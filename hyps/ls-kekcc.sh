#!/bin/bash

process=$(basename $0)
top_dir=$(dirname $(readlink -f $0))/..

ssh="sshpass -f $HOME/.pswd"

#______________________________________________________________________________
$ssh ssh login.cc.kek.jp ls -la /hsm/had/sks/HYPS/rawdata/
