# Workshop Config Guide

## Install NGINX Plus using Ansible:

1. Navigate to UDF <https://udf.f5.com/courses> and login with creditials that were emailed to you from noreply@registration.udf.f5.com
2. You should see an event Happening now. Click on the Launch link at the far right.
3. Click the Jion button.
4. On the top of the page, click on the Deployment tab. Note that the VM will take a minute to provision and will be ready when you have a green arrow next to the nginx-plus VM.
5. To use your VM, click the "Access" link on the NGINX-Plus host and use the Web Shell
6. Note that in the web shell to paste on Windows, use ctrl-shift-v
7. You will be logged in as root, first we will change your hostname and we will instead use the ubuntu account for the remainder of the workshop.
   1. >hostnamectl set-hostname yourname
   2. >su ubuntu
9.  Install our required dependencies for the workshop.
   2. >cd ~/NGINX-Ansible-Controller-Workshop
   3. >sh 0-install-required-dependencies.sh
10. Verify that nginx is not running
   4. >curl localhost
11. Take a look at the playbook and note the host groups that will be targeted (loadbalancers). Also view the hosts files to see which host(s) will be updated. 
   5. >cat nginx_plus.yaml
   6. >cat hosts
   7. >cat nginx_plus_vars.yaml
12. Run the Ansible playbook to install NGINX Plus. (use option 1 or 2)
   8. Full command: 
         >ansible-playbook nginx_plus.yaml -b -i hosts
   9. Scripted equivalent
         >./1-run-nginx_plus-playbook.sh

## Open the Controller GUI / Install agent on VM

7. <https://controller1.ddns.net> (User: admin@nginx.com / Nginx1122!)
8. Click the upper left NGINX logo and Infrastructure section>graphs. Note that your instance isn't there. 
9.  Go back to your ssh session and run the controller agent install playbook. (use option 1 or 2)
    1. Full command: 
       >ansible-playbook nginx_controller_agent_3x.yaml -b -i hosts -e "user_email=admin@nginx.com user_password=Nginx1122! controller_fqdn=controller1.ddns.net"
    2. Scripted Equivalent: 
       >sh 2-run-nginx_controller_agent_3x-playbook.sh

## Configure Load Balancing Within Controller GUI

10. Go back to the Controller GUI and go to the Infrastructure>Graphs page
11. Wait for the new instance to appear and then feel free to change the alias by clicking the settings (gear icon) so it is easy for you to find.
12. Click on the NGINX logo and select Services. 
13. Go to the Gateways
14. Create a new gateway, call it yourname-gw
15. Put it in the production environment and hit next.
16. In the Placements, select your NGINX instance, hit next.
17. Under the hostnames, add 
    1.  http://nginx.ddns.net 
    2.  https://nginx.ddns.net 
    3.  Be sure to hit done after adding each URI.
18. Select the nginx.ddns.net certificate and select all protocols.
19. Feel free to view the optional configuration options.
20. Publish the gateway and wait on the Gateways screen until your status is green.
21. On the leftmost column hit Apps to show the My Apps menu > select overview. Click one of the buttons that say Create App.
22. Name your app yourname-app and put it in the production environment. 
23. Hit submit.
24. You should be brought to the Apps list and you see your app listed. We need to create a Component for your app. There are numerous ways to create this first component one of which is to hover over your app and hit the eye icon under the View column. This page provides an Overview for this entire app. Hit Create Component near the upper-right corner of the page.
25. Name the first component time1
26. In the Gateways section, select your gateway.
27. In the URI section, add (link is on top right of screen) uri: /time1
28. Hit done. 
29. Click next through the optional configuration items until you get to workload groups.
30. Add a workload group. Name it time1
31. Add the backend workload URI: http://3.20.98.115:81
32. Be sure to hit done after adding the URI.
33. Hit publish.
34. Wait for the green Configured status underneath time1. 
35. Navigate back to the UDF Deployment page and under the nginx-plus VM, click access and http refresh the browser to see time change.
36. View the changes made to /etc/nginx/nginx.conf on your host. 
    1.  >sudo nginx -T
37. Repeat steps 24-35 adding a component for time2 and point it to http://3.20.98.115:82
38. Add another component and name it both.
39. Select your gateway. 
40. In the URI section add: /both 
41. Click done.
42. Click on Workload groups and add a workload group called both
43. Add both of our backend workoad URIs:
    1.  http://3.20.98.115:81
    2.  http://3.20.98.115:82
44. Test the new configuration with a few curl commands on your SSH session:
    1.  curl localhost/time1
    2.  curl localhost/time2
    3.  curl localhost/both (run it several times to see the round robin)
    4.  curl -k https://localhost/both (to test https is working)
    5.  you can also test using the public IP of your VM in a browser

## Configure API Management

44. Navigate to Services>APIs and view the workload group. (ergast.com:80)
45. On API Definitions create your "F1 Yourname" API with base path /api/f1
46. Hit save and add URI /seasons and /drivers. Enable documentation with response 200 and {"response":"2009"} as an example (you can make this up, it is just for future developers who might consume this API resource)
47. Click Add A Published API f1_api in prod and create a new application "yourname_f1_app"
48. Select the entry point, click save.
49. Scroll to the bottom and add the routes to the resources we created.
50. Publish and wait for the success message.
51. curl a few of these examples:
```
   curl -k http://localhost/api/f1/seasons
   curl -k http://localhost/api/f1/drivers
   curl -k http://localhost/api/f1/drivers.json
   curl -k http://localhost/api/f1/drivers/arnold.json
```

52. Edit your published API and add a rate limit policy.
53. Publish and test a couple more requests.
54. Review the JWT Identity Provider under the API Managment Section. A JWT has been configured. It is in this repo, named auth_jwt_key_file.jwk.
55. Go back to your API Definition and edit your published API to require an Authentication Policy using the JWT Provider. 
56. Publish and test a curl command using this token (which is in the script in option 2). Alternatively, use postman.
    1.  >curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJuYW1lIjoiUXVvdGF0aW9uIFN5c3RlbSIsInN1YiI6InF1b3RlcyIsImV4cCI6IjE2MDk0NTkxOTkiLCJpc3MiOiJNeSBBUEkgR2F0ZXdheSJ9.lJfCn7b_0mfKHKGk56Iu6CPGdJElG2UhFL64X47vu2M" localhost/api/f1/seasons
    2.  >sh 3-run-jwt-curl.sh


Optional, if you have time:

57. Add an alert for too many 500 errors.
58. Create a dashboard that you think might be useful in a NOC.
59. Access the Developer API Management Portal: <http://3.19.238.184:8090>
Feel free to browse around the GUI to see other functionality. 
