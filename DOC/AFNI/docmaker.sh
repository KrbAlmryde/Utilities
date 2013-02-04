#!/bin/sh

while read prog; do
	cat $prog > $prog.txt
done <size
