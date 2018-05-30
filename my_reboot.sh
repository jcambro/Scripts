#!/bin/bash
#
#A script to reboot Linux after all users have logged out of their accounts.

#### Helper Function
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


#### Main Body

#See if any important users are loged on. Sort works from lowest to highest. Looking for high ID numbers.
#USERCHECK=$(id -u | sort -n | tail -n 1)
USERCHECK=$(who | awk '{print $1}')

#If the variable is null, no users are logged on
if [[ "$USERCHECK" == "" ]]
then
	reboot now
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

	#Find the user with the least time on
	LOGIN_TIME=$(who | sort -k 3.3,3.4 -k 3.6,3.7 -k 3.9,3.10 -k 4.1,4.2 -k 4.4,4.5 | head -n 1 |awk '{print $3,$4}')
	
	TIME_ON=$($(($(($(date +%s) - $(date -d "$LOGIN_TIME" +%s)))/60)))
	
	#There are 10080 minutes in 7 days.
	if (( $TIME_ON < 10080 ))
	then
		#CHANGE TO 3600 after testing, which is 1 hour.
		sleep 10
	else
		reboot now
		exit
	fi
done

reboot now
