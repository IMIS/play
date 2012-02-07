#!/bin/bash
# chkconfig: 345 20 80
# description: Play start/shutdown script
# processname: play
#
# Instalation:
# copy file to /etc/init.d
# chmod +x /etc/init.d/play
# chkconfig --add /etc/init.d/play
# chkconfig play on
#
# Usage: (as root)
# service play start
# service play stop
# service play status
#
# Remember, you need python 2.6 to run the play command, it doesn't come standard with RedHat/Centos 5.5
# Also, you may want to temporarely remove the >/dev/null for debugging purposes

# Path to the application
APPLICATION_PATH=/opt/ishop-name-app

# Path to play install folder
PLAY_HOME=/opt/play/play
PLAY=$PLAY_HOME/play
HOST=yourshop.imis.ch
PLAY_RUN="$PLAY start -Dprecompiled=true -Dcom.sun.management.jmxremote.port=47216 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=$HOST"
PLAY_STOP="${PLAY} stop ${APPLICATION_PATH}"
PLAY_LOG=/var/log/ishop/play.log

# Path to the JVM
JAVA_HOME=/usr/lib/jvm/java-6-openjdk
export JAVA_HOME

# User running the Play process
USER=imis

CMD_START="sudo -u $USER -- $PLAY_RUN"
CMD_STOP="sudo -u $USER -- $PLAY_STOP"

if [ "`whoami`" = $USER ]
then
	CMD_START="$PLAY_RUN"
	CMD_STOP="$PLAY_STOP"
fi

# source function library
#. /etc/init.d/functions
. /lib/lsb/init-functions
RETVAL=0

start() {
	echo -n "Starting Play service: "
	echo $CMD_START 
	cd $APPLICATION_PATH
	${CMD_START} >$PLAY_LOG 2>&1 &
	RETVAL=$?

	# You may want to start more applications as follows
	# [ $RETVAL -eq 0 ] && su $USER -c "${PLAY} start application2"
	    # RETVAL=$?

	if [ $RETVAL -eq 0 ]; then
		echo success
	else
		echo failure
	fi
	echo
}

stop() {
	echo -n "Shutting down Play service: "
	echo $CMD_STOP 
	$CMD_STOP

	RETVAL=$?

	if [ $RETVAL -eq 0 ]; then
		echo success
	else
		echo failure
	fi
	echo
}

status() {
${PLAY} status ${APPLICATION_PATH}
RETVAL=$?
}
clean() {
        rm -f ${APPLICATION_PATH}/server.pid
        #rm -f application2/service.pid
}
case "$1" in
start)
clean
start
;;
stop)
stop
;;
restart|reload)
stop
sleep 10
start
;;
status)
status
;;
clean)
clean
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
esac
exit 0


