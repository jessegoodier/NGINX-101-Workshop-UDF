# Workshop Config Guide

## Install NGINX Plus using Ansible:

1. Navigate to UDF <https://udf.f5.com/courses> and login with creditials that were emailed to you from noreply@registration.udf.f5.com
2. You should see an event Happening now. Click on the Launch link at the far right.
3. Click the join button.
4. On the top of the page, click on the Deployment tab. Note that the VM will take a minute to provision and will be ready when you have a green arrow next to the nginx-plus VM.
5. To use your VM, click the "Access" link on the NGINX-Plus host and use the Web Shell
6. Note that in the web shell to paste on Windows, use ctrl-shift-v
7. You will be logged in as root, first we will change your hostname and we will instead use the ubuntu account for the remainder of the workshop.
   1. >hostnamectl set-hostname yourname
   2. >su ubuntu
8. Install our required dependencies for the workshop.
   1. >cd ~/NGINX-101-Workshop-UDF
   2. >sudo sh 0-install-required-dependencies.sh
9.  Verify that nginx is not running
   1.  >curl localhost
10. Take a look at the playbook and note the host groups that will be targeted (loadbalancers). Also view the hosts files to see which host(s) will be updated. 
   3. >cat nginx_plus.yaml
   4. >cat hosts
   5. >cat nginx_plus_vars.yaml
11. Run the Ansible playbook to install NGINX Plus. (use option 1 or 2)
   6. Full command: 
         >ansible-playbook nginx_plus.yaml -b -i hosts
   7.  Scripted equivalent
         >./1-run-nginx_plus-playbook.sh

## Open the Controller GUI / Install agent on VM

13. <https://controller1.ddns.net> (User: admin@nginx.com / Nginx1122!)
14. Click the upper left NGINX logo and Infrastructure section>graphs. Note that your instance isn't there. 
15. Go back to your ssh session and run the controller agent install playbook. (use option 1 or 2)
    1. Full command: 
       >ansible-playbook nginx_controller_agent_3x.yaml -b -i hosts -e "user_email=admin@nginx.com user_password=Nginx1122! controller_fqdn=controller1.ddns.net"
    2. Scripted Equivalent: 
       >sh 2-run-nginx_controller_agent_3x-playbook.sh

## Configure Load Balancing Within Controller GUI

16. Go back to the Controller GUI and go to the Infrastructure>Graphs page
17. Wait for the new instance to appear and then feel free to change the alias by clicking the settings (gear icon) so it is easy for you to find.
18. Click on the NGINX logo and select Services. 
19. Go to the Gateways
20. Create a new gateway, call it yourname-gw
21. Put it in the production environment and hit next.
22. In the Placements, select your NGINX instance, hit next.
23. Under the hostnames, add 
    1.  http://nginx.ddns.net 
    2.  https://nginx.ddns.net 
    3.  Be sure to hit done after adding each URI.
24. Select the nginx.ddns.net certificate and select all protocols.
25. Feel free to view the optional configuration options.
26. Publish the gateway and wait on the Gateways screen until your status is green.
27. On the leftmost column hit Apps to show the My Apps menu > select overview. Click one of the buttons that say Create App.
28. Name your app yourname-app and put it in the production environment. 
29. Hit submit.
30. You should be brought to the Apps list and you see your app listed. We need to create a Component for your app. There are numerous ways to create this first component one of which is to hover over your app and hit the eye icon under the View column. This page provides an Overview for this entire app. Hit Create Component near the upper-right corner of the page.
31. Name the first component time1
32. In the Gateways section, select your gateway.
33. In the URI section, add (link is on top right of screen) uri: /time1
34. Hit done. 
35. Click next through the optional configuration items until you get to workload groups.
36. Add a workload group. Name it time1
37. Add the backend workload URI: http://3.20.98.115:81
38. Be sure to hit done after adding the URI.
39. Hit publish.
40. Wait for the green Configured status underneath time1. 
41. Navigate back to the UDF Deployment page and under the nginx-plus VM, click access and http refresh the browser to see time change.
42. View the changes made to /etc/nginx/nginx.conf on your host. 
    1.  >sudo nginx -T
43. Repeat steps 24-35 adding a component for time2 and point it to http://3.20.98.115:82
44. Add another component and name it both.
45. Select your gateway. 
46. In the URI section add: /both 
47. Click done.
48. Click on Workload groups and add a workload group called both
49. Add both of our backend workoad URIs:
    1.  http://3.20.98.115:81
    2.  http://3.20.98.115:82
50. Test the new configuration with a few curl commands on your SSH session:
    1.  curl localhost/time1
    2.  curl localhost/time2
    3.  curl localhost/both (run it several times to see the round robin)
    4.  curl -k https://localhost/both (to test https is working)
    5.  you can also test using the public IP of your VM in a browser

## Configure API Management

51. Navigate to Services>APIs and view the workload group. (ergast.com:80)
52. On API Definitions create your "F1 Yourname" API with base path /api/f1
53. Hit save and add URI /seasons and /drivers. Enable documentation with response 200 and {"response":"2009"} as an example (you can make this up, it is just for future developers who might consume this API resource)
54. Click Add A Published API f1_api in Production and select the app you created "yourname_f1_app"
55. Select the entry point, click save.
56. Scroll to the bottom and add the routes to the resources we created.
57. Publish and wait for the success message.
58. curl a few of these examples:
```
   curl -k http://localhost/api/f1/seasons
   curl -k http://localhost/api/f1/drivers
   curl -k http://localhost/api/f1/drivers.json
   curl -k http://localhost/api/f1/drivers/arnold.json
```

59. Edit your published API and add a rate limit policy.
60. Publish and test a couple more requests.
61. Review the JWT Identity Provider under the API Managment Section. A JWT has been configured. It is in this repo, named auth_jwt_key_file.jwk.
62. Go back to your API Definition and edit your published API to require an Authentication Policy using the JWT Provider. 
63. Publish and test a curl command using this token (which is in the script in option 2). Alternatively, use postman.
    1.  >curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJuYW1lIjoiUXVvdGF0aW9uIFN5c3RlbSIsInN1YiI6InF1b3RlcyIsImV4cCI6IjE2MDk0NTkxOTkiLCJpc3MiOiJNeSBBUEkgR2F0ZXdheSJ9.lJfCn7b_0mfKHKGk56Iu6CPGdJElG2UhFL64X47vu2M" localhost/api/f1/seasons
    2.  >sh 3-run-jwt-curl.sh



Etra credit, if you have time:

64. Add an alert for too many 500 errors.
65. Create a dashboard that you think might be useful in a NOC.
66. Access the Developer API Management Portal: <http://3.16.124.236:8090/docs>
Feel free to browse around the GUI to see other functionality. 
