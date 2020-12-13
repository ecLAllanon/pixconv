#!/bin/bash

check_cam () {
 logfile=/var/log/ping.log

 if [ "$1" ]
 then
  ip_address1=$1
  echo $ip_address1 > $logfile
 fi

 /usr/bin/date > $logfile
 echo 'Check cameras started!' > $logfile

 while true; do # объявляем бесконечный цикл

  if ping -q -c 1 -n $ip_address1 > $logfile # проверяем пингуется ли камера
  then
   while ping -q -c 1 -n $ip_address1 > /dev/null # если пингуется, - ждем пока перестанет пинговаться
    do
    #echo $ip_address1 > $logfile
    sleep 5
    done
  fi

  #echo $ip_address1 > $logfile
  /usr/bin/date > $logfile
  echo 'We are OFFLINE' > $logfile

  while ! ping -q -c 1 -n $ip_address1 > /dev/null # ждем когда появится пинг от камеры
  do
   sleep 1
   #echo $ip_address1 > $logfile
  done

  /usr/bin/date > $logfile
  echo 'New state: online, restarting services...' > $logfile
  systemctl stop nginx # когда появился пинг от камеры - перезапускаем nginx, убиваем ffmpeg
  sleep 120
  killall -INT ffmpeg
  sleep 1
  killall ffmpeg
  sleep 1
  systemctl start nginx
  echo 'Service restarting done! We are online and working.' > $logfile

 done
}

check_cam cam.org.ua

exit 0
