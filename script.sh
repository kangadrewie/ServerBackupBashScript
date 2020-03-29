#! /bin/bash

HEIGHT=15
WIDTH=40
BACKTITLE="Version Control and Audit 1.0 by Andrew Gorman"

#Backup new changes of directory
backup() {
	#dt=`date '+%d-%m-%Y_%H:%M:%S'`
	#zip -r /home/ubuntu/backups/$dt.zip /var/www/html/Live
	
	TITLE="Backup Options"
	MENU="Choose one of the following options:"
	CHOICE_HEIGHT=4
		
	OPTIONS=(1 "Backup Directory Location"
		 2 "Backup Status"
		 3 "Backup Timer"
		 )	

	CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

	case $CHOICE in
		
		1)
			INPUT=$(\dialog --title "Backup Directory" \
         			    --inputbox "Enter the directory name:" 8 40 \
  				    3>&1 1>&2 2>&3 3>&- \
			)
			
			INPUT=$(sed 's|/|\\/|g' <<< $INPUT)

			sed -i "s/^BACKUP_PATH.*/BACKUP_PATH=${INPUT}/" /home/ubuntu/backup.sh
			#sed -i "s/^BACKUP_PATH.*/BACKUP_PATH=${INPUT}/" /home/ubuntu/backup.sh
			#sed -i 's/^BACKUP_PATH.*/BACKUP_PATH="\/var\/www\/html\/Live"/' /home/ubuntu/backup.sh
			;;
		2)
			backup
			;;
		3)
			apacheStatus
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
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

	clear

	case $CHOICE in
		1)
			#Generate Full Audit Report to text file
			sudo ausearch -f /var/www/html/Intranet/ > /home/ubuntu/AuditLog.txt
			;;
		2)
			#Generate Summary Report
			sudo ausearch -f /var/www/html/Intranet > /home/ubuntu/SummaryReport.txt| aureport -f -i

			dialog --programbox 50 80 | sudo ausearch -f /var/www/html/Intranet > /home/ubuntu/SummaryReport.txt| aureport -f -i
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

apacheStatus() {
	dialog --infobox "$(sudo systemctl status apache2)" 50 80
	gui
}

healthReport() {
	sudo htop
	gui
}


#Simple GUI
gui() {
	
	TITLE="Main Menu"
	MENU="Choose one of the following options:"
	CHOICE_HEIGHT=4
		
	OPTIONS=(1 "Audit Logging"
		 2 "Backup"
		 3 "Apache Status"
		 4 "Server Processes"
		 5 "Push Changes")	

	CHOICE=$(dialog --clear \
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
			healthReport
			;;
		5)
			pushChanges
			;;
	esac
 
}

gui

