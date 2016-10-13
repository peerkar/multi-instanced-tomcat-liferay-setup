# Multi Instanced Tomcat-Liferay Setup
Scripts for creating a multi instance Tomcat environment and for both creating and managing instances fast and easily on it.

In this setup instances and Liferay's common libraries are fully separated from Tomcat base installation to make upgrading Tomcat's version or testing with different  versions simple.

Scripts for creating managing instances are made for Liferay using MySQL but you can  create your instances manually as well or with minor modifications make the scripts generic. Feel free to modify the scripts for your own scenarios.
## Why? What is this setup Good for?
This setup may be suitable if you are longing for Glassfish or JBoss “like” domain functionality for Tomcat,  if you are going to run multiple independent Tomcat instances (like Liferay, Solr etc.) in your server and want to simplify Tomcat administration and maintenance (like upgrading).

If you are a developer or tester and need to have a simple and fast way of creating and running Tomcat instances or sandboxes for example for clustering tests this may also be a good hit.

## Requirements / Reference Environment

* Ubuntu Linux 16.04 LTS (should work on 14.04 too)
* Java 8 full JDK
* MySQL (If installing Liferay 7 / DXP you have to have version 5.6 or higher)

## Usage instructions
###Creating environment

1. Clone the project
2. Configure your environment in resources/configuration/configuration.sh
3. Run install_environment.sh

The resulting directory structure (in the target directory) should look like this:

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
    └── tomcat-current -> /opt/tomcat/apache-tomcat-8.5.5/ [Symbolic link. References to the installation are made through this link.]




### Creating a new Tomcat instance

1. There is ready for use configuration for Liferay CE 7 GA3 but  you can make them more to the \[INSTALLATION_DIR\]/resources/configuration directory. The name of the directory serves as the name of the template for instance creation script.
2. Create a new instances with [INSTALLATION_DIR]/bin/create-instance.sh. 

You need to know free ports (shutdown, ajp, http, redirect) for your Tomcat instance here and MySQL credentials for creating new databases. Be sure that ports do not conflict with other instances or reservations by your system. Depending on the environment one possible and easy to remember numbering schema could be:

* shutdown:         8000-
* ajp-connector:   8010-
* http-connector:  8080-
* redirect:             8440

This way numbering is easy to remember.
### Start and stop instances
Manage your instance (start|stop|restart) with \[INSTALLATION_DIR\]/bin/manage\_instance.sh

**Example:**
/opt/tomcat/bin/manage\_instance my\_instance\_directory start

Where my\_instance\_directory is the name of the directory under [INSTALLATION_DIR]/instances
## Notes
There are not many checks for your input in the scripts.
There is no instance delete script. You can remove the instance by simply removing the directory under  [INSTALLATION_DIR]/instances

**Improvement suggestions welcome!**


