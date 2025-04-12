#!/bin/bash

process=$(basename $0)
top_dir=$(dirname $(readlink -f $0))/..

data_dir=(
    /home/sks/tcp_easiroc_v7
)
lock_file=/tmp/rsync.lock

ssh="sshpass -f $HOME/.pswd"
rsync="rsync -aP"

#______________________________________________________________________________
while true
do
    for d in ${data_dir[@]}
    do
	$ssh $rsync -e "ssh -o PubkeyAuthentication=no" \
	     $d hayashu@login.cc.kek.jp:/group/had/sks/E45/counter-test/
	rm -f $lock_file
    done
    break
    sleep 10
done
