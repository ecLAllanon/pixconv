#!/bin/bash
declare -A dictionary=(
    ["Ч"]="Ch"
    ["Ш"]="Sh"
    ["Щ"]="Sht"
    ["Ю"]="Yu"
    ["Я"]="Ya"
    ["Ж"]="Zh" 
    ["А"]="A"
    ["Б"]="B"
    ["В"]="V"
    ["Г"]="G"
    ["Д"]="D"
    ["Е"]="E"
    ["З"]="Z"
    ["И"]="I"
    ["Й"]="Y"
    ["К"]="K"
    ["Л"]="L"
    ["М"]="M"
    ["Н"]="N"
    ["О"]="O"
    ["П"]="P"
    ["Р"]="R"
    ["С"]="S"
    ["Т"]="T"
    ["У"]="U"
    ["Ф"]="F"
    ["Х"]="H"
    ["Ц"]="C"
    ["Ъ"]="A"
    ["Ь"]="I"
    ["Ы"]="Y"
)
 
for letter in "${!dictionary[@]}"; do
    lowercase_from=$(echo $letter | sed 's/[[:upper:]]*/\L&/')
    lowercase_to=$(echo ${dictionary[$letter]} | awk '{print tolower($0)}')
    dictionary[$lowercase_from]=$lowercase_to
done
 
function cyr2lat {
    string=$1
    for letter in "${!dictionary[@]}"; do
        string=${string//$letter/${dictionary[$letter]}}
    done
 
    echo $string;
}
 
for f in "$@"
do
    if [ ! -f "$f" ]; then
        echo "$(basename "$0") warn: this is not a regular file (skipped): $f" >&2
        continue
    fi
 
    DIR=$(dirname "$f")
    BASENAME="$(basename "$f")"
    # convert non-latin chars using my transliterate script OR uconv from the icu-devtools package
    NEWFILENAME=$(cyr2lat "$BASENAME") 
     
    if [ -f "$DIR/$NEWFILENAME" ]; then
        echo "$BASENAME warn: target filename already exists (skipped): $BASENAME/$NEWFILENAME" >&2
        continue
    fi
 
    if [ "$BASENAME" != "$NEWFILENAME" ]; then
        echo "\`$f' -> \`$NEWFILENAME'"
        mv -i "$f" "$DIR/$NEWFILENAME"
    fi
done
