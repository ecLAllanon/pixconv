#!/bin/bash
# -vf "scale=1080:-1"
# -vf scale=-1:'min(720\,ih)':force_original_aspect_ratio=decrease
# -vf scale='min(1080\,iw)':-1
# -vf scale='trunc(min(1,min(1280/iw,720/ih))*iw/2)*2':'trunc(min(1,min(1280/iw,720/ih))*ih/2)*2':force_original_aspect_ratio=decrease
# -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2'

# Remove empty files
find . -size 0 -print -delete

# Remove all dangerous chars from filename
rename -- 's/[^A-Za-z0-9._-]//g' *
rename -f -- 's/[^A-Za-z0-9._-]/-/g' *

# Rescale pix
find . -maxdepth 1 -type f -iname '*.flv' -not -empty |
    parallel -j14 "ffmpeg -y -i '{}' -vcodec libx264 -acodec aac -ar 44100 -f mp4 '{.}.mp4' || exit 1 && touch -r '{}' '{.}.mp4' && rm '{}'"

