#!/bin/sh

###################################
#
# BASE CONFIGURATION FOR THIS SETUP
#
###################################

#
# TOMCAT RUN CREDENTIALS
#

TOMCAT_USER=portal

TOMCAT_GROUP=portal

#
# DIRECTORIES
#

#
# Note that a full Java 8 JDK is required and you have install / link by yourself
#
JAVA_HOME=/opt/tomcat/jdk-current

# Path to the JDK (this is where apt installs Oracle 8 Java by default).

#JDK_PATH=/opt/jdk1.8.0_102
JDK_PATH=/usr/lib/jvm/java-8-oracle

# Base installation dir. Everything goes inside this.

INSTALLATION_DIR=/opt/tomcat

# Tomcat home / Tomcat symlink dir. This is the directory being referenced in the instance management scripts.

CATALINA_HOME=$INSTALLATION_DIR/tomcat-current

# Scripts and binaries dir

BIN_DIR=$INSTALLATION_DIR/bin

# Tomcat instances live here

INSTANCES_DIR=$INSTALLATION_DIR/instances

# Libraries shared with all Liferay instances

LIB_DIR=$INSTALLATION_DIR/lib

# Resources dir

RESOURCES_DIR=$INSTALLATION_DIR/resources

# Downloads dir

DOWNLOAD_DIR=$RESOURCES_DIR/download

# Home directory for the portal user

TOMCAT_HOME_DIR=/home/$TOMCAT_USER

#
# TOMCAT INSTALLATION FILE
#
# If local file is defined it'll have precedence over download url.
#

TOMCAT_FILE=
TOMCAT_URL=http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.8/bin/apache-tomcat-8.5.8.zip

#
# LIFERAY SHARED LIBRARIES
#
# Note: The versions used are the ones from 7.0 GA3 package (except JMS)
#
# https://dev.liferay.com/discover/deployment/-/knowledge_base/7-0/installing-liferay-on-tomcat-8
#

ACTIVATION_JAR_FILE=
ACTIVATION_JAR_URL=http://central.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar

CCPP_JAR_FILE=
CCPP_JAR_URL=http://central.maven.org/maven2/javax/ccpp/ccpp/1.0/ccpp-1.0.jar

HSQL_JAR_FILE=
HSQL_JAR_URL=http://central.maven.org/maven2/org/hsqldb/hsqldb/2.3.3/hsqldb-2.3.3.jar

# http://stackoverflow.com/questions/3622773/java-net-maven-repo-jms-artifact-missing

JMS_JAR_FILE=
JMS_JAR_URL=http://repo1.maven.org/maven2/javax/jms/jms-api/1.1-rev-1/jms-api-1.1-rev-1.jar

JTA_JAR_FILE=
JTA_JAR_URL=http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar

JUTF7_JAR_FILE=
JUTF7_JAR_URL=https://repository.jboss.org/nexus/content/repositories/thirdparty-releases/com/beetstra/jutf7/jutf7/0.9.0/jutf7-0.9.0.jar

MAIL_JAR_FILE=
MAIL_JAR_URL=http://central.maven.org/maven2/javax/mail/mail/1.4/mail-1.4.jar

MYSQL_JAR_FILE=
MYSQL_JAR_URL=http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.23/mysql-connector-java-5.1.23.jar

PERSISTENCE_JAR_FILE=
PERSISTENCE_JAR_URL=http://central.maven.org/maven2/org/eclipse/persistence/javax.persistence/2.0.0/javax.persistence-2.0.0.jar

PORTLET_JAR_FILE=
PORTLET_JAR_URL=https://repo1.maven.org/maven2/org/apache/portals/portlet-api_2.1.0_spec/1.0/portlet-api_2.1.0_spec-1.0.jar

POSTGRESQL_JAR_FILE=
POSTGRESQL_JAR_URL=http://central.maven.org/maven2/org/postgresql/postgresql/9.4-1201-jdbc41/postgresql-9.4-1201-jdbc41.jar

