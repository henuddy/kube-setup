#!/bin/bash
#
# install-goaccess.sh 安装脚本 2016-08-23 
#

version=1.0.2
yum -y install wget gcc gcc-c++ ncurses-devel geoip-devel tokyocabinet-devel
wget http://tar.goaccess.io/goaccess-$version.tar.gz
tar -zxvf goaccess-$version.tar.gz 
cd goaccess-$version
./configure --enable-geoip --enable-utf8
make && make install

echo 'time-format %H:%M:%S' >> /usr/local/etc/goaccess.conf
echo 'date-format %d/%b/%Y' >> /usr/local/etc/goaccess.conf
echo 'log-format %h %^[%d:%t %^] "%r" %s %b "%R" "%u"' >> /usr/local/etc/goaccess.conf
