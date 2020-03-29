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
				--cancel-label "Go Back" \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 > /dev/tty)

	EXIT=$?

	case $EXIT in
		$DIALOG_CANCEL)
			gui
			;;
	esac 

	case $CHOICE in
		
		#Change directory location of Backup
		1)
			INPUT=$(\dialog --title "Backup Directory" \
		          			    --inputbox "Enter the directory name:" 8 40 \
							   				    3>&1 1>&2 2>&3 3>&- \
											 			)	
			NON_ESCAPED_INPUT=$INPUT
			INPUT=$(sed 's|/|\\/|g' <<< $INPUT)
			sed -i "s/^BACKUP_PATH.*/BACKUP_PATH=${INPUT}/" /home/ubuntu/backup.sh

			dialog --msgbox "Backup Directory has been changed to ${NON_ESCAPED_INPUT}. This will take affect when backup runs again." 15 40
			gui
			;;
		
		#Check Backup status
		2)
			
			;;

		#Change time of backup
		3)
			
			;;

		4)
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
				--cancel-label "Go Back" \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
				
				EXIT=$?
				
				case $EXIT in
					$DIALOG_CANCEL)
						gui
						;;
				esac

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
         			    --inputbox "Enter Username:" 8 40 \
  				    3>&1 1>&2 2>&3 3>&- \
			)

			mkdir "$INPUT"
			sudo ausearch -f /var/www/html/Intranet/ | aureport -f -i | grep $INPUT > /home/ubuntu/UserReport.txt
			dialog --cr-wrap \
			       --textbox /home/ubuntu/UserReport.txt 50 80
			gui	
			;;
	esac 
}

#Push any new changes to live site
#pushChanges() {



#}

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
	esac
 
}

gui
