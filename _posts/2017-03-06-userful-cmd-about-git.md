---
layout: post
title: Userful Cmd About Git
disqus: y
share: y
---

Some useful commands about git, keep updating:


There are 3 levels of git config; project, global and system.
[Stackoverflow.com](http://stackoverflow.com/questions/8801729/is-it-possible-to-have-different-git-config-for-different-projects)
project: Project configs are only available for the current project and stored in .git/config in the project's directory.
global: Global configs are available for all projects for the current user and stored in ~/.gitconfig.
system: System configs are available for all the users/projects and stored in /etc/gitconfig.

Create a project specific config, you have to execute this under the project's directory:
```
$ git config user.name "John Doe" 
```
Create a global config:
```
$ git config --global user.name "John Doe"
```
Create a system config:
```
$ git config --system user.name "John Doe" 
```












