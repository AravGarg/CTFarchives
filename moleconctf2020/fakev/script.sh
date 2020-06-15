#!/bin/bash

count=1
while [ $count -lt 10 ]
do
	touch $count.txt
	count=`expr $count + 1`
done
