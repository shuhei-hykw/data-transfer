#!/bin/bash

process=$(basename $0)
top_dir=$(dirname $(readlink -f $0))/..

data_dir=(
    /mnt/raid/rawdata
    /mnt/raid/software
    /mnt/raid/subdata
    /mnt/raid/user
    /mnt/raid/hddaq
)
lock_file=/tmp/rsync.lock

ssh="sshpass -f $HOME/.pswd"
rsync="rsync -aP --exclude-from=/mnt/raid/user/hayakawa/data-transfer/exclude.txt"

#______________________________________________________________________________
while true
do
    for d in ${data_dir[@]}
    do
	cd $d
	if [ -f $lock_file ]; then continue; fi
	touch $lock_file
	if [[ "$d" == *"rawdata"* ]]
	then
	    dat_list=(bookmark misc Messages recorder.log)
	    # for dat in `ls *.dat.gz 2>/dev/null`
	    for dat in `ls *.dat 2>/dev/null`
	    do
		if [ -w $dat ]; then continue; fi
		dat_list+=("$dat")
	    done
	    $ssh $rsync -e ssh ${dat_list[@]} login.cc.kek.jp:/hsm/had/sks/HYPS/rawdata/
	else
	    $ssh $rsync -e ssh $d login.cc.kek.jp:/group/had/sks/HYPS/
	fi
	rm -f $lock_file
    done
    break
    sleep 10
done
