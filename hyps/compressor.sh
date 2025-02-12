#!/bin/sh

process=$(basename $0)
top_dir=$(dirname $(readlink -f $0))/..

data_dir=(
    /mnt/raid/rawdata
)
lock_file=pigz.lock

#______________________________________________________________________________
while true
do
    # date
    for d in ${data_dir[@]}
    do
	cd $d
	if [ -f $lock_file ]; then continue; fi
	touch $lock_file

	# if [ -f dsync.lock ]; then
	#     sleep 1
	#     continue
	# fi
	for dat in `ls *.dat 2>/dev/null`
	do
	    ### writing
	    if [ -w $dat ]; then continue; fi

	    run5=`echo $dat | sed "s/run//g" | sed "s/.dat//g"` # %05d
	    run=`expr $run5 + 0`

	    dat_gz=$dat.gz

	    ### already compressed
	    if [ -f $dat_gz ]; then continue; fi

	    ### start gzip
	    date
	    echo "Compressing ... $dat -> $dat_gz  "
	    ls -lh $dat
	    #pv
	    cat $dat | nice -n 19 pigz -p 30 > $dat_gz \
		&& chmod -c 444 $dat_gz \
		&& ls -l $dat_gz >> compressor.log
	done
	# echo -n "data dir : " && pwd -P
	rm -f $lock_file
    done
    # df -h
    # echo
    break
    sleep 10
done
