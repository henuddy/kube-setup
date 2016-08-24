#!/bin/bash
# addNode.sh
# 添加node 2016-08-19
#
test -z "$*" && \
	echo 'ERROR! addNode.sh必要参数不能为空！参数要求: nodeIp1 nodeIp2...(以” “分割)' \
    && exit -1;

paramNodes=$*
echo "params: $*"
addedNodes=$(kubectl get node|grep -v 'NAME'|awk '{print $1}')
for addedNodeIp in addedNodes
do
	for paramNodeIp in paramNodes
	do 
		test $addedNodeIp == $paramNodeIp && echo "Error! $paramNodeIp is already added." && exit -1
	done
done

cd `dirname $0`
pubKey=`sh getPubKey.sh`
echo $pubKey > ~/authorized_keys
test -z "$pubKey" && echo "Error! pubKey is null" && exit -1
# push master的public key
for paramNodeIp in $paramNodes
do 
	echo "push master pubKey to $paramNodeIp.."
	ssh root@$paramNodeIp "echo 'StrictHostKeyChecking no' > ~/.ssh/config && echo $pubKey >> ~/.ssh/authorized_keys"
done
# 收集所有机器的public key
nodeIpList="$addedNodes $paramNodes"
for nodeIp in $nodeIpList
do
	echo "get $nodeIp 's pubKey.."
	scp getPubKey.sh root@$nodeIp:~/
	nodePubKey=`ssh root@$nodeIp "sh ~/getPubKey.sh"`
	echo $nodePubKey >> ~/authorized_keys
done
# 添加所有node以及master的public key
for nodeIp in $nodeIpList
do
	echo "push all pubKey to $nodeIp"
	scp ~/authorized_keys root@$nodeIp:~/.ssh/
done
echo "end."
