#!/bin/sh

#set -e
SCRIPT_NAME=$(basename "$0")

if pidof -o $$ -x "$SCRIPT_NAME" > /dev/null; then
    echo "$SCRIPT_NAME is already running."
    exit 1
fi

src=(
    /misc/data/e72/
    /misc/kazan-home/e72-ctrl
    /misc/shsdata
    /mnt/nvme0/share
    /mnt/nvme0/user
)

host=login.cc.kek.jp
dest_disk=/group/had/sks/E72/JPARC2025May/
dest_tape=/hsm/had/sks/E72/JPARC2025May/rawdata

# dest_disk=$HOME/group/E70/JPARC2024May
# dest_tape=$HOME/hsm/E70/JPARC2024May

eval $(keychain --eval ~/.ssh/id_ed25519)

# if [ ! -f $HOME/.pswd ]; then exit; fi
# sshpass="sshpass -f $HOME/.pswd ssh -o Compression=no -x -l hayashu"
# sshpass="sshpass -p $pass ssh -o PubKeyAuthentication=no -l $user"

#rsync="rsync -rlptDvhP --update --partial --bwlimit=20M --exclude=*.dat"
#rsync="rsync -rlptDvhP --delete"
rsync="rsync -ahvz --partial --whole-file -e ssh"
#rsync="rsync -rlptDvhP"

while true
do
    for s in ${src[@]}
    do
	if [ ! -e $s ]; then continue; fi
	if ( echo $s | grep -sq e72 && ls $s | grep -sq lock ); then
	    echo "$s -> skip"
	    echo
	    continue
	fi
	if echo $s | grep -sq e72; then
	    dest=$host:$dest_tape
	    echo "$s -> $dest"
	    $rsync --exclude="$s/run*" $s $dest
	    tmp_include=/tmp/include-e72
	    find $s/run* -perm 444 > $tmp_include
	    $rsync --include-from=$tmp_include --exclude="*" $s $dest
	else
	    dest=$host:$dest_disk
	    echo "$s -> $dest"
	    $rsync $s $dest
	fi
	#ionice -c 2 -n 7 nice -n 19
    done
    date

    break

    echo waiting...
    sleep 300
done
