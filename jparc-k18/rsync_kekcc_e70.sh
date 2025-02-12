#!/bin/sh

#set -e
SCRIPT_NAME=$(basename "$0")

if pidof -o $$ -x "$SCRIPT_NAME" > /dev/null; then
    echo "$SCRIPT_NAME is already running."
    exit 1
fi

src=(
    /mnt/raid/e70_bench
    /mnt/raid/e70_2025jan
    /mnt/ssd1/software/param.git
    /mnt/raid/subdata
)

host=login.cc.kek.jp
dest_disk=/group/had/sks/E70/JPARC2025Jan
dest_tape=/hsm/had/sks/E70/JPARC2025Jan

# dest_disk=$HOME/group/E70/JPARC2024May
# dest_tape=$HOME/hsm/E70/JPARC2024May

if [ ! -f $HOME/.pswd ]; then exit; fi
sshpass="sshpass -f $HOME/.pswd ssh -o Compression=no -x -l hayashu"
# sshpass="sshpass -p $pass ssh -o PubKeyAuthentication=no -l $user"

#rsync="rsync -rlptDvhP --update --partial --bwlimit=20M --exclude=*.dat"
#rsync="rsync -rlptDvhP --delete"
rsync="rsync -ahvz --partial --whole-file"
#rsync="rsync -rlptDvhP"

while true
do
    for s in ${src[@]}
    do
	if [ ! -e $s ]; then continue; fi
	if ( echo $s | grep -sq e70 && ls $s | grep -sq lock ); then
	    echo "$s -> skip"
	    echo
	    continue
	fi
	if echo $s | grep -sq e70; then
	    dest=$host:$dest_tape
	    echo "$s -> $dest"
	    $rsync --exclude="$s/run*" -e "$sshpass" $s $dest
	    tmp_include=/tmp/include-e70
	    find $s/run* -perm 444 > $tmp_include
	    $rsync --include-from=$tmp_include --exclude="*" -e "$sshpass" $s $dest
	else
	    dest=$host:$dest_disk
	    echo "$s -> $dest"
	    $rsync -e "$sshpass" $s $dest
	fi
	#ionice -c 2 -n 7 nice -n 19
    done
    date

    break

    echo waiting...
    sleep 300
done
