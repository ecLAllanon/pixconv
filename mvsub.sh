#!/bin/bash

for i in $(find . -mindepth 1 -type d -exec bash -c 'echo -ne "{}\t"' \;); do 
	mv $i/* .
done
find . -size 0 -print -delete 
find . -type d -empty -delete
