#!/bin/bash 
num=$[$RANDOM%100+1]
while true 
do 
	read -p "请猜一猜:" gnum
	if [ $gnum -gt $num ];then 
		echo "大了"
	elif [ $gnum -lt $num ];then 
		echo "小了"
	else		
		echo "对了"
		break
	fi



done 

echo "快来领奖啦"	
