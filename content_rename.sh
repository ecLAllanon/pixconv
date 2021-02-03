#!/bin/sh
for f in *; do
    d="$(grep "Subject:" "$f" | sed -e 's/[^A-Za-z0-9._ ]//g' | sed -e 's/Subject ASSM //g')"
    if [ ! -f "$d" ]; then
        mv "$f" "$d.txt"
    else
        echo "File '$d' already exists! Skiped '$f'"
    fi
done

