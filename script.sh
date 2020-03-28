#! /bin/bash

HEIGHT=15
WIDTH=40
BACKTITLE="Version Control and Audit 1.0 by Andrew Gorman"

#Backup new changes of directory
backup() {
	dt=`date '+%d-%m-%Y_%H:%M:%S'`
	zip -r /home/ubuntu/backups/$dt.zip /var/www/html
}

#backup
#Ensure users are unable to write while backup is happening
#chmodLock() {


#}

#Define when backup takes place
#timer() {


#}

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
			;;
		3)
			#Search Users Audit Report
			user_input=$(\dialog --title "Create Directory" \
         			    --inputbox "Enter the directory name:" 8 40 \
  				    3>&1 1>&2 2>&3 3>&- \
			)

			mkdir "$user_input"
			sudo ausearch -f /var/www/html/Intranet/ | aureport -f -i | grep $user_input
			
			;;
	esac 
}

#Push any new changes to live site
#pushChanges() {



#}


#Simple GUI
gui() {
	
	TITLE="Main Menu"
	MENU=="Choose one of the following options:"
	CHOICE_HEIGHT=4
		
	OPTIONS=(1 "Audit Logging"
		 2 "Backup"
		 3 "Backup Timer"
		 4 "Push Changes")	

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
			pushChanges
			;;
	esac
 
}

gui











