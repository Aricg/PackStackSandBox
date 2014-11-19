#!/bin/bash
service NetworkManager stop
yum -y remove NetworkManager
systemctl start network.service
systemctl enable network.service
systemctl status network.service
yum makecache fast
yum update -y
systemctl stop firewalld
systemctl disable firewalld
yum -y install iptables-services vim tcpdump
#Create this below file, otherwise starting iptables will fail
touch /etc/sysconfig/iptables
systemctl enable iptables && systemctl start iptables
systemctl status iptables
