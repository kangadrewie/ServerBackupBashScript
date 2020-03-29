#! /bin/bash

HEIGHT=15
WIDTH=40
BACKTITLE="Version Control and Audit 1.0 by Andrew Gorman"

DIALOG_CANCEL=1

#Backup new changes of directory
backup() {
	
	TITLE="Backup Options"
	MENU="Choose one of the following options:"
	CHOICE_HEIGHT=4
		
	OPTIONS=(1 "Backup Directory Location"
		 2 "Backup Status"
		 3 "Backup Timer"
		 4 "Backup History"
		 )	

	CHOICE=$(dialog --clear \
				--nocancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 > /dev/tty)
 

	case $CHOICE in
		#Change directory location of Backup
		1)
			INPUT=$(\dialog --title "Backup Directory" \
							--nocancel \
		          			--inputbox "Enter the directory name:" 8 40 \
							3>&1 1>&2 2>&3 3>&-)

			NON_ESCAPED_INPUT=$INPUT
			INPUT=$(sed 's|/|\\/|g' <<< $INPUT)
			sed -i "s/^BACKUP_PATH.*/BACKUP_PATH=${INPUT}/" /home/ubuntu/backup.sh

			dialog --msgbox "Backup Directory has been changed to ${NON_ESCAPED_INPUT}. This will take affect when backup runs again." 15 40
			gui
			;;
			
		#Check Backup status
		2)
			dialog --msgbox "Backup is RUNNING for the following:\n\n$(sudo crontab -l)" 8 50
			gui
			;;

		#Change time of backup
		3)
			TIMER_INPUT=$(\dialog --title "Backup Timer" \
							--nocancel \
		          			--timebox "Enter time of day for Backup:" 5 35 15 30 00 \
							3>&1 1>&2 2>&3 3>&-)

			HOUR="$(cut -d':' -f1 <<<$TIMER_INPUT)"
			MINUTES="$(cut -d':' -f2 <<<$TIMER_INPUT)"
			
			
		 	sudo crontab -l > backupInterval
			sudo echo "${MINUTES} ${HOUR} * * * /home/ubuntu/backup.sh" > backupInterval
			
			sudo crontab backupInterval
			sudo rm backupInterval

			sudo dialog --msgbox "A daily backup has been set for ${HOUR}: ${MINUTES}." 15 45
			gui
			;;

		4)
			#History of Backups
			dialog --textbox /home/ubuntu/BackupLog.txt 50 80
			gui
			;;
 
	esac
}

#Log changes made to directory
auditLog() {

	TITLE="Audit Logging"
	MENU="Choose one of the following options:"
	CHOICE_HEIGHT=3 
	OPTIONS=(1 "Generate Full Audit"
        	 2 "Summary Report"
         	 3 "Search User Audit")

	CHOICE=$(dialog --clear \
				--nocancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
			
	case $CHOICE in
		1)
			#Generate Full Audit Report to text file
			sudo ausearch -f /var/www/html/Intranet/ > /home/ubuntu/AuditLog.txt
			dialog --textbox /home/ubuntu/AuditLog.txt 50 80
			
			
			dialog --msgbox "A .txt report is available and can be viewed on /home/ubuntu/AuditLog.txt" 8 40 
			gui
			;;
			
		2)
			#Generate Summary Report
			sudo ausearch -f /var/www/html/Intranet | aureport -f -i > /home/ubuntu/SummaryReport.txt
			dialog --textbox /home/ubuntu/SummaryReport.txt 50 80
			gui 
			;;
		3)
			#Search Users Audit Report
			INPUT=$(\dialog --title "Search User" \
         			        --cancel-label "Go Back" \
							--inputbox "Enter Username:" 8 40 \
  				            3>&1 1>&2 2>&3 3>&- \
			)

			
			mkdir "$INPUT"
			sudo ausearch -f /var/www/html/Intranet/ | aureport -f -i | grep $INPUT > /home/ubuntu/UserReport.txt
			dialog --cr-wrap \
			      	--textbox /home/ubuntu/UserReport.txt 50 80
			gui		
				
	esac 
}

#Push any new changes to live site
pushChanges() {

	dialog 	--backtitle "Manually Push Changes" \
			--yesno "Are you sure you want to push changes to /var/www/html/Live?" 7 60

	RESPONSE=$?
	case $RESPONSE in
		0)
			#Change Permissions
			sudo chmod 000 /var/www/html/Intranet
			sudo chmod 000 /var/www/html/Live
 			
			#Only copy what has been newly created or modified
			sudo cp -u -r -v /var/www/html/Intranet/. /var/www/html/Live > /home/ubuntu/Transfers.txt 
			
			#Change Permission back
			sudo chmod 733 /var/www/html/Intranet
			sudo chmod 0444  /var/www/html/Live
			
			#Display what has been pushed to Live Folder
			dialog --textbox /home/ubuntu/Transfers.txt 50 80 
			gui	
			;;
		1)
			gui
			;;

		255)
			gui
			;;
			 			
	esac

}

#Check Apache2 Status
apacheStatus() {
	dialog --msgbox "$(sudo systemctl status apache2)" 50 80
	gui
}

#Check server processes
serverProcesses() {
	sudo htop
	gui
}

#System Health Check
systemHealth() {
	#Generate System Health Log
	#sudo vmstat -t 3 5 >> /home/ubuntu/SystemHealth.txt
	dialog --infobox "Please wait a moment." 8 40

   	echo "" >> /home/ubuntu/SystemHealth.txt
	date >> /home/ubuntu/SystemHealth.txt	
	
	sudo vmstat -t 3 5 >> /home/ubuntu/SystemHealth.txt
	sleep 1
	dialog --textbox /home/ubuntu/SystemHealth.txt 50 80
	gui
}


#Simple GUI
gui() {
	
	TITLE="Main Menu"
	MENU="Choose one of the following options:"
	CHOICE_HEIGHT=6
		
	OPTIONS=(1 "Audit Logging"
		 2 "Backup"
		 3 "Apache Status"
		 4 "Server Processes"
		 5 "System Health"
		 6 "Push Changes")	

	CHOICE=$(dialog --clear \
				--cancel-label "Exit" \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

	case $CHOICE in
		
		1)
			auditLog
			;;
		2)
			backup
			;;
		3)
			apacheStatus
			;;
		4)
			serverProcesses
			;;
		5)
			systemHealth
			;;
		6)
			pushChanges
			;;
	esac
 
}

gui
