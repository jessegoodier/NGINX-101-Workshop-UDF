#!/bin/bash
sudo apt update
sudo apt -y install python2.7 jq
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt -y install ansible
ansible-galaxy install nginxinc.nginx 
#ansible-galaxy collection install nginxinc.nginx_controller
ansible-galaxy install nginxinc.nginx_controller_generate_token
ansible-galaxy install nginxinc.nginx_controller_agent
sudo chmod 755 *.sh
ssh-keyscan -H localhost > ~/.ssh/known_hosts