#!/bin/bash
# Created by abraaojs
set -x

sudo systemctl start docker && sudo systemctl enable docker
sudo systemctl start kubelet && sudo systemctl enable kubelet
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet

NODE_IP=$(ip -br -4 address show eth1 | awk '{split($3,ip,"/"); print ip[1]}')
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$NODE_IP

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Install Flannel"
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
echo 'source <(kubectl completion bash)' >> $HOME/.bashrc

echo "Install Dashboard Kubernetes"
kubectl apply -f /vagrant/provision/kubernetes-dashboard.yml
kubectl apply -f /vagrant/provision/kubernetes-dashboard-rbac.yml
echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
