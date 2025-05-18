#!/bin/bash

set -e

rawdata_dir=/mnt/raid/rawdata
ok_file=/mnt/raid/subdata/tmp/sha512sum-hyps.log
exclude_file=$rawdata_dir/exclude.txt

cd $rawdata_dir

now=$(date +%s)

find . -mindepth 1 -printf "%P\n" | sort | while read -r path; do
    if grep -Fxq "$path: OK" "$ok_file"; then
	run_num=$(echo "$path" | sed -E 's/[^0-9]*0*([0-9]+)\.dat/\1/')
	if awk '{print $1}' $exclude_file | grep -Fxq "$run_num"; then
	    echo keep $run_num
	else
            file_mtime=$(stat -c %Y "$path")
            age_days=$(( (now - file_mtime) / 86400 ))
            if [ "$age_days" -gt 14 ]; then
                # echo rm -rf -- "$path"
                rm -rf -- "$path"
            else
                echo skip recent "$path" "$age_days"
            fi
	    # grep -Fx "$path: OK" "$ok_file"
            # echo rm -rf -- "$path"
	fi
    fi
done
