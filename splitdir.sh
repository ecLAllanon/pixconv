#!/bin/bash

echo "========== Renaming ============"

/usr/local/bin/cyr2lat.sh *

# Remove all dangerous chars from filename
for i in $(find . -maxdepth 1 -print0 | perl -n0e 'chomp; print $_, "\n" if /[[:^ascii:][:cntrl:]]/'); do
        rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)"
done

#for i in $(find . -maxdepth 1 -regex '.*[^ -~].*' -print); do
for i in $(find . -maxdepth 1 -print); do
        rename -- 's/[^A-Za-z0-9._]/_/g' "$(basename $i)"
done

# Remove leftovers with control chars
for i in $(find . -maxdepth 1 -regex '.*[^ -~].*' -print); do
        rename -f -- 's/[^A-Za-z0-9._]/'$(printf %.3s $(echo $RANDOM))'/g' "$(basename $i)"
done

# Replace mass underlines
find . -type f -name "*___*" -exec bash -c 'f="$(basename $1)"; g="$(printf %.3s $(echo $RANDOM))_${f/*__/}"; mv -- "$f" "$g"' _ '{}' \;

rename -f -- 's/^-+//' *

echo "========== Moving ============"

for N in {001..100}; do 
	if [ "$(ls -A ./* 2> /dev/null)" ]; then
		mkdir ../result$N
		mv `ls | head -60` ../result$N/ && echo "Moved to result$N"
	else
		echo "========== All Done ============"
		exit 0
	fi
done
