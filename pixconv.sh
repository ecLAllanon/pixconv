#!/bin/bash
# -vf "scale=1080:-1"
# -vf scale=-1:'min(720\,ih)':force_original_aspect_ratio=decrease
# -vf scale='min(1080\,iw)':-1
# -vf scale='trunc(min(1,min(1280/iw,720/ih))*iw/2)*2':'trunc(min(1,min(1280/iw,720/ih))*ih/2)*2':force_original_aspect_ratio=decrease
# -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2'
# ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx264 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' || exit 1 && rm '{}'
# ffmpeg -y -analyzeduration 10000000 -err_detect ignore_err -i '{}' -vcodec libx265 -vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' -acodec aac -f mp4 '{.}.mp4' 2> /dev/null && touch -r '{}' '{.}.mp4' && rm '{}' || (rm '{}' && exit 1)"


######### Config:

put_year_to_filename=0  # 0 or 1
put_date_to_filename=1  # 0 or 1

#################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# cd /www/commandor/travels/.incoming

#AUTO='$1'
AUTO=''
NEED_IDX=''
#OIFS="$IFS"
IFS=$'\n'
incoming_dir=$(pwd)
start_time=$(date '+%m-%d %H:%M:%S')
rm -rf res
clear -x
# for dir in `find ./* -type d -print | grep -v pix | sort -r`; do
for dir in `find . -type d -print | grep -vx ./pix | grep -vx ./sav | sort -r`; do
	cd "$incoming_dir"
	echo -e "\n========= ${GREEN}PROCESSING${NC} --*[ ${GREEN}$dir${NC} ]*-- =========  ${GREEN}$(date '+%m-%d %H:%M:%S')${NC}\n"
	cd "$dir"
	
	if [ -z "$(ls -A '.')" ]; then
		continue
	fi

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
	rm -f ./*.log

	echo -e "=== ${GREEN}Renaming...${NC}"

	/usr/local/bin/cyr2lat.sh *

	# Remove all dangerous chars from filename
	for i in $(find . -maxdepth 1 -print0 | perl -n0e 'chomp; print $_, "\n" if /[[:^ascii:][:cntrl:]@)(]/'); do
		rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)" 2> /dev/null
	done

	#for i in $(find . -maxdepth 1 -regex '.*[^ -~].*' -print); do
#	for i in $(find . -maxdepth 1 -print); do
#		rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)" 2> /dev/null
#	done

	# Remove leftovers with control chars
	for i in $(find . -maxdepth 1 -regex '.*[^ -~@].*' -print); do
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
	rename 's/\.mts$/\.mpg/i' * 2> /dev/null
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
	for i in $(find . -maxdepth 1 -type f -regextype posix-egrep -iregex ".*\.(mov|avi|mpg|wmv|flv|mkv|vro|mp4|txt)$" -not -empty -printf "%f\n"); do
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
	
	# (time echo 'test') 2>&1 >/dev/null | grep 'real'

	echo -e "=== ${GREEN}Convering...${NC}"
	mkdir -p res

	# Convert videos
	# Codecs: libvpx-vp9 libaom-av1 libx265 libx264 ][ MP4 / MKV / WEBM

# CRF 0-51, less = better
#	    	-c:v libx264 -crf 20 -tune zerolatency -preset slow \

# CRF 0-63, less = better
#	    	-c:v libaom-av1 -crf 30 -b:v 0 -strict -2 \

# CRF 0-??, less = better
# 1. br 2000k:  -c:v libvpx-vp9 -b:v 2M -pass 1 -an \
# 2. CRF:               -c:v libvpx-vp9 -b:v 0 -crf 30 -pass 1 -an \

	find . -maxdepth 1 -type f -iname '*.mp4' -not -empty |
	   	parallel --retries 3 --nice -5 --halt soon,fail=50% --eta -j15 " \
	    	(time ffmpeg -y -i '{}' \
	    	-c:v libx264 -crf 20 -preset slow -movflags faststart \
	    	-vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' \
	    	-c:a aac -b:a 128k -ac 2 'res/{.}.mp4') 2>&1 >/dev/null 2>'{/}'.log && \
	    	touch -r '{}' 'res/{.}.mp4' && \
	    	echo -e '${GREEN}Good MP4${NC} {}' || \
	    	(echo -e '${RED}Recoding error MP4${NC} {}' && mkdir -p bad && mv -n '{}' ./bad && rm 'res/{.}.mp4' && exit 1) && rm '{}' && rm '{/}'.log"

	mv -n res/* ./ 2> /dev/null
	rm -rf res
	
	find . -maxdepth 1 -type f -regextype posix-egrep -iregex '.*\.(mov|avi|mpg|wmv|flv|mkv|vro)$' -not -empty |
	    parallel --retries 3 --nice -5 --halt soon,fail=50% --eta -j15 " \
	    	(time ffmpeg -y -i '{}' \
	    	-c:v libx264 -crf 20 -preset slow -movflags faststart \
	    	-vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' \
	    	-c:a aac -b:a 128k -ac 2 '{.}.mp4') 2>&1 >/dev/null 2>'{/}'.log && \
	    	touch -r '{}' '{.}.mp4' && \
	    	echo -e '${GREEN}Good MOV${NC} {}' || \
            (echo -e '${RED}Recoding error MOV${NC} {}' && mkdir -p bad && mv -n '{}' ./bad && rm '{.}.mp4' && exit 1) && rm '{}' && rm '{/}'.log"


	# Convert audio files
	if [ ! -z "$(ls -A '.' | grep .wma)" ]; then
		echo -e "\n=== Converting ${GREEN}audio files${NC} to MP3"
		for file in *.wma; do ffmpeg -i "${file}"  -acodec libmp3lame -ab 192k -ac 2 "${file/.wma/.mp3}"; done
		rm -f *.wma
		NEED_IDX="y"
	fi

	# Rescale and autorotate pix
	if [ ! -z "$(find . -maxdepth 1 -type f -iname '*.jpg' -not -empty)" ]; then
		mkdir -p pix
		echo -e "\n=== ${GREEN}Rotating/rescaling${NC} images"
		find . -maxdepth 1 -type f -iname '*.jpg' -not -empty |
		    parallel --eta -j15 " exiftran -aip '{}' ; ffmpeg -y -i '{}' \
	    		-vf scale='trunc(min(1\,min(1920/iw\,1920/ih))*iw/2)*2':'trunc(min(1\,min(1920/iw\,1920/ih))*ih/2)*2' 'pix/{.}.jpg' 2> /dev/null && \
	    		touch -r '{}' 'pix/{.}.jpg' || \
	    		(echo -e '${RED}Recoding error${NC} --- file {}' && exit 1) && rm '{}' "

		# If we dont have pix - delete dir
		cd pix
		if [ ! -z "$(ls -A '.')" ]; then
		  cd ..
		  NEED_IDX="y"
		else
		  # No pixez found here
		  echo -e '-- No pixz here'
		  cd ..
		  rm -rf pix
		fi
	fi

	# If we have some videos - make dir for pixz
	if [ ! -z "$(ls -A ./*.mp4 2> /dev/null | grep -vx pix 2> /dev/null)" ]; then
	  rm -f ./*.AAE
	  rm -f ./*.SRT
	  rm -f ./*.THM
	  rm -f ./*.BUP
	  rm -f ./*.IFO
	  NEED_IDX="y"
	else
	  # No videos found here
	  echo -e '-- No videos here'
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
	#find . -maxdepth 1 -type d -empty -delete ;
	#find . -maxdepth 1 -size 0 -print -delete ;

	# Rename long numeric filenames 
	#for f in $(find . -maxdepth 1 -type f -regex "\./[0-9._-]*\..*" -print); do
	#	bfile="$(basename $f)"
	#	mv -n "${bfile}" "$(printf "%05d" $RANDOM).${bfile#*.}"
	#done

	# Move to processed dir to main gallery
	cur_dir=$(basename "$PWD")
	if [ ! -z "$AUTO" ] && [ "$cur_dir" = ".incoming" ]; then
		cur_dir=$(pwd)
		if [ "$cur_dir" = "$incoming_dir" ] && [ ! -z "$(ls -A '.')" ]; then
			echo -e "\n=== ${GREEN}Moving${NC} random trash to Incoming..."
			NEED_IDX="y"
			mkdir -p "$incoming_dir/../Incoming/"
		    mv -f * "$incoming_dir/../Incoming/"
		    cd "$incoming_dir/../Incoming/"
		    if [ ! -z "$(ls -A '.' | wc -l | awk -F'\t' '$NF>=50{print $1}')" ] || [ ! -z "$(ls -A '.' | wc -l | awk -F'\t' '$NF>=150{print $1}')" ]; then
				cd ".."
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
		elif [ ! -z "$(ls -A '.')" ]; then
			echo -e "\n=== ${GREEN}Moving${NC} processed ${GREEN}$dir${NC} to gallery ... $(date '+%m-%d %H:%M:%S')"
			NEED_IDX="y"
		    mv -f "../$dir" "$incoming_dir/.." 2> /dev/null
		fi
	fi            
done

cd "$incoming_dir"

if [ ! -z "$AUTO" ] && [ ! -z "$NEED_IDX" ]; then
	echo -e "=== ${GREEN}Building${NC} directory indexes...\n"
	cur_dir=$(basename "$PWD")
	if [ "$cur_dir" = ".incoming" ]; then
		cd "$incoming_dir/.."
	fi
	/usr/local/bin/build > /opt/logs/last-build.log
fi


echo -e " Start time ${GREEN}${start_time}${NC}"
echo -e "Finish time ${GREEN}$(date '+%m-%d %H:%M:%S')${NC}"
echo -e "\n${GREEN}========= ALL DONE =========${NC}"


