# NGINX Controller with Ansible Workshop 

This workshop is to show how to deploy NGINX Plus using Ansible and then connecting that NGINX Plus instance to NGINX Controller that is already running.

The AWS VM has already been provisioned for you and has ansible installed and this github repository cloned to it.
The username / password are: workshop / Nginx1122!

------------

To save AWS costs, the workshop uses a single host that will use the locally installed ansible to run playbooks that will ssh to the localhost to install NGINX Plus and the Controller-Agent. It also uses docker to create a couple web services. 

Continue on to the workshpo:
<https://github.com/jessegoodier/NGINX-Ansible-Controller-Workshop/blob/master/1-Workshop_Config_Guide.md>