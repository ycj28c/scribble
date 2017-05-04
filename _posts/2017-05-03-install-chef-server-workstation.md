---
layout: post
title: Install Chef Server And Workstation
disqus: y
share: y
---

Purpose
-------------------------
Chef is the most popular devops tools currently, it help us quickly establish the environment. I will use it for my AWS nodes management. Install will contains below parts:

* Install the Chef-Server
* Install the Chef-Workstation
* Install the Client nodes

After infrastructure is setup, you will need to
* Write cookbook/environment/attribute.. in workstation.
* upload to chef-server, assign cookbook to nodes.
* run chef-client in nodes and everything will done.

Lot of resource on Internet are chef11, they are no longer works in chef12. I successfully setup up chef in AWS + Ubuntu14.04 + Chef 12.2.0. 

Chef-Server Install
-------------------------
There are opensource chef-server and hosted chef-server options, the hosted chef-server fees are below:

Price Of Hosted Chef-Server:
- Launch package: $120/month, 20 nodes, 10 users
- Standard package: $300/month, 50 nodes, 20 users
- Premium package: $700/month. 100 nodes, 50 users
All these tiers are exceedingly expensive for most small and medium sized organizations. There is a small reprieve, however-- as mentioned earlier, one can get the full Enterprise Hosted Chef on free trial basis for up to 5 nodes, 2 users, with no support included.

If you want to use the hosted chef-server, you can skip chef-server install, go directly to chef-workstation, elsewise, do as below(At least 4G physical memeory, 2 core cpu for chef-server):

```bash
//ssh to your server
ssh -i "secret.pem" ubuntu@ec2-xxxxxx.compute.amazonaws.com

//download chef-server here https://downloads.chef.io
cd /tmp
wget https://packages.chef.io/files/stable/chef-server/12.2.0/ubuntu/14.04/chef-server-core_12.2.0-1_amd64.deb
//install the chef server core
sudo dpkg -i /tmp/chef-server-core_12.2.0-1_amd64.deb
//configure chef-server
sudo chef-server-ctl reconfigure

//install chef-manage, chef ui tool("chef-server-ctl install opscode-manage" not work)
sudo dpkg -i chef-manage_2.4.3-1_amd64.deb
sudo chef-manage-ctl reconfigure --accept-license
sudo chef-server-ctl reconfigure
//now you able to connect chef-manage web ui by https://{chef-server-ip}

//check chef server/manage status
sudo chef-manage-ctl status
sudo chef-server-ctl status
```

Add Orgnize And User
-------------------------
Then, you need to add the orgnize and users, two ways, through chef-manage web ui or below commands:
```bash
mkdir .chef
sudo chef-server-ctl user-create admin admin admin admin@xxx.com password -f ~/.chef/admin.pem
sudo chef-server-ctl org-create xxx "admin@xxx.com" --association_user admin -f ~/.chef/xxx.pem
```

Chef-Workstation Install
-------------------------
You can install the chef-workstation in one server as chef-server or install in different server.

```bash
//ssh to your server
ssh -i "secret2.pem" ubuntu@ec2-yyyyyy.compute.amazonaws.com
//install the Chef client DK or Chef client(Chef Client Dk has all the functions chef client has), in addition, it provide some advance functions for developer developing cookbook and debug cookbook.

//chef client dk example
//sudodpkg -i chefdk_0.17.17-1_amd64.deb

//here I install the chef-client
curl -L https://www.opscode.com/chef/install.sh | sudo bash

//verify chef client installed
chef-client -v

//download start-kit in chef-server web ui, upload to chef-workstation server(Administrator -> organizaion -> Starter Kit -> Download Starter Kit)

//unzip chef-repo and copy to chef-workstation, here I install in /home/ubuntu
scp -i secret2.pem -r chef-repo ubuntu@ec2-yyyyyy.compute.amazonaws.com:/home/ubuntu

//now we can use knife in chef-repo folder

//download chef certificate
cd ~
cd chef-repo/
knife ssl fetch

// add chef to global environment path
echo 'export PATH="/opt/chef/embedded/bin:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

//verify chef workstation
knife client list
knife user list
```

Now, the chef infrastructure has established.

Reference
-------------------------
http://blog.csdn.net/chancein007/article/category/6419332

http://www.bogotobogo.com/DevOps/Chef/Chef_Server_install_on_EC2_ubuntu_14_04.php

https://docs.chef.io/install_server.html

http://chadwick.wikidot.com/chefinstallation
