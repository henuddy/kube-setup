#!/bin/bash
# doAddRoute.sh
# 添加node route 2016-08-22
#
test -z "$*" && \
	echo 'ERROR! doAddRoute.sh 必要参数不能为空！参数要求: docker0Ip@nodeIp1 docker0Ip@nodeIp2...(以” “分割)' \
    && exit -1;
thisNodeIp=`ip a|grep inet|grep -v inet6|grep -v 127.0.0.1|grep 255|awk '{print $2}'|awk -F '/' '{print $1}'`
params=$*
test -f ~/static-routes && rm -f ~/static-routes
test -f /etc/sysconfig/static-routes && rm -f /etc/sysconfig/static-routes
touch ~/static-routes
#echo "params: $params"
for nodeDockerIp in $params
do
	dockerIp=`echo $nodeDockerIp | awk -F '@' '{print $1}'`
	nodeIp=`echo $nodeDockerIp | awk -F '@' '{print $2}'`
	test $nodeIp == $thisNodeIp && continue
	echo "add $nodeIp 's docker0 ip $dockerIp to $thisNodeIp..."
	thisRoute=`route | grep $dockerIp`
	echo "any -net $dockerIp netmask 255.255.255.0 gw $nodeIp" >> ~/static-routes
	if [ -z "$thisRoute" ]; then
		route add -net $dockerIp netmask 255.255.255.0 gw $nodeIp
	else
		thisRouteGw=`echo $thisRoute|awk '{print $2}'`
		if [[ $thisRouteGw != $nodeIp ]]; then
			route del -net $dockerIp netmask 255.255.255.0  gw $thisRouteGw
			route add -net $dockerIp netmask 255.255.255.0 gw $nodeIp
		fi
	fi
done
cp ~/static-routes /etc/sysconfig/
echo "doAddRoute $thisNodeIp end."