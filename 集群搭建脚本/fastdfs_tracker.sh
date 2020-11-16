echo -e "\033[1;32m 1.获取fastdfs的docker镜像 \033[0m"
docker pull morunchang/fastdfs:latest
echo -e "\033[1;32m 2.生成tracker容器并启动 \033[0m"
docker run -itd --name tracker --restart=always --net=host morunchang/fastdfs sh tracker.sh
echo -e "\033[1;32m 查看traker容器启动状态 \033[0m"
docker ps
exit
