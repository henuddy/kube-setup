#!/bin/bash
# addRoute.sh
# 添加node 2016-08-19
#
test -z "$*" && \
	echo 'ERROR! addRoute.sh 必要参数不能为空！参数要求: nodeIp1 nodeIp2...(以” “分割)' \
    && exit -1;

paramNodes=$*
addedNodes=$(kubectl get node|grep -v 'NAME'|awk '{print $1}')
nodeDockerIps=''
nodeIps=''
i=0
for nodeIp in $addedNodes $paramNodes
do
	echo -n "get $nodeIp 's docker0 ip ..："
	dockerIp=`ssh root@$nodeIp "route | grep docker0" | awk '{print $1}'`
	echo $dockerIp
	test -z "$dockerIp" && echo "Error! $nodeIp 's docker0 ip is null." && continue
	nodeDockerIps="$nodeDockerIps $dockerIp@$nodeIp"
	nodeIps="$nodeIps $nodeIp"
done

echo "ok node docker0 ips : $nodeDockerIps"
echo "ok node ips : $nodeIps"

for nodeIp in $nodeIps
do
	echo "add route to $nodeIp..."
	scp doAddRoute.sh root@$nodeIp:~/
	ssh root@$nodeIp "sh ~/doAddRoute.sh $nodeDockerIps"
done
echo "addRoute end."