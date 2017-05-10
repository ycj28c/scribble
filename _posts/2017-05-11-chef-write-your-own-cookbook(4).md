---
layout: post
title: Chef Write Your Own Cookbook(4)
disqus: y
share: y
---

Purpose
-------------------------
Recently want to learn something about front, react seems a popular framework, ruan yifeng has a good material for learning [React Tech Stack](http://www.ruanyifeng.com/blog/2016/09/react-technology-stack.html), he also provide the code exmaple, I want to deploy it in my aws tomcat node, what I need to do?

I will use **chef12 + knife + tomcat8** for this custom cookbook.

Install The Tomcat Cookbook
-------------------------

We are not write the tomcat cookbook from the very begining, there already has tomcat cookbook we can use directly use. This tomcat cookbook is like the concept of libary, we will wrap this cookbook for our custom requirment.

Go to chef supermarket, find the [tomcat cookbook](https://supermarket.chef.io/cookbooks?utf8=%E2%9C%93&q=tomcat&platforms%5B%5D=)

Install tomcat by your chef-workstation

```bash
# install the tomcat cookbook
cd ~/chef-repo
knife cookbook site install tomcat
# knife will generate cookbook in ~/chef-repo/cookbooks/tomcat
```

Sync the cookbook to chef-server

```bash
cd ~/chef-repo
knife cookbook upload tomcat
```

Create CookBook Use knife
-------------------------

Now we have the tomcat cookbook, to automatically setup the ruan yifeng react demo into tomcat, we need to write our own cookbook.

In your chef-workstation, do below:

```bash
cd ~/chef-repo
# you may need to export editor first
# $export EDITOR=vi

# create aws-tomcat cookbook
cd cookbooks
chef generate cookbook aws_tomcat
```

Now we can use git to download the runyifeng react demos

```bash
cd ~/chef-repo/cookbooks/aws_tomcat
# file must put in {cookbookname}/files/default
mkdir files/default
cd files/default
# copy the ruanyifeng react demo
git clone https://github.com/ruanyf/react-demos.git
```

Then, we need to add some ruby code for our tomcat deployment

```bash
cd aws_tomcat/recipes
vi default.rb
```

Add below code to default.rb

```ruby
#
# Cookbook:: aws_tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'java'
include_recipe 'tomcat'

user 'chefed'

# put chefed in the group so we can make sure we don't remove it by managing cool_group
group 'cool_group' do
  members 'chefed'
  action :create
end

# Install Tomcat 8.0.43 to the default location
tomcat_install 'helloworld' do
  tarball_uri 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.43/bin/apache-tomcat-8.0.43.tar.gz'
  tomcat_user 'cool_user'
  tomcat_group 'cool_group'
end

# Install Tomcat 8.0.43 to the default location mode 0755
tomcat_install 'dirworld' do
  dir_mode '0755'
  tarball_uri 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.43/bin/apache-tomcat-8.0.43.tar.gz'
  tomcat_user 'cool_user'
  tomcat_group 'cool_group'
end

# Install the sample web app
remote_file '/opt/tomcat_helloworld/webapps/sample.war' do
  owner 'cool_user'
  mode '0644'
  source 'https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war'
  checksum '89b33caa5bf4cfd235f060c396cb1a5acb2734a1366db325676f48c5f5ed92e5'
end

# copy the ruan yifeng react demos into sample web app
remote_directory '/opt/tomcat_helloworld/webapps/sample/react-demos' do
 source 'react-demos'
 owner 'cool_user'
 mode '0755'
end

# start the helloworld tomcat service using a non-standard pic location
tomcat_service 'helloworld' do
  action [:restart, :enable]
  env_vars [{ 'CATALINA_PID' => '/opt/tomcat_helloworld/bin/non_standard_location.pid' }, { 'SOMETHING' => 'some_value' }]
  sensitive true
  tomcat_user 'cool_user'
  tomcat_group 'cool_group'
end
```

Sync The Cookbook
-------------------------

```bash
cd ~/chef-repo
knife cookbook upload tomcat
```
Now the java cookbook is in chef-server now, we need to assgin the cookbook to client node to let our cookbook working. Go to your chef server web, [Chef Server](https://api.chef.io). 

In Nodes -> choose your client node -> Actions -> Edit Run List -> add java to run List
![chef-noderunlist](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/chef4/chef-tomcatcookbook.png)

We must put dependency library in(put both tomcat and aws_tomcat cookbooks)

Run The Cookbook In Client
-------------------------

Now everything ready, let's run the cookbook. Login into our AWS client node.
```bash
# run chef-client to run all the cookbook in run list
sudo chef-client
```

Now can visit ruanyifeng react demos by:

[dmoe01](http://54.219.129.91:8080/sample/react-demos/demo01/index.html)

[dmoe02](http://54.219.129.91:8080/sample/react-demos/demo02/index.html)

[dmoe03](http://54.219.129.91:8080/sample/react-demos/demo03/index.html)

[dmoe04](http://54.219.129.91:8080/sample/react-demos/demo04/index.html)

etc.

Congraturation!
