#!/bin/bash
git pull
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get update
sudo apt-get -y install python2.7 jq software-properties-common ansible

ansible-galaxy collection install nginxinc.nginx_controller --force
chown -R ubuntu:ubuntu /home/ubuntu/.ansible
chmod 755 *.sh
ssh-keyscan -H localhost > ~/.ssh/known_hosts