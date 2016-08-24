#!/bin/bash
#
# addNode 安装脚本 2016-08-22
#

test -z "$*" && \
	echo 'ERROR! addNode.sh 必要参数不能为空！参数要求: nodeIp1 nodeIp2...(以” “分割)' \
    && exit -1;

masterIp=`ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1|awk '{print $2}'|awk -F '/' '{print $1}'`
echo "master IP is : $masterIp"
test -z "$masterIp" && \
    echo "addNode.sh masterIp get error!" \
    && exit -1;
paramNodes=$*
echo "params: $*"
sh sshkeygen.sh $paramNodes
test $? -ne 0 && echo "Error!" && exit -1
# 执行node安装脚本
for nodeIp in $paramNodes
do
	echo "begin install node $nodeIp.."
	scp setup/setup-node.sh root@$nodeIp:~/
	ssh root@$nodeIp "sh ~/setup-node.sh $masterIp"
	test $? -ne 0 && echo "Error"
done

sh addRoute.sh $paramNodes
test $? -ne 0 && echo "Error!"
echo "end."