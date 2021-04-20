#!/bin/bash

echo '.' > dirtree.txt
find -L * -type d >> dirtree.txt
sort -f -o dirtree.txt dirtree.txt
sed -n '/thumb/!p' dirtree.txt > temp
mv temp dirtree.txt

dir="$(pwd)"
cd /www/gallery
php thumbs.php -p "$dir"
cd "$dir"
chown -R www-data:www-data *
