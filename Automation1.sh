#!/bin/bash
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="Kumar_Naveen"
s3_bucket="upgradkumarnaveen"

sudo apt update

sudo apt install apache2 -y

servstat=$(service apache2 status)

if [[ $servstat == *"active (running)"* ]]; then
  echo "process is running"
else echo "process is not running"
fi

cd /var/log/apache2/
tar -cvf $myname-httpd-logs-$timestamp.tar *.log
mv *.tar /tmp

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
