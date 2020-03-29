#! /bin/bash

BACKUP_PATH=/var/www/html/Intranet

#Change permissions
sudo chmod 000 $BACKUP_PATH

#Zip the live folder with the current time and date to backup folder
dt=`date '+%d-%m-%Y_%H:%M:%S'`
zip -r /home/ubuntu/backups/$dt.zip $BACKUP_PATH

#Change Permissions back
sudo chmod 744 $BACKUP_PATH

echo "Successful Backup"
