#!/bin/bash
# -vf "scale=1080:-1"
# -vf scale=-1:'min(720\,ih)':force_original_aspect_ratio=decrease
# -vf scale='min(1080\,iw)':-1
# -vf scale='trunc(min(1,min(1280/iw,720/ih))*iw/2)*2':'trunc(min(1,min(1280/iw,720/ih))*ih/2)*2':force_original_aspect_ratio=decrease
# -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2'
# ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' || exit 1 && rm '{}'

######### Config:

put_year_to_filename=0  # 0 or 1
put_date_to_filename=0  # 0 or 1

#################
RED='\033[0;31m'
NC='\033[0m' # No Color

for dir in ./*
do
  test -d "$dir" || continue
  cd "$dir"
  echo -e "${RED}========= PROCESSING $dir =========${NC}"

# Remove empty files
find . -size 0 -print -delete

# Remove all dangerous chars from filename
#rename -- 's/ //g' * 2> /dev/null
#for f in *; do mv "$f" $(echo $f | sed -e 's/[^A-Za-z0-9._-]/-/g') 2> /dev/null; done
rename -- 's/[^A-Za-z0-9._-]//g' *
rename -f -- 's/[^A-Za-z0-9._-]/-/g' *

# Remove date from start of file name
find . -name '[[:digit:]]*' -type f -exec rename 's:^(.*/)\d+-\d+([^/]*)\z:\1\2:s' {} + 2> /dev/null
find . -name '[[:digit:]]*' -type f -exec rename 's:^(.*/)\d+-([^/]*)\z:\1\2:s' {} + 2> /dev/null
rename -f -- 's/^-+//' *

# Rename other file formats
rename 's/\.dat$/\.mpg/i' * 2> /dev/null
rename 's/\.vob$/\.mpg/i' * 2> /dev/null
rename 's/\.asf$/\.mpg/i' * 2> /dev/null
rename 's/\.3gp$/\.mpg/i' * 2> /dev/null
rename 's/\.m4v$/\.mpg/i' * 2> /dev/null
rename 's/\.divx$/\.mpg/i' * 2> /dev/null
rename 's/\.mpeg$/\.mpg/i' * 2> /dev/null
rename 's/\.rmvb$/\.mov/i' * 2> /dev/null
rename 's/\.rm$/\.mov/i' * 2> /dev/null

# Get creation date and add it to filename
for i in $(find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|wmv|flv|mkv|vro|mp4)$" -not -empty -printf "%f\n"); do
    if [ "$put_date_to_filename" -eq 0 ] && [ "$put_year_to_filename" -eq 0 ]; then
        # No any dates in filename
        mydate=""
    elif [ "$put_date_to_filename" -eq 0 ]; then
        # Only year in filename
        mydate="$(exiftool -S -n -time:FileModifyDate -d %Y-%m-%d $i | cut -d' ' -f2 | cut -d':' -f1 --output-delimiter='-')"
    else
        mydate="$(exiftool -S -n -time:FileModifyDate -d %Y-%m-%d $i | cut -d' ' -f2 | cut -d':' -f1,2 --output-delimiter='-')"
    fi

    if [ "$mydate" ]; then
        mv -f $i "$mydate-$i"
    fi
done

# Convert videos
mkdir -p res
find . -maxdepth 1 -type f -iname '*.mp4' -not -empty |
    parallel -j14 "ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac 'res/{.}.mp4' || exit 1 && touch -r '{}' 'res/{.}.mp4' && rm '{}' && echo '========= PROCESSING $dir =============='"
mv -f res/* ./ 2> /dev/null
rm -rf res
find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|wmv|flv|mkv|vro)$" -not -empty |
    parallel -j14 "ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' || exit 1 && touch -r '{}' '{.}.mp4' && rm '{}' && echo '========= PROCESSING $dir =============='"

# Rescale pix
rename -f 's/\.jpe?g$/.jpg/i' * 2> /dev/null
mkdir -p pix
find . -maxdepth 1 -type f -iname '*.jpg' -not -empty |
    parallel -j14 "ffmpeg -y -i '{}' -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'pix/{.}.jpg' || exit 1 && touch -r '{}' 'pix/{.}.jpg' && rm '{}'"

# If we dont have pix - delete dir
cd pix
if [ "$(ls -A '.')" ]; then
  cd ..
else
  echo -e '========= No pixz! =========='
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
  echo -e '========= No videos, pix will not move! =========='
  mv -f ./pix/* . 2> /dev/null
  rm -rf ./pix
fi

cd ..

done

echo -e "${RED}========= ALL DONE =========${NC}"

