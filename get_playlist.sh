#!/bin/sh
# for *nix shell

get_file_pomoyka()
{
 local URL="http://f27uk3gyl2gfu4z36eifv4ob73w6xgrcms4w4vdxzcsxsobgc766ityd.onion/trash/ttv-list/$(basename $1)"
 curl --socks5-hostname 127.0.0.1:9050 --compressed --connect-timeout 30 --max-time 50 --fail -R -z "$1" -o "$1" "${URL}"
}

get_file_pomoyka /www/pub/acetv.all.player.m3u
get_file_pomoyka /www/pub/acetv.all.tag.player.m3u
