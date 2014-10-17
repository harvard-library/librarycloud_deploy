# Setting up a full LibraryCloud environment at AWS

## Deploy a control server

1) Setup an AWS server with sufficient disk space to handle files to be loaded into LibraryCloud. A t2.small instance with 100GB of attached storage should be sufficient to start.

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

3) Wait for the servers to boot.

4) For each data file in ```/data/dropbox``` run the following command:

        ~/librarycloud_ingest/util/ingest_aleph.sh [PATH_TO_MRC_FILE] [INTERNAL_IP_OF_AN_INGESTION_SERVER] [PRIVATE_KEY]

Rotate among the servers when uploading the files, to spread the load amongst the different servers. _Note: Further testing is required to see how much of a difference this actually makes._

_Another Note: The requirement to include the private key on the command line can potentially be removed in the future_

5) Wait for the ingestion to complete. Monitor progress by reviewing the SQS queues used in the environment (by default, the queues prefixed with ```test-```). When all queues except ```test-done``` and ```test-dead-letter``` are empty, the ingestion is complete.

6) Delete the Auto-Scaling Group to shut down the extra ingestion servers





