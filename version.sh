#!/bin/sh

if [ "$1" = "" ]; then
	echo "Usage: $0 [filename]"
	exit 1
fi
grep "HDEFINE(VERSION" "$1" |awk -F\" '{print $3}' |awk -F\\ '{print $1}'