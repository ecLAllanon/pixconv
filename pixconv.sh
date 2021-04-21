#!/bin/bash
# -vf "scale=1080:-1"
# -vf scale=-1:'min(720\,ih)':force_original_aspect_ratio=decrease
# -vf scale='min(1080\,iw)':-1
# -vf scale='trunc(min(1,min(1280/iw,720/ih))*iw/2)*2':'trunc(min(1,min(1280/iw,720/ih))*ih/2)*2':force_original_aspect_ratio=decrease
# -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2'
# ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' || exit 1 && rm '{}'

######### Config:

put_year_to_filename=0  # 0 or 1
put_date_to_filename=1  # 0 or 1

#################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# cd /www/commandor/travels/.incoming

AUTO=0
if [ -n "$1" ] && [ "$1" = "auto" ]; then
	AUTO=1
fi

OIFS="$IFS"
IFS=$'\n'
incoming_dir=$(pwd)
# for dir in `find ./* -type d -print | grep -v pix | sort -r`; do
for dir in `find . -type d -print | grep -vx pix | sort -r`; do
	cd "$incoming_dir"
	echo -e "\n${RED}========= PROCESSING $dir =========${NC}\n"
	cd "$dir"

	# Extract all archives
	rename -- 's/[^A-Za-z0-9._-]//g' "*.zip" 2> /dev/null
	rename -f -- 's/[^A-Za-z0-9._-]/_/g' "*.zip" 2> /dev/null
	rename -- 's/[^A-Za-z0-9._-]//g' "*.rar" 2> /dev/null
	rename -f -- 's/[^A-Za-z0-9._-]/_/g' "*.rar" 2> /dev/null
	find . -maxdepth 1 -type f -name "*.rar" -exec unrar x -o- -p- {} \;
	find . -maxdepth 1 -type f -name "*.zip" -exec unzip -n {} \;
	rm -f *.rar 2> /dev/null
	rm -f *.zip 2> /dev/null

	# Remove empty files
	find . -maxdepth 1 -size 0 -print -delete
	find . -type f -iname '*thumb*' -print -delete
	rm -f ./*.part
	rm -f ./*.torrent
	rm -f ./*.db
	rm -f ./*.cbz
	rm -f ./*.swf
	rm -f ./*.srt
	rm -f ./*.txt

	echo -e "=== ${GREEN}Renaming...${NC}"

	/usr/local/bin/cyr2lat.sh *

	# Remove all dangerous chars from filename
	for i in $(find . -maxdepth 1 -print0 | perl -n0e 'chomp; print $_, "\n" if /[[:^ascii:][:cntrl:]]/'); do
		rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)" 2> /dev/null
	done

	#for i in $(find . -maxdepth 1 -regex '.*[^ -~].*' -print); do
#	for i in $(find . -maxdepth 1 -print); do
#		rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)" 2> /dev/null
#	done

	# Remove leftovers with control chars
	for i in $(find . -maxdepth 1 -regex '.*[^ -~].*' -print); do
		rename -f -- 's/[^A-Za-z0-9._]/'$(printf %.3s $(echo $RANDOM))'/g' "$(basename $i)" 2> /dev/null
	done

	# Replace mass underlines
	find . -type f -name "*___*" -exec bash -c 'f="$(basename $1)"; g="$(printf %.3s $(echo $RANDOM))_${f/*__/}"; mv -- "$f" "$g" 2> /dev/null' _ '{}' \;

	# Remove date from start of file name
	find . -maxdepth 1 -name '[[:digit:]]*' -type f -exec rename 's:^(.*/)\d+-\d+([^/]*)\z:$1$2:s' {} + 2> /dev/null
	find . -maxdepth 1 -name '[[:digit:]]*' -type f -exec rename 's:^(.*/)\d+-([^/]*)\z:$1$2:s' {} + 2> /dev/null
	rename -f -- 's/^-+//' *

	# Rename other file formats
	rename 's/\.bc!$/\.mpg/i' * 2> /dev/null
	rename 's/\.dat$/\.mpg/i' * 2> /dev/null
	rename 's/\.vob$/\.mpg/i' * 2> /dev/null
	rename 's/\.asf$/\.mpg/i' * 2> /dev/null
	rename 's/\.3gp$/\.mpg/i' * 2> /dev/null
	rename 's/\.m4v$/\.mpg/i' * 2> /dev/null
	rename 's/\.f4v$/\.flv/i' * 2> /dev/null
	rename 's/\.divx$/\.mpg/i' * 2> /dev/null
	rename 's/\.mpeg$/\.mpg/i' * 2> /dev/null
	rename 's/\.mpe$/\.mpg/i' * 2> /dev/null
	rename 's/\.rmvb$/\.mov/i' * 2> /dev/null
	rename 's/\.rm$/\.mov/i' * 2> /dev/null
	rename 's/\.png$/\.jpg/i' * 2> /dev/null
	rename 's/\.bmp$/\.jpg/i' * 2> /dev/null
	rename -f 's/\.jpe?g$/.jpg/i' * 2> /dev/null

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

	    if [ ! -z "$mydate" ]; then
	        mv -f "$i" "$mydate-$i"
	    fi
	done
	
	echo -e "=== ${GREEN}Convering...${NC}"

	# Convert videos
	mkdir -p res
	find . -maxdepth 1 -type f -iname '*.mp4' -not -empty |
	    parallel -j15 "echo -e 'processing {}' && ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac 'res/{.}.mp4' 2> /dev/null && touch -r '{}' 'res/{.}.mp4' && rm '{}' || (rm '{}' && exit 1)"
	mv -f res/* ./ 2> /dev/null
	rm -rf res
	find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|wmv|flv|mkv|vro)$" -not -empty |
	    parallel -j15 "echo -e 'processing {}' && ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' 2> /dev/null && touch -r '{}' '{.}.mp4' && rm '{}' || (rm '{}' && exit 1)"

	# Rescale and autorotate pix
	mkdir -p pix
	echo -e "\n=== Autorotating and rescaling images..."
    #parallel -j15 "exiftool -S -Orientation=1 -n -overwrite_original '{}' ; ffmpeg -y -i '{}' -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'pix/{.}.jpg' && touch -r '{}' 'pix/{.}.jpg' && rm '{}' || (rm '{}' && exit 1)"
	find . -maxdepth 1 -type f -iname '*.jpg' -not -empty |
	    parallel -j15 "exiftran -aip '{}' ; ffmpeg -y -i '{}' -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'pix/{.}.jpg' 2> /dev/null && touch -r '{}' 'pix/{.}.jpg' && rm '{}' || (rm '{}' && exit 1)"

	# If we dont have pix - delete dir
	cd pix
	if [ ! -z "$(ls -A '.')" ]; then
	  cd ..
	else
	  # No pixez found here
	  echo -e '!!! No pixz here'
	  cd ..
	  rm -rf pix
	fi

	#echo -e '\n!!! Press any key !!!\n'
	#read line

	# If we have some videos - make dir for pixz
	if [ ! -z "$(ls -A ./*.mp4 2> /dev/null | grep -vx pix 2> /dev/null)" ]; then
	  rm -f ./*.AAE
	  rm -f ./*.SRT
	  rm -f ./*.THM
	  rm -f ./*.BUP
	  rm -f ./*.IFO
	else
	  # No videos found here
	  echo -e '!!! No videos here'
	  mv -f ./pix/* ./ 2> /dev/null
	  rm -rf pix
	fi


	# Move dirs with few files to ..
#	for i in $(find . -maxdepth 1 -type d -exec bash -c "echo -ne '{}\t'; ls '{}' | wc -l" \; | awk -F"\t" '$NF<=20{print $1}'); do
#		mv ./$i/* ./
#	done

	# Shorten filenames
	for i in $(find . -maxdepth 1 -type d -print); do
		rename 's/^(.{20}).*/$1.'$(printf %.2s $(echo $RANDOM))'/' "$(basename $i)"
	done

	# Truncate from start of filename
	rename 's/.*(.{50}).*(\..*)$/$1$2/' *
	# Truncate from end of filename
	# rename 's/^(.{50}).*(\..*)$/$1$2/' *
    
	# Cleanup empties
	#echo -e "=== Deleting empty:"
	find . -maxdepth 1 -type d -empty -delete ;
	find . -maxdepth 1 -size 0 -print -delete ;

	# Rename long numeric filenames 
	for f in $(find . -maxdepth 1 -type f -regex "\./[0-9._-]*\..*" -print); do
		bfile="$(basename $f)"
		mv -n "${bfile}" "$(printf "%05d" $RANDOM).${bfile#*.}"
	done

	# Move to processed dir to main gallery
	if [ "$AUTO" -eq 1 ]; then
		cur_dir=$(pwd)
		if [ "$cur_dir" = "$incoming_dir" ]; then
			echo -e "\n=== Moving random trash to Incoming..."
		    mv -f * "$incoming_dir/../Incoming/" 2> /dev/null
		    cd "$incoming_dir/../Incoming/"
		    if [ ! -z "$(ls -A '.' | wc -l | awk -F"\t" '$NF>=50{print $1}')" ] || [ ! -z "$(ls -A '.' | wc -l | awk -F"\t" '$NF>=150{print $1}')" ]; then
				cd ..
				lastDir=$(find Incoming-* -maxdepth 0 -type d 2> /dev/null | tail -1 | cut -c 10-)
				if [ -z "$lastDir" ]; then
					echo -e "=== Incoming is overloaded, dumping trash to ${GREEN}Incoming-0001${NC}"
					mv -f Incoming Incoming-0001 2> /dev/null
				else
					lastDir=000$(( 10#$lastDir + 1 ))
					echo -e "=== Incoming is overloaded, dumping trash to ${GREEN}Incoming-${lastDir: -4}${NC}"
					mv -f Incoming "Incoming-${lastDir: -4}" 2> /dev/null
				fi
	#			mv -f Incoming "$(printf "Incoming-%05d" $RANDOM)" 2> /dev/null
				mkdir -p Incoming
		    fi
		else
			echo -e "\n=== Moving processed dir to gallery..."
		    mv -f "../$dir" "$incoming_dir/.." 2> /dev/null
		fi
	fi            
done

# Build thumbnails and dirtree.txt
cd "$incoming_dir"
if [ "$AUTO" -eq 1 ]; then
	cd "$incoming_dir/.."
fi
/usr/local/bin/build > /dev/null

#for i in {1..10}; do
	echo -e "\n${RED}========= ALL DONE =========${NC}\n"
#done
