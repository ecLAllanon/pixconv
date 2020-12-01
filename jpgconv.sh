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
  cd pix
  pwd

# Remove spaces from filename
for f in *\ *; do mv "$f" "${f// /-}"; done

# Rescale pix
mkdir res
find . -maxdepth 1 -type f -iname '*.jpg' -not -empty |
    parallel -j14 "ffmpeg -y -i '{}' -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'res/{.}.jpg' || exit 1 && touch -r '{}' 'res/{.}.jpg' && rm '{}'"
mv -f res/* ./
rm -rf res

  cd ../..
done

