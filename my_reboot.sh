#!/bin/bash
#
#A script to reboot Linux after all users have logged out of their accounts.

#### Helper Functions
function command_line_args {
	while [ "$1" != "" ]
	do
		case $1 in
			#TODO ADD OPTIONS
		esac
		shift
	done
}

function reset_giveup {
	#Days go from 1 to 366. Goal is to jump 7 days forward.
	CURRENT_DATE=$(date +%j)
	CURRENT_DATE+=6
	GIVEUP=$(($CURRENT_DATE % 365))
	#Keeps the value from being 0
	GIVEUP+=1
}

function student_or_staff {
	
	#Checks for important users
	if (( $USERCHECK > 999999 ))
	then
		echo "There is an important user on the system"
	else
		echo "There is a student on the system"
	fi
}



#See if any important users are loged on. Sort works from lowest to highest. Looking for high ID numbers.
USERCHECK=$(id -u | sort -n | tail -n 1)
NUMBERUSERS=$(id -u | sort -n | wc -l) 

#Set the giveup time to be 7 days later 
GIVEUP=1
reset_giveup

echo "The number of users logged on: " $NUMBERUSERS

#If the variable is null, no users are logged on
if [[ "$USERCHECK" == "" ]]
then
	command_line_args

	#Handle the arguments

	reboot now
	exit
else
	student_or_staff
fi

PREV_USER=$USERCHECK

#Updates every hour to see if there is a user on. 
while [ -n "$(who)" ]
do
	USERCHECK=$(id -u | sort -n | tail -n 1)

	if [[ "$PREV_USER" -ne "$USERCHECK" ]]
	then
		#The same user has to be on for 7 days
		reset_giveup
		student_or_staff
		PREV_USER=$USERCHECK
	fi
	
	
	if (( "$(date +%j)" != "$GIVEUP" ))
	then
		#CHANGE TO 3600 after testing, which is 1 hour.
		sleep 10
	else
		#TODO send an email to alert an admin to kick off the user.
		exit
	fi
done

command_line_args

#Handle the arguments

reboot now
