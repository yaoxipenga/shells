@echo off

rem mysql安装路径
set mysql_home=D:\mysql-5.7.30-winx64

rem winrar安装路径
set rar_file="C:\Program Files\WinRAR\WinRAR.exe"

rem 设置备份文件存放路径
set backup_path=E:\data_backup

rem 设置备份数据库名
set backup_database=demo

rem 设置备份生成脚本名
set backup_file=demo.sql

rem 设置打包文件名
set pack_file=demo.rar

rem 数据库地址
set mysql_address=192.168.81.244

rem 数据库用户名
set mysql_user=root

rem 数据库密码
set mysql_password=mect888!

rem 历史备份最大保留天数
set max_savedays=7

rem 执行备份命令导出数据库脚本（恢复时使用命令：mysql -u用户名 -p密码 数据库名 < 备份脚本）
%mysql_home%\bin\mysqldump --no-defaults  --host %mysql_address%  --port=3306  -u%mysql_user%    -p%mysql_password%  --events --routines --triggers --flush-logs --add-drop-database --add-drop-table --default-character-set=utf8   --single-transaction --databases %backup_database% > %backup_path%\%backup_file%
rem 将导出的数据库脚本打包压缩 rar 参数：m 移动文件到压缩包，-rr 添加恢复记录，-ag 压缩文件自动生成带日期的文件名
%rar_file% m -rr -ag %backup_path%\%pack_file% %backup_path%\%backup_file%

rem 删除老的备份，最大保留天数在max_savedays变量里设置  forfiles 参数：-p 搜索路径，-m 搜索文件类型，/d -数字 搜索大于多少天数的文件，/c "命令"
forfiles -p %backup_path% -m *.rar /d -%max_savedays% /c "cmd /c del /f/q @path"



