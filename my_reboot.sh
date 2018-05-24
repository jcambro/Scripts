#!/bin/bash
#
#A script to reboot Linux after all users have logged out of their accounts.
#IDEA: run with nohup &

#### Helper Function
function command_line_args {
	while [ "$1" != "" ]
	do
		case $1 in
			#TODO ADD OPTIONS
		esac
		shift
	done
}


#See if any important users are loged on. Sort works from lowest to highest. Looking for high ID numbers.
USERCHECK=$(id -u | sort -n | tail -n 1)
NUMBERUSERS=$(id -u | sort -n | wc -l) 

#Set the giveup time to be 7 days later. can tweak this. Days go up to 366 but start at 1. 
GIVEUP=$(date +%j)
GIVEUP+=6
GIVEUP=GIVEUP%365
#Keeps the value from ever being 0.
GIVEUP+=1

echo "The number of users logged on: " $NUMBERUSERS

#If the variable is null, no users are logged on
if [[ "$USERCHECK" == "" ]]
then
	command_line_args

	#Handle the arguments

	reboot now
	exit

#Checks for an important user.   NEED TO UPDATE THE NUMBER
elif (( $USERCHECK > 999999 ))
then
	echo "There is someone with credentials logged into this system"
else
	echo "A student is logged in"
fi

#Updates every hour to see if there is a user on. 
while[ -n "$(who)" ]
do
	if[ "$(date +%j)" != "$GIVEUP" ]
	then
		#CHANGE TO 3600 after testing, which is 1 hour.
		sleep 10
	else
		#send an email to alert an admin to kick off the user.
		exit
	fi
done

reboot now
