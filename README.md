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




