#!/bin/bash
if [[ $# -lt 1 ]]
then
	echo "Usage: $0 <filename>"
	exit 1
fi
file=$1
declare -A count
for word in $(grep -P -o '\b\w+\b' $file)
do
	let count[$word]++
done
for word in ${!count[@]}
do
	printf "%-14s%s\n" $word ${count[$word]}
done
