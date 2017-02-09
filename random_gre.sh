#!/bin/bash

customlist=$1
infof=`wc -l $customlist`
infon=1-`echo $infof | cut -d\  -f 1`
lnum=`shuf -i $infon -n 1`q\;d
# lnum=`shuf -i 1-683 -n 1`q\;d
ltxt="`sed $lnum $customlist | sed -e 's/|//g'`"
echo -e "$ltxt"
