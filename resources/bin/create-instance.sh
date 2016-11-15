#!/bin/bash
#
# Description: Tomcat Liferay instance creation script
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

        printf "OK\n"
}

#
# Read input from tty
#
read_input() {

	while [[ -z $CONFIGURATION_NAME ]]; do
	    read -p "Please enter the name of the configuration to use (eg. liferay-ce-7-ga3: " CONFIGURATION_NAME
	done

	while [[ -z $INSTANCE_NAME ]]; do
	    read -p "Name for the new instance: " INSTANCE_NAME
	done

	while [[ -z $SHUTDOWN_PORT ]]; do
	    read -p "Shutdown port (for example 8000): " SHUTDOWN_PORT
	done

	while [[ -z $AJP_CONNECTOR_PORT ]]; do
	    read -p "AJP connector port (for example 8010): " AJP_CONNECTOR_PORT
	done

	while [[ -z $HTTP_CONNECTOR_PORT ]]; do
	    read -p "Http connector port (for example 8080): " HTTP_CONNECTOR_PORT
	done

	while [[ -z $REDIRECT_PORT ]]; do
	    read -p "Redirect port (for example 8440): " REDIRECT_PORT
	done

	while [[ -z $MYSQL_USERNAME ]]; do
	    read -p "MySQL username to use for creating database: " MYSQL_USERNAME
	done

	while [[ -z $MYSQL_PASSWORD ]]; do
	    read -s -p "Password: " MYSQL_PASSWORD
	done

	printf "\n"

	while [[ -z $DB_USERNAME ]]; do
	    read -p "MySQL username for the new instance: " DB_USERNAME
	done

	while [[ -z $DB_PASSWORD ]]; do
	    read -s -p "Password: " DB_PASSWORD
	done

	printf "\n"

	CONFIGURATION_DIR=$RESOURCES_DIR/configuration/$CONFIGURATION_NAME
	INSTANCE_DIR=$INSTANCES_DIR/$INSTANCE_NAME
	LIFERAY_HOME=$INSTANCE_DIR/liferay-home

	source $CONFIGURATION_DIR/configuration.sh
}

create_directory_structure() {

        mkdir -p $INSTANCE_DIR/bin
        mkdir -p $INSTANCE_DIR/lib
        mkdir -p $INSTANCE_DIR/logs
        mkdir -p $INSTANCE_DIR/temp
        mkdir -p $INSTANCE_DIR/work
        mkdir -p $INSTANCE_DIR/webapps

        printf "Created instance directory structure.\n"
}

copy_conf_directory() {

	cp -R $CATALINA_HOME/conf $INSTANCE_DIR/

	printf "Copied default conf directory to $INSTANCE_DIR.\n"

}

create_liferay_home() {

        mkdir -p $LIFERAY_HOME

        printf "Created Liferay home directory $LIFERAY_HOME.\n"
}

copy_setenv() {

	cp $CONFIGURATION_DIR/setenv.sh $INSTANCE_DIR/bin/

	printf "Copied setenv.sh to  $INSTANCE_DIR/bin.\n" 
}

#
# Setup Catalina policy file in place
#
setup_catalina_policy() {

	cp $INSTANCE_DIR/conf/catalina.policy $INSTANCE_DIR/conf/catalina.policy.original

	echo "grant { permission java.security.AllPermission };" > $INSTANCE_DIR/conf/catalina.policy

	printf "Set up catalina.policy.\n"
}

#
# Add our lib folder to the common loader path
#
setup_catalina_properties() {

	# Have to do the append before \r

	sed -i.original 's/\(^common\.loader.*\)\(\r\)/\1,"\${catalina\.home}\/\.\.\/lib\/\*\.jar"/' $INSTANCE_DIR/conf/catalina.properties

	printf "Set up catalina.properties.\n"
}

#
# Setup context.xml
#
# http://stackoverflow.com/questions/26893297/tomcat-8-throwing-org-apache-catalina-webresources-cache-getresource-unable-to
#
setup_context_xml() {
	sed -i.original "s/<\/Context>/   <Resources cachingAllowed=\"true\" cacheMaxSize=\"100000\" \/>\n<\/Context>/" $INSTANCE_DIR/conf/context.xml

	printf "Set up context.xml.\n"
}

#
# Setup server xml and port definitions in it
#
setup_server_xml() {

	cp $INSTANCE_DIR/conf/server.xml $INSTANCE_DIR/conf/server.xml.original

        sed -i "s/Server port=\"8005\"/Server port=\"$SHUTDOWN_PORT\"/" $INSTANCE_DIR/conf/server.xml
        sed -i "s/Connector port=\"8009\"/Connector port=\"$AJP_CONNECTOR_PORT\"/" $INSTANCE_DIR/conf/server.xml
        sed -i "s/Connector port=\"8080\"/Connector port=\"$HTTP_CONNECTOR_PORT\"/" $INSTANCE_DIR/conf/server.xml
        sed -i "s/redirectPort=\"8443\"/redirectPort=\"$REDIRECT_PORT\"/g" $INSTANCE_DIR/conf/server.xml

	printf "Set up server.xml.\n"
}

#
# Create MySQL database
#
setup_database() {

	# Use instance name as database name. Clean illegal characters.

	DB_NAME=$(echo $INSTANCE_NAME | sed 's/[^a-zA-Z 0-9]/_/g')

	mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --execute="CREATE DATABASE $DB_NAME CHARACTER SET UTF8;"
	mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --execute="GRANT ALL PRIVILEGES ON $DB_NAME.* to $DB_USERNAME@localhost IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"

	printf "Created database $DB_NAME. Granted rights for user $DB_USERNAME.\n"
}

#
# Setup ROOT.xml
#
setup_root_xml() {
	mkdir -p $INSTANCE_DIR/conf/Catalina/localhost
	cp $CONFIGURATION_DIR/ROOT.xml $INSTANCE_DIR/conf/Catalina/localhost/
	sed -i "s/username=\"\"/username=\"$DB_USERNAME\"/" $INSTANCE_DIR/conf/Catalina/localhost/ROOT.xml
	sed -i "s/password=\"\"/password=\"$DB_PASSWORD\"/" $INSTANCE_DIR/conf/Catalina/localhost/ROOT.xml
	sed -i "s/url=\"\"/url=\"jdbc:mysql:\/\/localhost\/$DB_NAME?useUnicode=true\&amp;characterEncoding=UTF-8\&amp;useFastDateParsing=false\"/" $INSTANCE_DIR/conf/Catalina/localhost/ROOT.xml
}

#
# Install portal war
#
install_war() {

       if [ -z "$LIFERAY_PORTAL_WAR_FILE" ] || [ ! -f "$LIFERAY_PORTAL_WAR_FILE" ]; then
                printf "Downloading portal WAR.\n"
                LIFERAY_PORTAL_WAR_FILE=$(wget -P "$DOWNLOAD_DIR" --content-disposition "$LIFERAY_PORTAL_WAR_DOWNLOAD_URL" 2>&1 | grep "Saving to: " | sed "s/Saving to: ‘\(.*\)’/\1/; 1q")
        else
                printf "Using local Liferay portal war.\n"
        fi

	mkdir -p $INSTANCE_DIR/webapps/ROOT

	unzip $LIFERAY_PORTAL_WAR_FILE -d $INSTANCE_DIR/webapps/ROOT

	printf "Extracted portal war to $INSTANCE_DIR/webapps.\n"
}

#
# Install portal dependencies
#
install_dependencies() {

        if [ -z "$LIFERAY_DEPENDENCIES_FILE" ] || [ ! -f "$LIFERAY_DEPENDENCIES_FILE" ]; then
                printf "Downloading dependencies.\n"
                LIFERAY_DEPENDENCIES_FILE=$(wget -P "$DOWNLOAD_DIR" --content-disposition "$LIFERAY_DEPENDENCIES_DOWNLOAD_URL" 2>&1 | grep "Saving to: " | sed "s/Saving to: ‘\(.*\)’/\1/; 1q")
        else
                printf "Using local depencies war.\n"
        fi

        folder_name=$(unzip -qql $LIFERAY_DEPENDENCIES_FILE | sed -r '1 {s/([ ]+[^ ]+){3}\s+//;q}')

	unzip -j $LIFERAY_DEPENDENCIES_FILE "$folder_name*" -d $INSTANCE_DIR/lib

	printf "Extracted portal dependencies to $INSTANCE_DIR/lib.\n"
}

#
# Install portal OSGI dependencies
#
install_osgi_dependencies() {

        if [ -z "$LIFERAY_OSGI_DEPENDENCIES_FILE" ] || [ ! -f "$LIFERAY_OSGI_DEPENDENCIES_FILE" ]; then
                printf "Downloading OSGI dependencies.\n"
                LIFERAY_OSGI_DEPENDENCIES_FILE=$(wget -P "$DOWNLOAD_DIR" --content-disposition "$LIFERAY_OSGI_DEPENDENCIES_DOWNLOAD_URL" 2>&1 | grep "Saving to: " | sed "s/Saving to: ‘\(.*\)’/\1/; 1q")
        else
                printf "Using local OSGI depencies file.\n"
        fi

        folder_name=$(unzip -qql $LIFERAY_OSGI_DEPENDENCIES_FILE | sed -r '1 {s/([ ]+[^ ]+){3}\s+//;q}')

	unzip $LIFERAY_OSGI_DEPENDENCIES_FILE -d $LIFERAY_HOME

	mv $LIFERAY_HOME/$folder_name/osgi $LIFERAY_HOME/osgi

	rm -r $LIFERAY_HOME/$folder_name

	printf "Extracted OSGI dependencies to $LIFERAY_HOME.\n"
}

#
# Place Tomcat support file instance specific as it's portal version dependant
#
install_tomcat_support_dependency() {

        if [ -z "$TOMCAT_SUPPORT_JAR_FILE" ] || [ ! -f "$TOMCAT_SUPPORT_JAR_FILE" ]; then
                wget -P $INSTANCE_DIR/lib --content-disposition "$TOMCAT_SUPPORT_JAR_URL"
		printf "Downloaded $TOMCAT_SUPPORT_JAR_FILE to $INSTANCE_DIR/lib.\n"
        else
		cp $TOMCAT_SUPPORT_JAR_FILE $INSTANCE_DIR/lib/
	        printf  "Copied $TOMCAT_SUPPORT_JAR_FILE to $INSTANCE_DIR/lib.\n"
        fi
}

#
# Copy minimal portal-ext.properties in place
#
install_portal_ext() {

	cp $CONFIGURATION_DIR/portal-ext.properties $INSTANCE_DIR/webapps/ROOT/WEB-INF/classes/

	printf "Copied portal-ext.properties to $INSTANCE_DIR/webapps/ROOT/WEB-INF/classes/.\n"
}

#
# Setup folder rights (http://superuser.com/questions/632618/best-practice-for-access-permission-to-users-for-apache-tomcat)
#
set_folder_rights() {

	chown -R $TOMCAT_USER:$TOMCAT_GROUP $INSTANCE_DIR

        # Users can not modify the configuration of tomcat

        chmod -R g+r $INSTANCE_DIR/conf

        # Users can modify the other folders

        chmod -R g+w $INSTANCE_DIR/logs
        chmod -R g+w $INSTANCE_DIR/temp
        chmod -R g+w $INSTANCE_DIR/webapps
        chmod -R g+w $INSTANCE_DIR/work

        printf "Set up folder rights.\n"
}

#
# Check if there is a post install script and run it .
#
run_post_install_tasks() {

        if [ -z "$POST_INSTALL_SCRIPT" ] || [ ! -f "$POST_INSTALL_SCRIPT" ]; then
                printf  "No post install tasks to run..\n"
        else
                printf "Running post install script.\n"
		source $POST_INSTALL_SCRIPT
        fi
}

printf "\n##################################################################################\n"
printf "#                                                                                #\n"
printf "#    Tomcat instance creation script                                             #\n"
printf "#                                                                                #\n"
printf "##################################################################################\n"

cd "$(dirname "$0")"

source ../resources/configuration/configuration.sh

check_run_privileges;

read_input;

create_directory_structure;

copy_conf_directory;

create_liferay_home;

copy_setenv;

setup_catalina_policy;

setup_catalina_properties;

setup_context_xml;

setup_server_xml;

setup_database;

setup_root_xml;

install_war;

install_dependencies;

install_osgi_dependencies;

install_tomcat_support_dependency;

install_portal_ext;

set_folder_rights;

run_post_install_tasks;

printf "\nAll done succesfully!\n"

printf "\nYou can manage the new instance with $BIN_DIR/manage_instance.sh $INSTANCE_NAME start|stop|restart\n\n"

exit 0
