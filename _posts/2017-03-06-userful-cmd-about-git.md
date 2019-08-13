---
layout: post
title: Userful Cmd About Git
disqus: y
share: y
categories: [Devops]
tags: [Git]
---

Some useful commands about git, keep updating:


There are 3 levels of git config; project, global and system.[Stackoverflow](http://stackoverflow.com/questions/8801729/is-it-possible-to-have-different-git-config-for-different-projects)
- project: Project configs are only available for the current project and stored in .git/config in the project's directory.
- global: Global configs are available for all projects for the current user and stored in ~/.gitconfig.
- system: System configs are available for all the users/projects and stored in /etc/gitconfig.

Create a project specific config, you have to execute this under the project's directory:
```shell
$ git config user.name "John Doe" 
```
Create a global config:
```shell
$ git config --global user.name "John Doe"
```
Create a system config:
```shell
$ git config --system user.name "John Doe" 
```

For Github, it is using email for user verify
Set your email address with the following command:
```shell
git config --global user.email "your_email@example.com"
```
Confirm that you have set your email address correctly with the following command.
```shell
git config --global user.email
your_email@example.com
```
Set your email address with the following command:
```shell
git config user.email "your_email@example.com"
git config user.email
```

IF you computer change password will effect the git password cache, reset it
```shell
git config –global credential.helper unset
```

Some trick when you revert a branch and want to merge again
```
you need to revert the revert commit, then merge the branch, otherwise you loss the commit that reverted;
```

Delete the local branchs, in this case has key words "improvement"
```
git branch --merged | grep improvement | xargs git branch -D
```

Total line change for person for period of time
```
git log --author="username" --pretty=tformat: --numstat --after="2019-03-01" --before=="2019-05-03"| awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'
```

Total commit for person for period of time
```
git log --author="username" --oneline --after="2019-03-01" --before="2019-05-03" | wc -l
```

Code line change for everyone
```
git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -; done
```

Top 5 Contributor
```
git log --pretty='%aN' | sort | uniq -c | sort -k1 -n -r | head -n 5
```

Find the history information  
```
# For full path names of changed files:
git log --name-only
# For full path names and status of changed files:
git log --name-status
# For abbreviated pathnames and a diffstat of changed files:
git log --stat
```

Reference
---------
[git统计历史上某一段时间代码的修改量](https://blog.csdn.net/zhangphil/article/details/79957197)  
[git代码统计](https://segmentfault.com/a/1190000008542123)
[How to have git log show filenames like svn log -v](https://stackoverflow.com/questions/1230084/how-to-have-git-log-show-filenames-like-svn-log-v)


