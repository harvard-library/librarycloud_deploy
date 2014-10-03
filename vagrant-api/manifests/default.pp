# Set the SQS environment to be used. This prefix will be used for all
# queues in the ingestion process

# Install required packages

$lc_packages = ["git", "java-1.7.0-openjdk", "ant", "tomcat", "tomcat-webapps", "tomcat-admin-webapps"]
package { $lc_packages: ensure => "installed", install_options => "--nogpgcheck", allow_virtual => false }

# package { "git": ensure => "installed", install_options => "--nogpgcheck", allow_virtual => false }
# package { "java-1.7.0-openjdk": ensure => "installed", install_options => "--nogpgcheck", allow_virtual => false }
# package { "ant": ensure => "installed", install_options => "--nogpgcheck", allow_virtual => false }

# Setup file system

file { [ 
		 "/usr/local/librarycloud/", 
		]:
    ensure => "directory",
}
 
# file { [ 
# 		 "/var/lib/librarycloud/files/dropbox"
# 		 "/var/lib/librarycloud/files/ingest-alpha"
# 		]:
#     ensure => "directory",
#     user => "ubuntu",
#     group => "ubuntu",
# }
# 

# Download code

vcsrepo { "/usr/local/librarycloud":
  ensure   => present,
  provider => git,
  source   => 'git://github.com/harvard-library/librarycloud.git',
}
# 
# # Setup credentials for AWS
# 
# file { "/usr/local/librarycloud/src/main/resources/aws.properties": 
# 	source => "/vagrant/secure/aws.properties",
# 	ensure => "present",
# }
# 
# # Set environmental-specific settings for test env
# # TODO: Find a better way to do this
# 
# file { "/usr/local/librarycloud/src/main/resources/librarycloud.env.properties": 
# 	content => "librarycloud.files.basepath=/var/lib/librarycloud/files\nlibrarycloud.sqs.environment=$sqs_env",
# 	ensure => "present",
# }
# 
# # Install service
# 
# file { "/etc/init/librarycloud.conf":
# 	ensure => "present",
# 	source => "/vagrant/librarycloud.conf",
# }
# 
# service { "librarycloud":
# 	ensure => "running",
# }
