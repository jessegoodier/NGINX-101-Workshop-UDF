# NGINX Controller with Ansible Workshop 

In this workshop we will deploy NGINX Plus using Ansible and then connect that NGINX Plus instance to NGINX Controller that is already running.

Your VM has been provisioned in F5's UDF workshop system. Ansible is installed and this github repository cloned to it.

------------

For simplicity, the workshop uses a single host that will use the locally installed ansible to run playbooks that will ssh to the localhost to install NGINX Plus and the Controller-Agent. It also uses docker to create a couple web services running on ports 81, 82. 

Continue on to the workshpo:
<https://github.com/jessegoodier/NGINX-101-Workshop-UDF/blob/master/1-Workshop_Config_Guide.md>