#!/bin/bash

check_cam () {

 if [ "$1" ]
 then
  ip_address1=$1
  echo $ip_address1
 fi

counts=0 # делать рестарт после указанного числа проверок, 0=всегда

while true; do # объявляем бесконечный цикл

 if ping -q -c 1 -n $ip_address1 # проверяем пингуется ли камера
  then

  /usr/bin/date
  echo 'New state: online'

  while ping -q -c 1 -n $ip_address1 > /dev/null # если пингуется, - ждем пока перестанет пинговаться
   do
   #echo $ip_address1
   #echo 'online'
   sleep 5
   done

 fi

  #echo $ip_address1
  /usr/bin/date
  echo 'We are OFFLINE!'
  count=1

  while ! ping -q -c 1 -n $ip_address1 > /dev/null # ждем когда появится пинг от камеры
   do
   #echo $ip_address1
   #echo 'offline'
   count=$(( $count + 1 ))
   done

 if [ "$count" -gt "$counts" ]
  then

  systemctl stop nginx # когда появился пинг от камеры - перезапускаем nginx, убиваем ffmpeg
  echo '------service nginx stop-----'
  killall -INT ffmpeg
  killall ffmpeg
  systemctl start nginx
  echo '-----service nginx start-----'

 fi

done
}

check_cam 192.168.1.50

exit 0
