#!/bin/bash
#
#A script to reboot Linux after all users have logged out of their accounts.
#
# John Ambrose (jcambro@umich.edu)  5-31-18


function student_or_staff {
	USERNUMBER=$(id -u $USERCHECK)
	
	#Checks for important users
	if (( $USERNUMBER > 999999 ))
	then
		echo "There is an important user on the system"
	else
		echo "There is a student on the system"
	fi
}




#find username of a user logged on.
USERCHECK=$(who | head -n 1 | awk '{print $1}')

#If the variable is null, no users are logged on
if [[ "$USERCHECK" == "" ]]
then
	reboot 
	exit
else
	student_or_staff
fi

PREV_USER=$USERCHECK

#Updates every hour to see if there is a user on. 
while [ -n "$(who)" ]
do
	USERCHECK=$(who | awk '{print $1}')

	if [[ "$PREV_USER" -ne "$USERCHECK" ]]
	then
		#Check if the person who logged on is important.
		student_or_staff
		PREV_USER=$USERCHECK
	fi

	#Find the user with the least time on. The sort command was tweaked for the date format yyyy-mm-dd hh:mm
	LOGIN_TIME=$(who | sort -k 3 -k 4 | tail -n 1 |awk '{print $3,$4}')
	
	#Saves the amount of time in minutes the shortest user has been on for.
	TIME_ON=$((($(( $(date +%s) - $(date -d "$LOGIN_TIME" +%s)))/60)))
	
	#There are 10080 minutes in 7 days.
	if (( $TIME_ON < 10080 ))
	then
		#CHANGE TO 3600 after testing, which is 1 hour.
		sleep 10
	else
		#boot the users. 
		zenity --warning --text "The system will forcibly remove all users and reboot in 10 minutes,\nPlease save all work."
		sleep 600

		reboot 
		exit
	fi
done

reboot
