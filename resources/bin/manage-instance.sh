#!/bin/bash
#
# Description: Tomcat instance management script. Thanks to https://web.liferay.com/web/brett.swaim/blog/-/blogs/sample-tomcat-startup-scripts
#
# Petteri Karttunen,  2016-09-08

#
# ARGUMENTS
#
INSTANCE_NAME=$1
CMD=$2

#
# VARIABLES
#
CATALINA_BASE=$INSTANCES_DIR/$INSTANCE_NAME
CATALINA_TMPDIR=$CATALINA_BASE/temp
FORCE_SHUTDOWN_THRESHOLD=45

#
# Check the credentials for running this script. Only root allowed.
#
check_run_credentials() {

	if ! [ $(id -u) = 0 ]; then
		printf "Please run this script as root or sudo.\n"
		exit 1
	fi
}

#
# Check  prequisites for the script to run
#
check_run_prequisites() {

	# Check that instance folder exists

	if [ ! -d "$CATALINA_BASE" ]; then
		printf "Instance not found. Please check instance's directory name.\n"
		exit 1
	fi

	# Check that mandatory arguments exist

	if [ -z "$INSTANCE_NAME" ] ||  [ -z "$CMD" ]; then
		printf "Missing arguments. Check usage info.\n"
		exit 1
	fi
}

#
# Get process id
#
get_pid() {
	echo `ps aux | grep -E $INSTANCE_NAME.*org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $2 }'`
}

#
# Start instance
#
start() {

	pid=$(get_pid)

	if [ -n "$pid" ]; then
		printf "Instance $INSTANCE_NAME seems to be running with PID $pid.\n"
	else
		printf "Starting instance $INSTANCE_NAME.\n"
	        su - -c "export CATALINA_HOME=$CATALINA_HOME CATALINA_BASE=$CATALINA_BASE CATALINA_TMPDIR=$CATALINA_TMPDIR JAVA_HOME=$JAVA_HOME ; export PATH=$PATH:$JAVA_HOME/bin ; $CATALINA_HOME/bin/catalina.sh start" $TOMCAT_USER
	fi
}

#
# Stop instance
#
stop() {

	pid=$(get_pid)

	if [ -n "$pid" ]; then

		printf "Stopping instance $INSTANCE_NAME PID $pid.\n"

	        su - -c "export CATALINA_HOME=$CATALINA_HOME CATALINA_BASE=$CATALINA_BASE CATALINA_TMPDIR=$CATALINA_TMPDIR JAVA_HOME=$JAVA_HOME ; export PATH=$PATH:$JAVA_HOME/bin ; $CATALINA_HOME/bin/catalina.sh stop" $TOMCAT_USER

		count=0

		step=5

		until [ `ps -p $pid | grep -c $pid` = '0' ] || [[ $count -gt $FORCE_SHUTDOWN_THRESHOLD ]]; do

			timeout=$((FORCE_SHUTDOWN_THRESHOLD-count))

			printf "Waiting for instance to shutdown. Seconds before forcing: $timeout.\n"

			sleep $step

			count=$((count+step))
		done

		if [[ $count -gt $FORCE_SHUTDOWN_THRESHOLD ]]; then

			printf "Forcing instance to shutdown after waiting for $FORCE_SHUTDOWN_THRESHOLD seconds.\n"

			kill -9 $pid
		fi

		printf "Instance was shut down.\n"

	else
		printf "Instance $INSTANCE_NAME seems not to be running.\n"
	fi
}

#
# Get status
#
status() {

	pid=$(get_pid)

	if [ -n "$pid" ]; then
		printf "Instance $INSTANCE_NAME seems to be running with pid $pid.\n"
	else
		printf "Instance $INSTANCE_NAME seems not to be running.\n"
	fi
}

printf "\n##################################################################################"
echo "#                                                                                #"
echo "#    Welcome to Tomcat instance management script.                               #"
echo "#                                                                                #"
echo "#    Usage: manage-instance.sh 'instance-folder-name' start|stop|restart|status  #"
echo "#                                                                                #"
printf "##################################################################################\n"

check_run_credentials;

check_run_prequisites;

#
# COMMAND ROUTING
#
case $CMD in
	start)
		start;;
	stop)
		stop;;
	restart)
		stop
		start;;
	status)
		status;;
	*)
		printf "Unknown command '$CMD'. Please check the usage info.";;
	esac

printf "\n"
exit 0

