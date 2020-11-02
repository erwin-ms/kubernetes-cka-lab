#!/bin/bash
# Created by abraaojs
set -x

yum update -y
yum -y install epel-release
yum install -y git wget curl conntrack-tools vim net-tools telnet tcpdump bind-utils socat ntp kmod ceph-common dos2unix

echo "[TASK 2] Disable SELINUX"
sed -i -e s/enforcing/disabled/g /etc/sysconfig/selinux
sed -i -e s/permissive/disabled/g /etc/sysconfig/selinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

echo "[TASK 3] Disable Firewall"
systemctl disable firewalld
systemctl stop firewalld

echo "[TASK 4] Update iptables"
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "[TASK 5] Disable Swap"
swapoff -a && sed -i '/swap/d' /etc/fstab

echo "Install Docker"
yum install -y yum-utils nfs-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker && systemctl enable docker

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet
yum install -y kubeadm ipvsadm

modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_sh
modprobe ip_vs_wrr

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

NODE_IP=$(ip -br -4 address show eth1 | awk '{split($3,ip,"/"); print ip[1]}')
