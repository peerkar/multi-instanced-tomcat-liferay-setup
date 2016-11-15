#!/bin/sh

################################################################
#
# PATHS CONFIGURATION FILE FOR CREATING A LIFERAY 7 GA3 INSTANCE
#
################################################################

# If local file is defined it takes precedence. 

LIFERAY_PORTAL_WAR_FILE=
LIFERAY_PORTAL_WAR_DOWNLOAD_URL="http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-7.0-ga3-20160804222206210.war"

LIFERAY_DEPENDENCIES_FILE=
LIFERAY_DEPENDENCIES_DOWNLOAD_URL="http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-dependencies-7.0-ga3-20160804222206210.zip"

LIFERAY_OSGI_DEPENDENCIES_FILE=
LIFERAY_OSGI_DEPENDENCIES_DOWNLOAD_URL="http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-osgi-7.0-ga3-20160804222206210.zip"

TOMCAT_SUPPORT_JAR_FILE=$CONFIGURATION_DIR/support-tomcat.jar
TOMCAT_SUPPORT_JAR_DOWNLOAD_URL=

POST_INSTALL_SCRIPT=$CONFIGURATION_DIR/post_install.sh

