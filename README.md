# Multi Instanced Tomcat - Liferay Setup
Scripts for creating a multi instance Tomcat environment and scripts for both creating and managing Liferay instances fast and easily on it. Configuration template for Liferay 7 CE GA3 is provided.
## Why? What is this setup good for?
The original motivation for this project was to create an easy to setup and templatable environment for Liferay. But it may be suitable for generic purposes if you are just longing for Glassfish or JBoss “like” domain functionality for Tomcat, if you are going to run multiple independent Tomcat instances (like clustered Liferay, Liferay + Solr etc.) in single server and want to simplify Tomcat administration and maintenance. This setup requires only one base installation of Tomcat and you still can run as many separate instances simultaneously as your server can handle. 

Tomcat base installation remains in this setup intact. Additional common loader libraries and instances are in dedicated directories. This makes make upgrading Tomcat's version or testing with different versions flexible.

Setup is using JDK through symbolic linked jdk-current directory to ease switching between the JDK's if necessary. You can also manually define a certain JDK for certain instance.

The instance setup script is for Liferay and MySQL but you can create your Tomcat instances manually also as well or modify them to make them suitable for your own scenarios. An effort have been made to make the scripts readable and simple for customization purposes. 

## Requirements / Reference environment

Tested in Ubuntu Linux 16.04 LTS environment.

## Usage instructions

There are three scripts in this package:

* **install-environment.sh:** creates Tomcat environment, sets up MySQL and Java
* **create\-liferay-instance.sh:** creates a new Liferay instance based on custom definable templates
* **manage-instance.sh:** starts and stops instances


###Creating environment

1. Clone the project
2. Modify configuration if necessary (resources/configuration/configuration.sh)
3. Run install_environment.sh

The resulting directory structure (in the target directory (default /opt/tomcat)) should look like this:

    ├── apache-tomcat-8.5.5 [Uncustomized Tomcat installation]
    ├── bin
    │   ├── create-liferay-instance.sh [Script for creating instances]  
    │   └── manage-instance.sh [Script for starting and stopping instances]
    ├── instances [Instances root dir]
    ├── jdk-current [Symbolic link to the default JDK]
    ├── lib [Liferay's shared libs]  
    ├── resources
    │   ├── configuration
    │   │   ├── configuration.sh [Configuration file for the scripts]
    │   │   ├── liferay-ce-7-ga3 [Template configuration Liferay CE 7 GA3 instance]
    │   ├── download [Files downloaded by the scripts]
    └── tomcat-current -> /opt/tomcat/apache-tomcat-8.5.5/ [Symlink referenced as Catalina Home by instances]




### Creating a new Tomcat instance

1. Create an instance template if needed. There is configuration templage for Liferay CE 7 GA3 in this package and you can make more configurations to the \[INSTALLATION_DIR\]/resources/configuration directory (see instructions below). The name of the directory serves as the name of the template for instance creation script.
2. Create a new instances with [INSTALLATION_DIR]/bin/create-instance.sh \[TEMPLATE_DIR_NAME\]. 

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
Manage your instance (start|stop|restart) with \[INSTALLATION_DIR\]/bin/manage\-instance.sh

**Example:**
/opt/tomcat/bin/manage\-instance my\_instance\_directory start

Where my\_instance\_directory is the name of the directory under [INSTALLATION_DIR]/instances
## Notes
* There are not many input checks etc. in the scripts.
* There is no instance delete script. You can remove the instance by simply removing the directory under  [INSTALLATION_DIR]/instances

**Improvement suggestions welcome!**

