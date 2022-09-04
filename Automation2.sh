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

cd /var/www/html/
if [ -f "inventory.html" ]
then
echo "File found"
else
   sudo touch inventory.html
   sudo chmod 777 inventory.html
   sudo echo $'Log Type\t\tTime Created\t\tType\t\tSize' > inventory.html
fi
sudo touch diff.html
sudo chmod 777 diff.html
sudo echo $'Log Type\t\tTime Created\t\tType\t\tSize' > diff.html
aws s3 ls s3://$s3_bucket --recursive --human-readable | awk  '{printf "\n%s %s %s", $3, $4, $5} END {print ""}' | awk -F'[-. ]' '{printf "\n%s-%s\t\t%s-%s\t\t%s\t\t%s%s", $5, $6, $7, $8, $9, $1, $3} END {print ""}' >> /var/www/html/diff.html
grep -Fxvf inventory.html diff.html >> inventory.html
sudo rm -rf diff.html

cd /etc/cron.d/
if [ -f "automation" ]
then
echo "File Found"
else
echo $'30 16 * * * root /root/Automation_Project/automation.sh' > automation
fi
