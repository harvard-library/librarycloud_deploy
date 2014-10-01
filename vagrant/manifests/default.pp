# Set the SQS environment to be used. This prefix will be used for all
# queues in the ingestion process

$sqs_env = "test"

# Install required packages

package { "git": ensure => "installed" }
package { "maven": ensure => "installed" }
package { "default-jdk": ensure => "installed" }

# Setup file system

file { [ 
		 "/usr/local/librarycloud/", 
		 "/var/lib/librarycloud", 
		 "/var/lib/librarycloud/files",
		]:
    ensure => "directory",
}

file { [ 
		 "/var/lib/librarycloud/files/dropbox",
		 "/var/lib/librarycloud/files/ingest-aleph",
		]:
    ensure => "directory",
    owner => "ubuntu",
    group => "ubuntu",
}

# Download code

vcsrepo { "/usr/local/librarycloud":
  ensure   => present,
  provider => git,
  source   => 'git://github.com/harvard-library/librarycloud_ingest.git',
}

# Setup credentials for AWS

file { "/usr/local/librarycloud/src/main/resources/aws.properties": 
	source => "/vagrant/secure/aws.properties",
	ensure => "present",
}

# Set environmental-specific settings for test env
# TODO: Find a better way to do this

file { "/usr/local/librarycloud/src/main/resources/librarycloud.env.properties": 
	content => "librarycloud.files.basepath=/var/lib/librarycloud/files\nlibrarycloud.sqs.environment=$sqs_env\nsolr_url=http://ec2-54-172-18-87.compute-1.amazonaws.com:8983/solr/librarycloud
",
	ensure => "present",
}

# Install service

file { "/etc/init/librarycloud.conf":
	ensure => "present",
	source => "/vagrant/librarycloud.conf",
}

service { "librarycloud":
	ensure => "running",
}
