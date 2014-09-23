
# Install required packages

package { "git": ensure => "installed" }
package { "maven": ensure => "installed" }
package { "default-jdk": ensure => "installed" }

# Setup file system

file { [ 
		 "/usr/local/librarycloud/", 
		 "/var/lib/librarycloud", 
		 "/var/lib/librarycloud/files"
		]:
    ensure => "directory",
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
	content => "librarycloud.files.basepath=/var/lib/librarycloud/files\nlibrarycloud.sqs.environment=test",
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
