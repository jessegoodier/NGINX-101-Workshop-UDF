#!/bin/bash
apt update
apt -y install python2.7 jq
apt install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt -y install ansible
ansible-galaxy install nginxinc.nginx 

ansible-galaxy install nginxinc.nginx-controller-generate-token
chmod 755 *.sh
ssh-keyscan -H localhost > ~/.ssh/known_hosts