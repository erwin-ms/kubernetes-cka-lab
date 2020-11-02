#!/bin/bash
# Created by Abraao Silva
# Date 3/8/2020
set -x

vagrant up

join_cmd=$(vagrant ssh master -c 'sudo kubeadm token create --print-join-command')

vagrant ssh node1 -c "sudo ${join_cmd}"
vagrant ssh node2 -c "sudo ${join_cmd}"