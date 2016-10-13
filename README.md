# Multi Instanced Tomcat-Liferay Setup
Script for creating a multi instance Tomcat environment fast and for both creating and managing instances easily on it.

Tomcat installation itself remains in this setup uncustomized and is not Liferay specific but the scripts for creating managing Tomcat instances are made for Liferay using MySQL. You can however create your instances manually or with minor modifications make the generic. Feel free to modify the scripts for your own scenarios.
## Why? What is this setup Good for?
This setup may be suitable if you are longing for Glassfish or JBoss “like” domain functionality for Tomcat,  if you are going to run multiple independent Tomcat instances (like Liferay, Solr etc.) in your server and want to simplify Tomcat administration and maintenance (like upgrading).

If you are a developer or tester and need to have a simple way of creating and running Tomcat instances or sandboxes for example for clustering tests this may also be a good hit.

In this setup Tomcat installation remains fully untouched so it’s easy to upgrade it if necessary. Liferay’s shared libs are in the \[INSTALLATION_DIR\]/lib.
## Requirements / Reference Environment

* Ubuntu Linux 16.04 LTS (should work on 14.04 too)
* Java 8 full JDK
* MySQL (If installing Liferay 7 / DXP you have to have version 5.6 or higher)

## Usage instructions
###Creating environment

1. Clone the project
2. Configure your environment in configuration/configuration.sh
3. Run install_environment.sh

### Creating a new Tomcat instance

1. There is ready for use configuration for Liferay CE 7 GA3 but  you can make them more to the [\INSTALLATION_DIR\]/resources/configuration directory. The name of the directory serves as the name of the template for instance creation script.
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

Where my_instance_directory is the name of the directory under [INSTALLATION_DIR]/instances
## Notes
There are not many checks for your input in the scripts.
There is no instance delete script. You can remove the instance by simply removing the directory under  [INSTALLATION_DIR]/instances

**Improvement suggestions welcome!**

