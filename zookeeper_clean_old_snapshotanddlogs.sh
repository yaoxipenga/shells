#!/bin/bash 
 
#snapshot file dir 
dataDir=/opt/zookeeper/zkdata/version-2
#tran log dir 
dataLogDir=/opt/zookeeper/zkdatalog/version-2

#Leave 66 files 
count=66 
count=$[$count+1] 
#ls -t 默认是把日志按照时间倒叙排列，tail -n num默认是指的倒数num个，然后xargs传参后删除
ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f 
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f 

#以上这个脚本定义了删除对应两个目录中的文件，保留最新的66个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。


#zk log dir   del the zookeeper log
#logDir=
#ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f
