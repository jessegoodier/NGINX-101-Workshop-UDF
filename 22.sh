#!/bin/bash
ansible-playbook agent.yaml -b -i hostroot -e "user_email=admin@nginx.com user_password=Nginx1122! controller_fqdn=controller1.ddns.net"
