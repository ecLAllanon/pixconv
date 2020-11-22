#!/bin/bash
# -vf "scale=1080:-1"
# -vf scale=-1:'min(720\,ih)':force_original_aspect_ratio=decrease
# -vf scale='min(1080\,iw)':-1
# -vf scale='trunc(min(1,min(1280/iw,720/ih))*iw/2)*2':'trunc(min(1,min(1280/iw,720/ih))*ih/2)*2':force_original_aspect_ratio=decrease
# -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2'

for dir in ./*
do
  test -d "$dir" || continue
  cd "$dir"
  echo "========= PROCESSING $dir =============="
  pwd

# Remove empty files
find . -size 0 -print -delete

# Remove date from start of file name
find . -name '[[:digit:]]*' -type f -exec rename 's:^(.*/)\d+-\d+([^/]*)\z:\1\2:s' {} + 2> /dev/null
rename -- 's/^-//' *
rename -- 's/^-//' *

# Remove spaces from filename
for f in *; do mv "$f" $(echo $f | sed -e 's/[^A-Za-z0-9._-]/-/g') 2> /dev/null; done

# Get creation date and add it to filename
for i in $(find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|mpeg|wmv|vro)$" -not -empty -printf "%f\n"); do
    mydate="$(exiftool -S -n -time:FileModifyDate -d %Y-%m-%d $i | cut -d' ' -f2 | cut -d':' -f1,2 --output-delimiter='-')"
    if [ "$mydate" ]; then
        mv -f $i "$mydate-$i"
    fi
done

# Convert videos
mkdir res
find . -maxdepth 1 -type f -iname '*.mp4' -not -empty |
    parallel -j14 "ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac 'res/{.}.mp4' || exit 1 && rm '{}'"
mv -f res/* ./
rm -rf res
find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|mpeg|wmv|vro)$" -not -empty |
    parallel -j14 "ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' || exit 1 && rm '{}'"

# Rescale pix
mv -f *.jpeg *.jpg
mv -f *.JPEG *.jpg
mkdir -p pix
find . -maxdepth 1 -type f -iname '*.jpg' -not -empty |
    parallel -j14 "ffmpeg -y -i '{}' -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'pix/{.}.jpg' || exit 1 && rm '{}'"

# If we dont have pix - delete dir
cd pix
if [ "$(ls -A '.')" ]; then
  cd ..
else
  echo "=========> No pixz! <=========="
  cd ..
  rm -rf ./pix
fi

# If we have some videos - make dir for pixz
if [ "$(ls -A '.' | grep -v pix)" ]; then
  rm -f ./*.AAE
  rm -f ./*.SRT
  rm -f ./*.THM
  rm -f ./*.BUP
  rm -f ./*.IFO
else
  echo "=========> No videos, pix will not move! <=========="
  mv -f ./pix/* .
  rm -rf ./pix
fi

  cd ..
done

