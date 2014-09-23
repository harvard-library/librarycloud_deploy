LibraryCloud Deployment
=======================

1) Create an aws.properties file with your AWS credentials:

        access.key=XXX
        secret.key=XXX

and place it at ```vagrant/secure/aws.properties```

2) Ensure that AWS credentials used in the Vagrantfile are available in your environment (to do: more details here)

3) Provision the server

        vagrant up --provider=aws



