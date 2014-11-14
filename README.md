# Setting up a full LibraryCloud environment at AWS

## Deploy a control server

1) Setup an AWS server with sufficient disk space to handle files to be loaded into LibraryCloud. A t2.small instance with 500GB of attached storage should be sufficient to start.

2) Attach the disk, set permissions, and download code
        
        lsblk
        sudo file -s /dev/xvdb
        sudo mkfs -t ext4 /dev/xvdb
        sudo mount /dev/xvdb /data
        sudo chown ec2-user /data
        sudo chgrp ec2-user /data
        sudo yum update
        sudo yum install git
        cd ~
        git clone https://github.com/harvard-library/librarycloud_ingest.git

3) Copy a private key that provides access to other AWS servers to the control server, and save it in the ~/keys folder.

4) Setups user and permissions that can be used to drop files ionto the control server

        mkdir /data/dropbox
        sudo useradd dropbox
        sudo chgrp -r /data/dropbox dropbox

5) Install AWS tools

        sudo yum install wget
        wget https://bootstrap.pypa.io/get-pip.py
        sudo python get-pip.py
        sudo pip install awscli
        git clone https://github.com/harvard-library/aws-tools.git

6) Setup AWS credentials. Enter access key, secret access key, and region when prompted.

        aws configure

7) Ensure AWS credentials are set in the environment, and the path includes necessary tools.

        export AWS_ACCESS_KEY_ID=<the access key>
        export AWS_SECRET_ACCESS_KEY=<the secret access key>
        export PATH=$PATH:~/aws-tools


## Deploy Search and API servers

Follow [these instructions](https://github.com/harvard-library/librarycloud#solr-installation-on-clean-rhel-server)

You may need to allocate more disk for the solr index. Mount a new disk as per [these instructions](#deploy-a-control-server) and edit the ```<dataDir>```attribute in  ```/usr/local/solr/solr/librarycloud/conf/solrconfig.xml``` to point to that mount point.

## Deploy an ingestion server

1) Create an aws.properties file with your AWS credentials:

        access.key=XXX
        secret.key=XXX

and place it at ```vagrant/secure/aws.properties```

2) Ensure that AWS credentials used in the Vagrantfile are available in your environment
        
        export AWS_ACCESS_KEY_ID=your_access_key
        export AWS_SECRET_ACCESS_KEY=your_secret_access_key
        export AWS_PRIVATE_AWS_SSH_KEY_PATH=path_to_ssh_private_key_for_aws
        export AWS_KEYPAIR_NAME="name of the AWS key pair"

3) Edit ```vagrant/manifests/default.pp``` and edit the $sqs_env environment variable. This sets the name of the queues used for a deployment of the ingestion pipeline. All servers within a single environment should have the same value. If you want to ensure that your work does not put data on another environment's queues, use a unique value (such as your username).

        # Set the SQS environment to be used. This prefix will be used for all
        # queues in the ingestion process
        $sqs_env = "test"

3) Provision the server

        vagrant up --provider=aws

4) Login to the server. It should be up and running and listening to queues
        
        vagrant ssh

## Prepare to launch multiple ingestion servers

1) Login to the AWS EC2 Console

2) Create a new Amazone Machine Image (AMI) from the ingestion server

3) Create a Launch Configuration from the saved AMI. Use the default options, but set the size to ```m3.2xlarge``` and ensure that the security group allows SSH access from the control server

# Ingest Aleph Data

0) Upload .mrc files to be ingested to ```/data/dropbox/full``` and ```/data/dropbox/incremental```

1) Login to the Control Server

2) Create and launch an Auto-Scaling Group from the previously created Launch Configuration. Use the defaults and set the requested number of servers to 10.

3) For each data file in ```/data/dropbox``` to be ingested, run the following command:

        ~/librarycloud_ingest/util/ingest_aleph.sh [PATH_TO_MRC_FILE] test

5) Wait for the ingestion to complete. Monitor progress by reviewing the SQS queues used in the environment (by default, the queues prefixed with ```test-```). When all queues except ```test-done``` and ```test-dead-letter``` are empty, the ingestion is complete.

6) Delete the Auto-Scaling Group to shut down the extra ingestion servers

# Ingest all data

## Preconditions

1) Data is available on the control server as follows

Location | Description | Timing
--- | --- | ---
/data/dropbox/aleph/full|Full export of all Aleph data|Sunday am|
/data/dropbox/aleph/incremental|Incremental Aleph updates|Monday 1pm, Wednesday 1pm|
/data/dropbox/aleph/delete|Records removed from Aleph|Monday 1pm, Wednesday 1pm, Friday midnight|
/data/dropbox/oasis/full|All OASIS files|Friday 7:30am|
/data/dropbox/via/full|All VIA files|Friday 7:30am|

2) There is an AMI with the latest ingest code. If one does not exist, install the latest ingest code on a server, and create an AMI from the Control server:

        aws ec2 create-image --instance-id INSTANCE_ID  --name "INGEST_AMI_NAME”

## Run full ingest

1) Login to the Control Server

2) Kickoff aleph ingest - look only at data files less than a week old

        find /data/dropbox/aleph/full -mtime -7 | xargs -L 1 ~/librarycloud_ingest/util/ingest.sh aleph test

3) Kickoff OASIS ingest - look only at data files less than a week old. Process in parallel (there are many files)

        find /data/dropbox/oasis/full -mtime -7 | xargs -P 10 -L 1 ~/librarycloud_ingest/util/ingest.sh oasis test

4) Kickoff OASIS ingest - look only at data files less than a week old. Process in parallel (there are many files)

        find /data/dropbox/via/full -mtime -7 | xargs -P 20 -L 1 ~/librarycloud_ingest/util/ingest.sh via test

5) Launch 10 additional ingest servers

        aws autoscaling create-launch-configuration --launch-configuration-name LibraryCloudIngest --image-id INGEST_AMI_NAME --key-name "SECURITY_GROUP_KEY_NAME" --security-groups SECURITY_GROUPS --instance-type m3.2xlarge

        aws autoscaling create-auto-scaling-group --availability-zones us-east-1a --auto-scaling-group-name LibraryCloudIngestGroup --launch-configuration-name LibraryCloudIngest --min-size 10 --max-size 10

5) Monitor SQS queues until all queues except for the "done" and "dead-letter" ones are empty

6) Shut down the additional ingest servers

## Run incremental ingest

1) Login to the Control Server

2) Kickoff aleph ingest - look only at data files less than two days old

        find /data/dropbox/aleph/incremental -mtime -2 | xargs -L 1 ~/librarycloud_ingest/util/ingest.sh aleph test





