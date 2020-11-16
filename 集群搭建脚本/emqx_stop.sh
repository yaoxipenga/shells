#!/usr/bin/bash 
ps -ef | grep emqx | grep -v grep 
if [ $? -eq 0 ];then 
   /usr/local/src/emqx-rel/_rel/emqx/bin/emqx stop 
   ps -ef | grep emqx | grep -v grep | awk -F' ' '{print $2}' | xargs kill -9
fi 
 
ps -ef | grep emqx 

