#!/bin/bash

./modScan.sh &
pid=$!

test=$( ps -p $pid | grep $pid )

while [ -n "$( ps -p ${pid} | grep ${pid} )" ]
do
	echo "."
	sleep 1
	test=$( ps -p $pid | grep $pid )
done