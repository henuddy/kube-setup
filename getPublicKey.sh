#!/bin/bash
# getPublicKey
pubfile=/root/.ssh/id_rsa.pub

if [ ! -f "$pubfile" ]; then
	rm -rf ~/.ssh/id_rsa*
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi

pubKey=`cat $pubfile`
echo $pubKey