#/bin/bash

# Rename pix into simple digits
a=100
for i in *.jpg; do
  new=$(printf "%004d.jpg" "$a") #04 pad to length of 4
  mv -i -- "$i" "$new"
  let a=a+1
done