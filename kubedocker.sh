#!/bin/bash
#
# kube+docker 安装脚本 2016-08-19 
#

test -z "$*" && \
	echo 'ERROR! kubedocker.sh 必要参数不能为空！参数要求: nodeIp1 nodeIp2...(以” “分割)' \
    && exit -1;

cd $(cd `dirname $0`; pwd)

# 执行master安装脚本
test ! -f setup-master.sh && echo "setup-master.sh not found." && exit -1
sh setup-master.sh

test ! -f addNode.sh && echo "addNode.sh not found." && exit -1
sh addNode.sh $*
# 添加lables属性
addedNodes=$(kubectl get node|grep -v 'NAME'|awk '{print $1}')
for node in $addedNodes
do
	echo "add lables to $node..."
	kubectl label --overwrite nodes $node node=$node
done

test ! -f install-goaccess.sh && echo "Error!"
sh install-goaccess.sh
cd ..
if [[ -d "master" ]]; then
	cp master/* /usr/local/bin/
	chmod +x /usr/local/bin/*
else
	echo "Error! master dir not found."
fi



