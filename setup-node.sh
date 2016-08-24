#!/bin/bash
#
# node 安装脚本 2016-08-19 
#
if [ ! -n "${1}" ]; then
        echo "param 1: masterIp is required.eg：sh setup-node.sh 172.16.2.50"
        exit -1;
fi

thisIp=`ip a|grep inet|grep -v inet6|grep -v 127.0.0.1|grep 255|awk '{print $2}'|awk -F '/' '{print $1}'`
if [ -z "$thisIp" ]; then
        echo "nodeIp get error!"
        exit -1;
fi
yum -y install ntp flannel kubernetes nfs-utils net-tools

systemctl stop firewalld
systemctl disable firewalld
systemctl start ntpd
systemctl enable ntpd

masterIp=$1

#dockerConfig
dockerConfig="/etc/sysconfig/docker"
echo "--------$dockerConfig----------"
sed -i "s/OPTIONS=*/OPTIONS='--selinux-enabled=false'\n#/g" $dockerConfig
sed -i "s/# INSECURE_REGISTRY=*/INSECURE_REGISTRY='--insecure-registry 172.16.0.24:5000'\n#/g" $dockerConfig
grep -v "^#" $dockerConfig

#flanneldConfig
flanneldConfig="/etc/sysconfig/flanneld"
echo "--------$flanneldConfig--------"
sed -i "s/FLANNEL_ETCD=\"http*/FLANNEL_ETCD=\"http:\/\/$masterIp:2379\"\n#/g" $flanneldConfig
grep -v "^#" $flanneldConfig

#kubeMaterConfig
kubeMaterConfig="/etc/kubernetes/config"
echo "--------$kubeMaterConfig--------"
sed -i "s/KUBE_MASTER=*/KUBE_MASTER=\"--master=http:\/\/$masterIp:8080\"\n#/g" $kubeMaterConfig
grep -v "^#" $kubeMaterConfig

#kubeConfig
kubeConfig="/etc/kubernetes/kubelet"
echo "--------$kubeConfig--------"
sed -i "s/KUBELET_ADDRESS=*/KUBELET_ADDRESS=\"--address=0.0.0.0\"\n#/g" $kubeConfig
sed -i "s/# KUBELET_PORT=*/KUBELET_PORT=\"--port=10250\"\n#/g" $kubeConfig
sed -i "s/KUBELET_HOSTNAME=*/KUBELET_HOSTNAME=\"--hostname_override=$thisIp\"\n#/g" $kubeConfig
sed -i "s/KUBELET_API_SERVER=*/KUBELET_API_SERVER=\"--api_servers=http:\/\/$masterIp:8080\"\n#/g" $kubeConfig
sed -i "s/KUBELET_ARGS=*/KUBELET_ARGS=\"--cluster_dns=10.254.0.2 --cluster_domain=boxiao.cn --cadvisor-port=4194\"\n#/g" $kubeConfig
grep -v "^#" $kubeConfig


for SERVICES in kube-proxy kubelet flanneld docker; do
	echo ============\> systemctl restart $SERVICES
	systemctl restart $SERVICES
	echo ============\> systemctl enable $SERVICES
	systemctl enable $SERVICES
	echo ============\> systemctl status -l $SERVICES
	systemctl status -l $SERVICES
done