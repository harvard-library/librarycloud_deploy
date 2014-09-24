LibraryCloud Deployment
=======================

# Deploying a LibraryCloud server

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

