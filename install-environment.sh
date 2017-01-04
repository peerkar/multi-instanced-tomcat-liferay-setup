#!/bin/bash
#
# Description: Multi instanced Tomcat setup script for use with Liferay
#
# Petteri Karttunen,  2016-10-06
#

#
# Check that this script is run by sufficient privileges
#
check_run_privileges() {

	printf "Checking user: "

	if ! [ $(id -u) = 0 ]; then
	        printf "FAILED. Please run this script as root or sudo.\n"
	        exit 1
	fi

	printf "Ok.\n"
}

#
# Check environment
#
check_environment() {

	printf "Starting configuration check.\n"

	# Check if there's already an installation in the target

	_check_existing_installation;

	# Check Java installation and version

	_check_java;

	# Check database

	_check_db;
}

#
# Check that we are on Ubuntu
#
_check_os_and_version() {

	printf "Checking OS and version.\n"

	if [ -f /etc/lsb-release ]; then

		lsb_release -ri

		os_version=$(lsb_release -rs 2>&1)

		if [ ! "$os_version" = "16.04" ]; then
			printf "This procedure is supported only on version 16.04 at the moment.\n"
			exit 1
		fi

	else
		printf "This is not an Ubuntu distribution. Cannot continue procedure.\n"
		exit 1
	fi
}

#
# Check for existing installation
#
_check_existing_installation() {

	printf  "Checking installation dir: "

	if [ -d "$CATALINA_HOME" ]; then
	        printf "FAILED. Tomcat dir $CATALINA_HOME exists already. Cannot continue."
	        exit 1
	fi

	printf "OK.\n"
}

#
# Check Java installation dir and version
#
_check_java() {

	printf "Checking Java installation dir and version: "

	# Check JDK path

	if [ ! -d "$JDK_PATH" ]; then

		printf "JDK not found in path $JDK_PATH.\n"

		_install_java;
	fi

        # Check version

        if [[ -x "$JDK_PATH/bin/java" ]]; then
                printf "Java binary found, "
                java_binary="$JDK_PATH/bin/java"
        else
		printf  "Java binary not found.\n"

		_install_java;
        fi

	java_version=$("$java_binary" -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')
	java_version_pretty=$("$java_binary" -version 2>&1 | awk -F '"' '/version/ {print $2}')

	printf "Java version is $java_version_pretty, "

	if [[ "$java_version" -lt 18 ]]; then

		printf "Java 8 or higher is required.\n"

		_install_java;
	fi
}

#
# Install Java
#
_install_java() {

	_check_os_and_version;

	read -p "Do you want to setup Oracle Java 8 now?: " -n 1 -r
        printf "\n"

	if [[ $REPLY =~ ^[Yy]$ ]]; then

		printf "Installing Java.\n"

		add-apt-repository ppa:webupd8team/java
		apt-get update
		apt-get install oracle-java8-installer

	else
		printf "Cannot continue. Please install Java manually before continuing.\n"
		exit 1
	fi
}

#
# Check DB
#
_check_db() {
	_check_mysql;
}

#
# Check MySQL
#
_check_mysql() {

        if [ -x "$(command -v mysql)" ]; then

                printf "MySQL seems to be installed.\n" 
        else

                printf "MySQL not found.\n"

                read -p "Do you want to install MySQL server now?: " -n 1 -r
                printf "\n"

                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        _install_mysql_server;
                else
                        echo "Please install MySQL server manually before continuing.\n"
                        exit 1
                fi
        fi
}

#
# Instal MySQL server
#
_install_mysql_server() {
	apt-get install mysql-server
}

#
# Create directory structure
#
create_directory_structure() {

        printf "Creating directory structure.\n"

        mkdir -p $BIN_DIR
        mkdir -p $INSTANCES_DIR
        mkdir -p $LIB_DIR
        mkdir -p $DOWNLOAD_DIR
        mkdir -p $RESOURCES_DIR

        # Create symbolic link for the JDK. This is this path this setup is using even if there were multiple JDKs. 

        if [ ! -d  "$JAVA_HOME" ]; then

                printf "Linking $JDK_PATH to $JAVA_HOME.\n"

                ln -s $JDK_PATH $JAVA_HOME
        fi

	_copy_resources;
}

#
# Copy resources
#
_copy_resources() {

        printf "Copying resources.\n"

	cp -R resources/configuration $RESOURCES_DIR/
	cp -R resources/bin $INSTALLATION_DIR/
}

#
# Install files
#
install_tomcat() {

	printf "Starting Tomcat install.\n"

	# Create download dir

	mkdir -p $DOWNLOAD_DIR

	# Download Tomcat if defined

	if [ -z "$TOMCAT_FILE" ] || [ ! -f "$TOMCAT_FILE" ]; then

		TOMCAT_FILE=$(wget -P "$DOWNLOAD_DIR" --content-disposition "$TOMCAT_URL" 2>&1 | grep "Saving to: " | sed "s/Saving to: ‘\(.*\)’/\1/; 1q")

		# Check if Download succeeded

		if [ -z "$TOMCAT_FILE" ] || [ ! -f "$TOMCAT_FILE" ]; then
			printf "Downloading failed. Check the download url in the resources/configuration/configuration.sh\n"
			exit 1
		fi

		printf "Downloaded $TOMCAT_FILE.\n"
	else
		printf "Using local Tomcat file $TOMCAT_FILE.\n"
	fi

	# Resolve Tomcat extraction dir and install

	tomcat_dir=$(unzip -qql $TOMCAT_FILE | sed -r '1 {s/([ ]+[^ ]+){3}\s+//;q}')

	printf "Unzipping Tomcat to $INSTALLATION_DIR.\n"

	unzip $TOMCAT_FILE -d $INSTALLATION_DIR

	printf "Creating symbolic link $INSTALLATION_DIR/$tomcat_dir $CATALINA_HOME.\n"

	ln -s $INSTALLATION_DIR/$tomcat_dir $CATALINA_HOME
}

#
# Install common Liferay dependency libraries (usually not Liferay version specific)
#
install_common_liferay_dependencies() {

	printf "Start installing Liferay dependencies ...\n"

	_install_library_file "$ACTIVATION_JAR_FILE" "$ACTIVATION_JAR_URL";
	_install_library_file "$CCPP_JAR_FILE" "$CCPP_JAR_URL";

	_install_library_file "$JMS_JAR_FILE" "$JMS_JAR_URL";
	_install_library_file "$JTA_JAR_FILE" "$JTA_JAR_URL";
	_install_library_file "$JUTF7_JAR_FILE" "$JUTF7_JAR_URL";
	_install_library_file "$MAIL_JAR_FILE" "$MAIL_JAR_URL";
	_install_library_file "$MYSQL_JAR_FILE" "$MYSQL_JAR_URL";
	_install_library_file "$PERSISTENCE_JAR_FILE" "$PERSISTENCE_JAR_URL";
	_install_library_file "$POSTGRESQL_JAR_FILE" "$POSTGRESQL_JAR_URL";

	# These come in dependencies war

	#_install_library_file "$PORTLET_JAR_FILE" "$PORTLET_JAR_URL";
	#_install_library_file "$HSQL_JAR_FILE" "$HSQL_JAR_URL";
}

#
# Copy or download common a single library file to it's correct location
#
_install_library_file() {

       if [ -z "$1" ] || [ ! -f "$1" ]; then
                wget -P $LIB_DIR --content-disposition "$2"
                printf  "Downloaded $2 to $LIB_DIR.\n"
        else
                printf "Copied $1 to $LIB_DIR.\n"
        fi
}

#
# Create Tomcat user
#
setup_tomcat_user() {

	printf "Setting up Tomcat user and group\n"

	# Create Tomcat user group if necessary

	if [ ! $(getent group $TOMCAT_GROUP) ]; then
		printf "Creating Tomcat group $TOMCAT_GROUP\n"
		groupadd $TOMCAT_GROUP
	else
		printf "Tomcat group $TOMCAT_USER exists already\n"
	fi

	# Create Tomcat user if necessary

	if [ $(id -u $TOMCAT_USER > /dev/null 2>&1; echo $?) != 0 ]; then
		printf "Creating Tomcat user $TOMCAT_USER\n"
		sudo useradd -g $TOMCAT_GROUP -r -m -d $TOMCAT_HOME_DIR -s /usr/sbin/nologin $TOMCAT_USER
	else
		printf "Tomcat user $TOMCAT_USER exists already\n"
	fi
}

setup_filesystem_rights() {

	printf "Setting up filesystem rights\n"

	chown -R $TOMCAT_USER:$TOMCAT_GROUP $INSTALLATION_DIR

	# We shouldn't be using the "root" instance but set the rights anyways

	_setup_tomcat_instance_filesystem_rights $CATALINA_HOME;
}

#
# Setup Tomcat's file system rights
#
_setup_tomcat_instance_filesystem_rights() {

	printf "Setting up Tomcat instance $1 filesystem rights\n"

	# Users can not modify the configuration of tomcat.

	if [ -d "$1/conf" ]; then
		chmod -R g+r $1/conf
	fi

        # Users can modify the other folders

        chmod -R g+w $1/logs
        chmod -R g+w $1/temp
        chmod -R g+w $1/webapps
        chmod -R g+w $1/work

	# Execute rights

	chmod -R 750 $1/bin
}

printf "\n##################################################################################\n"
printf "#                                                                                #\n"
printf "#    Tomcat installation script                                                  #\n"
printf "#                                                                                #\n"
printf "##################################################################################\n"

cd "$(dirname "$0")"

source resources/configuration/configuration.sh

check_run_privileges;

check_environment;

create_directory_structure;

install_tomcat;

install_common_liferay_dependencies;

setup_tomcat_user;

setup_filesystem_rights;

printf "\nAll done succesfully!\n"

printf "\nCreate a new Liferay instance by running script $BIN_DIR/create_instance.sh\n\n"

exit 0
