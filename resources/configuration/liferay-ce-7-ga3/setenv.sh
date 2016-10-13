#!/bin/sh

# http://blog.sokolenko.me/2014/11/javavm-options-production.html

CATALINA_OPTS="$CATALINA_OPTS -server -d64"
CATALINA_OPTS="$CATALINA_OPTS -Xss512k -Xmn512m -Xms2048m -Xmx2048m -XX:MaxMetaspaceSize=512m"
CATALINA_OPTS="$CATALINA_OPTS -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=80"
CATALINA_OPTS="$CATALINA_OPTS -XX:+UseCodeCacheFlushing -XX:ReservedCodeCacheSize=512m"
CATALINA_OPTS="$CATALINA_OPTS -Dmail.mime.decodeparameters=true -Djava.awt.headless=true -XX:+PrintGCDateStamps"
CATALINA_OPTS="$CATALINA_OPTS -Djava.net.preferIPv4Stack=true  -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false"
CATALINA_OPTS="$CATALINA_OPTS -Duser.timezone=Europe/Helsinki -Dfile.encoding=UTF8"

