#!/bin/sh
### BEGIN INIT INFO
# Provides:          cloudsql
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Google Cloud SQL Proxy
### END INIT INFO

SCRIPT=/opt/cloudsql/cloud_sql_proxy
RUNAS=root
CLOUDSQL_HOME=/opt/cloudsql/cloud_sql_proxy
CLOUDSQL_CONFIG_DIR=/etc/cloudsql/
CLOUDSQL_CONFIG=$CLOUDSQL_CONFIG_DIR/cloudsql.conf

# Load application config
. $CLOUDSQL_CONFIG

if [ -z "$INSTANCE_URI" ]; then
  OPTIONS="-instances=$INSTANCE_URI $ADDITIONAL_OPTIONS"
else
  OPTIONS="-instances=$INSTANCE_ID=tcp:$DB_PORT $ADDITIONAL_OPTIONS"
fi

PIDFILE=/var/run/cloudsql.pid
LOGFILE=/var/log/cloudsql.log

start() {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'CloudSQL Proxy Service is already running' >&2
    return 1
  fi
  echo 'Starting CloudSQL Proxy Service' >&2
  local CMD="$SCRIPT $OPTIONS &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD" $RUNAS > "$PIDFILE"
  echo 'CloudSQL Proxy Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'CloudSQL Proxy Service is not running' >&2
    return 1
  fi
  echo 'Stopping CloudSQL Proxy Service' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'CloudSQL Proxy Service stopped' >&2
}

uninstall() {
  echo -n "This will uninstall the CloudSQL Proxy Service? Proceed. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    update-rc.d -f cloudsql remove
    rm -fv "$0"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|uninstall}"
esac