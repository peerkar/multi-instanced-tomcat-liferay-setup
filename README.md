# Multi Instanced Tomcat-Liferay Setup
Script for creating a multi instance Tomcat environment and scripts for both creating and managing instances fast and easily on it.

## Why? What is this setup Good for?
This setup may be suitable if you are longing for Glassfish or JBoss “like” domain functionality for Tomcat, if you are going to run multiple independent Tomcat instances (like clustered Liferay, Solr, Elasticsearch etc.) in single server and want to simplify Tomcat administration and maintenance. This setup requires only one base installation of Tomcat and you still can run as many separate instances simultaneously as your server can handle. 

In this setup Tomcat base installation is just a matter of unzipping the package. Additional common loader libraries and instances are in dedicated directories. This makes make upgrading Tomcat's version or testing with different versions as simple as possible.

Scripts for creating and managing instances in this setup are made for Liferay using MySQL but you can create your instances manually as well or with minor modifications make the scripts generic or suitable for your own scenarios. An effort have been made to make the scripts readable and simple for customization purposes. 

## Requirements / Reference Environment

* Ubuntu Linux 16.04 LTS (should work on versions 12 and 14 too)
* Java 8 full JDK
* MySQL (If installing Liferay 7 / DXP you have to have version 5.6 or higher)

## Usage instructions
###Creating environment

1. Clone the project
2. Make to your environment necessary modifications in resources/configuration/configuration.sh
3. Run install_environment.sh

The resulting directory structure (in the target directory (default /opt)) should look like this:

    ├── apache-tomcat-8.5.5 [Uncustomized Tomcat installation]
    ├── bin
    │   ├── create-instance.sh [The script for creating instances]  
    │   └── manage-instance.sh [The script for starting and stopping instances]
    ├── instances [Instances live here]
    ├── lib [Liferay's shared libs (usually in tomcat-xxx/lib/ext)]  
    ├── resources
    │   ├── configuration
    │   │   ├── configuration.sh [Main configuration file]
    │   │   ├── liferay-ce-7-ga3 [Configuration for creating Liferay CE 7 GA3 instances]
    │   ├── download [Downloads go here]
    │   └── templates
    │       └── instance-template [A blank instance template]
    └── tomcat-current -> /opt/tomcat/apache-tomcat-8.5.5/ [Symbolic link which is referenced as Catalina Home from the instances.]




### Creating a new Tomcat instance

1. There is ready to use configuration for Liferay CE 7 GA3 in this package but you can make more configurations to the \[INSTALLATION_DIR\]/resources/configuration directory. The name of the directory serves as the name of the template for instance creation script.
2. Create a new instances with [INSTALLATION_DIR]/bin/create-instance.sh. 

For this script you need to know free ports (shutdown, ajp, http, redirect) for the new Tomcat instance and MySQL credentials for creating new databases. Be sure that ports do not conflict with other instances or reservations by your system. Depending on the environment one possible and easy to remember numbering schema could be:

* shutdown:        8000-
* ajp-connector:   8010-
* http-connector:  8080-
* redirect:        8440-


### Creating a configuration for another Liferay version (like DXP)

1. Copy the default liferay-ce-7-ga3 directory to the same location under different name
2. Make configuration changes to the files in the directory as needed

After that you can use this configuration with create\_instance.sh -script. Notice that support-tomcat.jar in the default configurations folder is Liferay version specific.


### Start and stop instances
Manage your instance (start|stop|restart) with \[INSTALLATION_DIR\]/bin/manage\_instance.sh

**Example:**
/opt/tomcat/bin/manage\_instance my\_instance\_directory start

Where my\_instance\_directory is the name of the directory under [INSTALLATION_DIR]/instances
## Notes
These scripts are purposedly simple and generic. There are not many checks for your input in the scripts.

There is no instance delete script. You can remove the instance by simply removing the directory under  [INSTALLATION_DIR]/instances

**Improvement suggestions welcome!**

