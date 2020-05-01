# Workshop Config Guide

## Accessing the labs

You will be access the labs using the F5 Unified Demo Framework (UDF).  Chrome is the preferred browser for access.

1. Open your browser, preferably Chrome and navigate to F5 UDF <https://udf.f5.com/courses>
   1. Select the **Non-F5 Users** option and log in using you UDF credentials.
      1. If this is your first time accessing UDF you should have received an email from noreply@registration.udf.f5.com with your credentials and asking you to reset your passsword.   
      2. **IMPORTANT** You should retain these credentials, as they will be required to any access future courses you attend in the F5 UDF environment.
2. You should see the event(s) under **Happening now**. Find the NGINX 101 Workshop event and click on the **Launch** link at the far right. 
3. Click the **Join** button.  Manage SSH Keys should not be required. 
4. At the top you will see **Documentation** and **Deployment**.
   1. In the **Documentation** section you can elect to leave the session, see how long the session last and other documentation
   2. Click on the **Deployment** tab. Note that the **nginx-plus** VM will take a minute to provision and will be ready when you have a green arrow.
5. To access the nginx-plus VM, click the **Access** link and select **Web Shell** from the drop-down menu
6. **NOTE**: To paste into the web shell use **ctrl-shift-v**

## Install NGINX Plus using Ansible

7. You will be logged in as root, let's first modify the hostname and then we will use the substitue user command (su) to use the **ubuntu** account for the remainder of the workshop.
   1. **hostnamectl set-hostname** *yourname*
   2. **su ubuntu**
8. Install our required dependencies for the workshop.
   1. **cd ~/NGINX-101-Workshop-UDF**
   2. **sudo sh 0-install-required-dependencies.sh**
9. Verify that nginx is not running
   1. **curl localhost**
10. Take a look at our playbook that will install NGINX Plus. Note the host groups that will be targeted (loadbalancers). Also view the hosts file to see which host(s) will be updated.
    1. **cat nginx_plus.yaml**
    1. **cat hosts**
    1. **cat nginx_plus_vars.yaml**
11. Note that we have cloned a github repository containing all of the files used in this workshop except the NGINX license certificates. We will need to move the license certificates to the correct folder for the scripts to work.
    1. **cp ~/nginx-repo.\* license/**
12. Run the Ansible playbook to install NGINX Plus. (use option 1 or 2)
    1. Full command:
         **ansible-playbook nginx_plus.yaml -b -i hosts**
    2. Scripted equivalent
         **sh 1-run-nginx_plus-playbook.sh**

## Open the Controller GUI / Install agent on VM

1. Open <https://controller1.ddns.net> (User: admin@nginx.com / Nginx1122!)
2. Click the upper left NGINX logo, then click on **Infrastructure** and then **Graphs**. Note that your instance isn't there.
3. Go back to your ssh session and run the controller agent install playbook. (use option 1 or 2)
    1. Full command:
       ```
          ansible-playbook nginx_controller_agent_3x.yaml -b -i hosts -e "user_email=admin@nginx.com user_password=Nginx1122! controller_fqdn=controller1.ddns.net"
       ``` 
    2. Scripted Equivalent:
       **sh 2-run-nginx_controller_agent_3x-playbook.sh**

## Configure Load Balancing Within Controller GUI

1. Go back to the Controller GUI and go to the Infrastructure>Graphs page
2. Wait for the new instance to appear and then feel free to change the alias by clicking the settings (gear icon) so it is easy for you to find.

### Configure a Gateway.

The Gateway is for traffic aggregation for ingress into the network & nginx instances, which is a collection of server (similar to virtual server) blocks 

3. Click on the NGINX logo and select **Services**.
4. Go to **Gateways**
5. Create a new gateway, call it *yourname*-gw
6. A the bottom, under **Environment**, select **production** and hit next.
7. In the **Placements**, select your NGINX instance, hit next.
8. Under the hostnames, add
   1. http://nginx.ddns.net
   2. https://nginx.ddns.net
   3. Be sure to hit **Done** after adding each URI.
   4. In **Cert Reference** select the **nginx.ddns.net** certificate and then select all **Protocols**.
10. Feel free to view the optional configuration options.
11. Publish the gateway by clicking on **Submit**. Wait on the **Gateways** screen until the gateway status is green.

### Create Apps

Apps are customer specified collection of components/traffic that constitutes an application or microservice. 

12. On the leftmost column hit **Apps** to show the *My Apps* menu and select **Overview** to show the current list of Apps.  Click on  **Create App** under *Quick Actions* or just hit the **Create** button in the upper right.
13. Name your new app *yourname*-app and under **Environment** select the **production**.
14. Hit **Submit**.
15. You should be an taken to an *Overview* of the app you just created.  To see a list of all apps click on **Apps** on the side-bar. 
 
 #### Add Components to your app
 
You need to create Components for your app. Components let you partition an App into smaller, self-contained pieces that are each responsible for a particular function of the overall application.  Components map backend workloads/code/microservices needing traffic routing and services for your app. Each Component contains an ingress definition that includes the fully-qualified domain names (FQDNs) and URIs of servers.  Components are basically a collection of location blocks (paths) and upstreams (server pools).

Components are created from the app overview page. If you are on the **My Apps** overvew page listing all the apps you can get to your app overview page by clicking on the app link or hovering over the app box which will expose the following icons to the far right, Delete (trash can), Edit (pen and paper), View (eyeball).  Selecting **View** will also take you to the overview page for that specific app.  Hit **Create Component** in the upper-right or select **Create Component** under *Quick Actions* on the inner side-bar.

16. In the **Configuration** section *Name* the first component **time1**.
17. In the **Gateways** section, select your gateway you configured earlier. **It is important you select only the gateway you created**
18. In the **URIs** section, select **Add URI** (link is on top right of screen) and enter the *URI*: **/time1**
19. *Important* hit **Done** in the URI box.
20. Click **Next** through the optional configuration items until you get to **Workload Groups**.  

**Workload Group**s, aka *upstream* in NGINX are server pools that you can proxy request to.  They are commonly used for defining either a web server cluster for load balancing, or an app server cluster for routing / load balancing.

21. In **Workload Groups**, in *Workload Group Name* enter **time1**.

**Backend Workload URIs** are the servers that comprise the Workload Group, aka upstream server, (ie. pool member)

22. Add the backend workload URI: <http://3.20.98.115:81>
23. Be sure to hit **Done** in the *URI* box after adding the URI.
24. Hit **Submit**.
25. Wait for the *green* **Status:** Configured next to time1 in the app Overview page or Components section.  If it spins for more than a couple of minutes just hit refresh to see if it finished.

#### Check your work

26. Go to UDF Deployment page and under the nginx-plus VM, go to the **Access** drop-down and open the **Web Shell**.  At the command prompt.
    1. **curl localhost/time1**
       1. This should return the timestamp page for API_SERVER: API1
27. View the changes made to /etc/nginx/nginx.conf on your host.
    1. **sudo nginx -T**
       1. You should see an **upstream time1_http...** section with your **server** 3.20.89.115:81 in it.
28. Add another component to your app named **time2**, with a URI of **/time2** using the server <http://3.1.50.39:82> by repeating steps 24-35.
    1. Go back to the **Web Console**
       1. **curl localhost/time2**
          1. 1. This should return the timestamp page for API_SERVER: API**2**
       2. **sudo nginx -T**
          1. You should see a new upstream section for time2

#### Create a load balanced component

29. Add another component and name it **both**.
30. Select your gateway.
31. In the URI section add: **/both**
32. Click **Done**.
33. Click on **Workload Groups** and add a workload group called **both** with a uri of **/both**
34. Add both of our backend workoad URIs:
    1. <http://3.20.98.115:81>
    2. <http://3.1.50.39:82>
35. Test the new configuration with a few curl commands on your SSH session:
    1. **curl localhost/time1**
    2. **curl localhost/time2**
    3. **curl localhost/both**
       1. Run it several times to see the round robin functionality
    4. **curl -k <https://localhost/both>**
       1. Showing that https is working.


## Configure API Management

1. Navigate to Services>APIs and view the workload group. (ergast.com:80)
2. On API Definitions create your "F1 Yourname" API with base path /api/f1
3. Hit save and add URI /seasons and /drivers. Enable documentation with response 200 and {"response":"2009"} as an example (you can make this up, it is just for future developers who might consume this API resource)
4. Click Add A Published API f1_api in Production and select the app you created earlier (yourname-app).
5. Scroll to the bottom and add the routes to the resources we created.
6. Publish and wait for the success message.
7. curl a few of these examples:

   ```
      curl -k http://localhost/api/f1/seasons
      curl -k http://localhost/api/f1/drivers
      curl -k http://localhost/api/f1/drivers.json
      curl -k http://localhost/api/f1/drivers/arnold.json
   ```

8. Edit your published API and add a rate limit policy.
9. Publish and test a couple more requests.
10. Review the JWT Identity Provider under the API Managment Section. A JWT has been configured. It is in this repo, named auth_jwt_key_file.jwk.
11. Go back to your API Definition and edit your published API to require an Authentication Policy using the JWT Provider.
12. Publish and test a curl command (below) using the authorization token or do a "**sh 3-run-jwt-curl.sh**".

   ```
       curl -H "Authorization: Bearer   eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJuYW1lIjoiUXVvdGF0aW9uIFN5c3RlbSIsInN1YiI6InF1b3RlcyIsImV4cCI6IjE2MDk0NTkxOTkiLCJpc3MiOiJNeSBBUEkgR2F0ZXdheSJ9.lJfCn7b_0mfKHKGk56Iu6CPGdJElG2UhFL64X47vu2M" localhost/api/f1/seasons
   ```
   
Extra credit, if you have time:

1. Add an alert for too many 500 errors.
2. Create a dashboard that you think might be useful in a NOC.
3. Access the Developer API Management Portal: <http://3.16.124.236:8090/docs>
Feel free to browse around the GUI to see other functionality.
