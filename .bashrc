# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
alias chwww='chmod g+w * ; chown -R www-data:www-data'
alias clr='echo > /opt/logs/access.log && echo > /opt/logs/error.log'
alias del0='find . -size 0 -print -delete'
alias scr='screen -dR scr'
alias scr1='screen -dR scr1'
alias scr2='screen -dR scr2'
alias vf='cd'
alias ginx='systemctl restart nginx'
alias newcert='certbot certonly --webroot'
alias rc='source ~/.bashrc'
alias dirt="echo '.' > dirtree.txt && find -L * -type d >> dirtree.txt && sort -f -o dirtree.txt dirtree.txt && sed -n '/thumb/!p' dirtree.txt > temp && mv temp dirtree.txt"
alias thum='dir="$(pwd)" ; cd /www/gallery ; php thumbs.php -p "$dir" ; cd "$dir" ; chown -R www-data:www-data *'
alias massrename='ls -1prt | grep -v "/$" | cat -n | while read n f; do mv -n "${f}" "$(printf "%04d" $n).${f#*.}"; done'
alias listen='netstat -tulpn'

alias pri='cd /www/priv/.incoming'
alias pi='cd /www/pix/.incoming'
alias loc='cd /usr/local/bin'


