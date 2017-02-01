#!/bin/bash

# ./socatchk remote-host remote-port
# crudely shutsdown socat (if running) and then restarts it for new host/port
orport=9150
orlisadr=127.0.0.1

case $1 in
-k|--kill)
for i in $(ls /tmp/soxify*.pid);do
  echo 'Killing pid...'
  kill -15 $(cat $i)
done
;;

-K|--killall)
[ "$(pidof socat >/dev/null 2>&1 && echo $?)" = 0 ] && kill $(pidof socat); [ "$(pidof socat && echo $?)" != 0 ]
;;

-c|--connect)
socat TCP4-LISTEN:$2,fork SOCKS4A:$orlisadr:$3:$4,socksport=$orport & echo "$!" >/tmp/"soxify.$!.pid"
;;

-h|--help)
echo "Usage: $0 -c <local port> <onion addr> <port> -- connect"
echo "       $0 -k -- kill all socat instances started by this script"
echo "       $0 -K -- kill all socat systemwide"
echo "       $0 -h -- show this usage"
;;

*)
echo "Invalid. -h or --help for Usage"
;;
esac
exit
