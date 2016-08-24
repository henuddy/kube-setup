#!/bin/bash

yum -y install ntp etcd kubernetes

systemctl stop firewalld
systemctl disable firewalld
systemctl start ntpd
systemctl enable ntpd

openssl genrsa -out /tmp/serviceaccount.key 2048

etcdConfig="/etc/etcd/etcd.conf"
kubeApiConfig="/etc/kubernetes/apiserver"
kubeMngConfig="/etc/kubernetes/controller-manager"

#listen all ips
echo "-----------$etcdConfig-----------"
sed -i "s/ETCD_LISTEN_CLIENT_URLS=*/ETCD_LISTEN_CLIENT_URLS=\n#/g" $etcdConfig
sed -i "s/ETCD_LISTEN_CLIENT_URLS=/ETCD_LISTEN_CLIENT_URLS=\"http:\/\/0.0.0.0:2379\"\n#/g" $etcdConfig
grep -v "^#" $etcdConfig

echo "-----------$kubeApiConfig-----------"
sed -i "s/KUBE_API_ADDRESS=*/KUBE_API_ADDRESS=\"--address=0.0.0.0\"\n#/g" $kubeApiConfig
sed -i "s/# KUBE_API_PORT=*/KUBE_API_PORT=\"--port=8080\" \n#/g" $kubeApiConfig
sed -i "s/# KUBELET_PORT=*/KUBELET_PORT=\"--kubelet-port=10250\"\n#/g" $kubeApiConfig
sed -i "s/KUBE_API_ARGS=*/KUBE_API_ARGS=\"--service_account_key_file=\/tmp\/serviceaccount.key\"\n#/g" $kubeApiConfig
grep -v "^#" $kubeApiConfig

echo "-----------$kubeMngConfig-----------"
sed -i "s/KUBE_CONTROLLER_MANAGER_ARGS=*/KUBE_CONTROLLER_MANAGER_ARGS=\"--service_account_private_key_file=\/tmp\/serviceaccount.key\"\n#/g" $kubeMngConfig
grep -v "^#" $kubeMngConfig

for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler; do
	echo ============-\> systemctl restart $SERVICES
	systemctl restart $SERVICES
	echo ============-\> systemctl enable $SERVICES
	systemctl enable $SERVICES
	echo ============-\> systemctl status -l $SERVICES
	systemctl status -l $SERVICES
done

etcdctl mk /atomic.io/network/config '{"Network":"172.17.0.0/16"}'