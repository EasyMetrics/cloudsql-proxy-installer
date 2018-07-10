#!/bin/bash

CLOUDSQL_HOME=/opt/cloudsql

echo "Fetching latest Cloud SQL Proxy binary...." 

mkdir -p $CLOUDSQL_HOME

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O $CLOUDSQL_HOME/cloud_sql_proxy

chmod +x $CLOUDSQL_HOME/cloud_sql_proxy

echo "Installing init.d script and default configuration file."

cp scripts/etc/init.d/cloudsql.sh /etc/init.d/cloudsql
chmod +x /etc/init.d/cloudsql
mkdir -p /etc/cloudsql/

if [ -f /etc/cloudsql/cloudsql.conf ]
then
    cp scripts/etc/cloudsql/cloudsql.conf /etc/cloudsql/cloudsql.conf.dist
    echo "CloudSQL Config file alredy exists."
    echo "Copying latest config to /etc/cloudsql/cloudsql.conf.latest"
else
    cp scripts/etc/cloudsql/cloudsql.conf /etc/cloudsql/cloudsql.conf
fi

update-rc.d cloudsql defaults

echo <<EOD
Google Cloud SQL Proxy installed to $CLOUDSQL_HOME.

Google Cloud SQL Proxy init.d service:
    START:	    service cloudsql start
    STOP:		service cloudsql stop
    UNINSTALL:	service cloudsql uninstall

Google Cloud SQL Proxy Log output: 
    /var/log/cloudsql.log
EOD