---
layout: post
title: Chef Cookbook Management(2)
disqus: y
share: y
categories: [Devops]
tags: [Chef, Cookbook]
---

Purpose
-------------------------
We can have multiple chef workstation to develop our cookbook, thus, must know the sync between the chef server and chef workstation, and it is better to implement the git for cookbook management.

I will use chef12 + knife for my senario

Sync Chef Server And Workstation
-------------------------

+ sync chef server to chef workstation

```bash
# sync environments, cookbooks, roles etc.
cd ~/chef-repo
knife download environments
knife download cookbooks
Knife download roles

# sync all
knife download *
```

+ sync chef workstation to chef server

```bash
# sync aws_tomcat to chef server
cd ~/chef-repo
knife cookbook uplad aws_tomcat
# sync all
knife upload *
```

Cookbook Version Control
-------------------------

I use github for all my cookbook management 

```bash
echo "# Chef-Server-AWS" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/ycj28c/Chef-Server-AWS.git
git push -u origin master

git config user.email "ycj28c@gmail.com"
git config user.name "ycj28c"
```

there are sensitive informant in /nodes and /.chef folder, don't push them

```bash
cd ~/chef-repo
vi .gitignore
# add .chef nodes
```

Simple Cookbook Dev Workflow
-------------------------
1. download cookbook from chef server

2. make change

3. upload to chef server

4. push to git