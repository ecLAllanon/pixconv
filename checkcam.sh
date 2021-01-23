#!/bin/bash

check_cam () {
 logfile=/var/log/camera.log

 if [ "$1" ]
 then
  ip_address1=$1
  echo $ip_address1 >> $logfile
 fi

 /usr/bin/date >> $logfile
 echo 'Check cameras started!' >> $logfile

 while true; do # объявляем бесконечный цикл

  if ping -q -c 1 -n $ip_address1 > /dev/null # проверяем пингуется ли камера
  then
   while ping -q -c 1 -n $ip_address1 > /dev/null # если пингуется, - ждем пока перестанет пинговаться
    do
    #echo $ip_address1 >> $logfile
    sleep 5
    done
  fi

  #echo $ip_address1 >> $logfile
  /usr/bin/date >> $logfile
  echo 'We are OFFLINE' >> $logfile

  while ! ping -q -c 1 -n $ip_address1 > /dev/null # ждем когда появится пинг от камеры
  do
   sleep 1
   #echo $ip_address1 >> $logfile
  done

  /usr/bin/date >> $logfile
  echo 'New state: online, restarting services...' >> $logfile
  systemctl stop nginx # когда появился пинг от камеры - перезапускаем nginx, убиваем ffmpeg
  sleep 1
  killall -INT ffmpeg > /dev/null
  sleep 1
  killall ffmpeg > /dev/null
  sleep 1
  systemctl start nginx
  echo 'Service restarting done! We are online and working.' >> $logfile

 done
}

if [ "$1" = "DAEMON" ]; then
	check_cam SITE
fi

export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
umask 022
nohup setsid $0 DAEMON $* &

exit 0
