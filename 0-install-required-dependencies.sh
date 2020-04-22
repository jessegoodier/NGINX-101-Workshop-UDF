#!/bin/bash
apt-add-repository --yes --update ppa:ansible/ansible
apt-get update
apt-get -y install python2.7 jq software-properties-common ansible

ansible-galaxy install nginxinc.nginx 
ansible-galaxy install nginxinc.nginx_controller_agent
ansible-galaxy install nginxinc.nginx_controller_generate_token
chmod 755 *.sh
ssh-keyscan -H localhost > ~/.ssh/known_hosts