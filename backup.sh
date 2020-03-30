#! /bin/bash

BACKUP_PATH=/var/www/html/Live

#Change permissions for Live Folder
sudo chmod 000 $BACKUP_PATH

#Zip the live folder with the current time and date to backup folder
dt=`date '+%d-%m-%Y_%H:%M:%S'`
zip -r /home/ubuntu/backups/$dt.zip $BACKUP_PATH

#Add Date to Backup History Log
date >> /home/ubuntu/BackupLog.txt
echo "" >> /home/ubuntu/BackupLog.txt

#Change Permissions for Intranet Folder
sudo chmod 000 /var/www/html/Intranet

#Copy new or modified files to live folder
sudo cp -u -r /var/www/html/Intranet/. $BACKUP_PATH

#Change permissions back to Intranet Folder to read and write
sudo chmod 0666 /var/www/html/Intranet
#Change Permission back to Live Folder to read only
sudo chmod 0444 $BACKUP_PATH


#Generate Health Report
sudo mkdir /home/ubuntu/HealthReports/
sudo chmod 744 /home/ubuntu/HealthReports/
sudo vmstat -t 3 5 > /home/ubuntu/HealthReports/$dt.txt 
