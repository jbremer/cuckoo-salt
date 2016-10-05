#!/bin/bash
### BEGIN INIT INFO
# Provides:             Cuckoo 
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:         
# Short-Description:    Cuckoo
### END INIT INFO

case "$1" in
  start)
    su - cuckoo -c "cd /srv/cuckoo/ && screen -c /srv/cuckoo/screenconf/api.conf -dmLS api nice -n -15 ./utils/api.py -H 0.0.0.0 -p 8090"
    su - cuckoo -c "cd /srv/cuckoo/web/ && screen -S web -d -m python manage.py runserver 0.0.0.0:8080"
    su - root -c "cd /srv/cuckoo/utils/ && screen -S rooter -d -m python rooter.py"
    su - cuckoo -c "cd /srv/cuckoo/ && screen -S cuckoo -d -m ./cuckoo.py -d"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_1 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_2 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_3 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_4 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_5 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_6 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_7 nice -n -15 ./process2.py -d auto"
    su - cuckoo -c "cd /srv/cuckoo/utils && screen -c /srv/cuckoo/screenconf/process.conf -dmLS process2_8 nice -n -15 ./process2.py -d auto"
;;
  stop)
    pkill -f "SCREEN -S web -d -m python manage.py runserver 127.0.0.1:8080"
    pkill -f "SCREEN -S rooter -d -m python rooter.py"
    pkill -f "SCREEN -S cuckoo -d -m ./cuckoo.py -d"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_1 nice -n -15 ./process2.py -d auto"  
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_2 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_3 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_4 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_5 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_6 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_7 nice -n -15 ./process2.py -d auto"
    pkill -f "SCREEN -c /srv/cuckoo/screenconf/process.conf -dmLS process2_8 nice -n -15 ./process2.py -d auto"
;;

 restart)
   $0 stop
   sleep 30
   $0 start
   ;;

esac
exit 0

