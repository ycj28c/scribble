---
layout: post
title: Git Cheat Sheet
disqus: y
share: y
categories: [Devops]
tags: [Git]
---

Git管理的系统学习

Previous Blog [USEFUL CMD ABOUT GIT](https://ycj28c.github.io/devops/2017/03/06/useful-cmd-about-git/)

Basic Git Config
----------------
```
$ git config --global user.name
# 修改全局的user.name
$ git config --global user.name "myusername"

$ git config --global user.email
# 修改全局的user.email
$ git config --global user.email "myemail@gmail.com"

# 显示目前的所有设置
$ git config --list
$git config user.name

# 直接修改文件
$ cat .gitconfig

# 修改默认文本编辑器
$ git config --global core.editor "atom --wait"
# 颜色比较丰富（默认）
$ git config --global color.ui true
```

Init Git Directory
------------------
```
$ mkdir first_git
$ cd first_git
$ git init
# 这里可以拷贝旧项目文件到该git目录中去了，或者直接在以后目录下git init

# 查看该git directory设置，.git用来tracking全部信息
$ cat .git/config
```

Git Architecture
----------------
```
# repository就是本地完成commit的持久化的目录
# staging index准备commit的本地文件，可以持续的添加文件
# working就是本地的repository，就是各种branches的临时文件

working copy -- git add file.txt --> staging index -- git commit file.txt --> repository

Head就是当前的branch位置，git checkout一下就行切换
```

Make File Changes
-----------------
```
# add some file in first_git
# 查看目前Head的状态，untracked的文件，hash等
$ git status

# 增加文件
# 提交全部修改
$ git add .
# 提交整个tour目录下文件
$ git add tour/
# 只提交second_file.txt
$ git add second_file.txt
# unstage文件
$ git reset HEAD second_file.txt
# 提交文件到repository
$ git commit -m "Add second file to project"

# 删除文件
# 手动删除文件second_file.txt
# 告诉git去跟踪文件
$ git rm second_file.txt
# 用git删除文件，命令一样，相当于手动删除 + 告诉git
$ git rm second_file.txt

# 修改文件
# 手动修改一个文件second_file.txt，重命名为secondary_file.txt
$ git mv second_file.txt secondary_file.txt
# 同理，可以直接用git mv命令直接重命名
```

Git Diff
--------
```
# 手动修改文件second_file.txt
# 查看working space修改了什么diff（增删改），不过不是很明显
$ git diff

# 查看staging的修改（只显示staging的文件diff）
$ git diff --staged
# 和--staged完成一样的--cached命令，Alias
$ git diff --cached

# 比较两个repository中commit的修改
$ git diff lc15863C..9dgce135ds --color-words
$ git diff lc15863C..HEAD --color-words
```

Git Log
-------
```
# 查看git历史
$ git log
# 显示最近的5个commit
$ git log -n 5
# 显示从2020-01-01开始的记录
$ git log --since=2020-01-01
# 显示某人的提交
$ git log --author="Kevin"
# 查看commit包含"Init"的记录（所以写好commit message很重要）
$ git log --grep="Init"
# 查看某个commit的具体修改(接上部分Hash值）
$ git show 6b334fdfdd144746a96d24aa0c5cd9ccbb0c3fa5
# 然后用f,b,u,d进行移动
```

Undo Changes
------------
```
# 取消discard修改
# 取消working space对index.html的修改(--表示当前branch）
$ git checkuot -- index.html

# 取消staging，也就是unstage
# 取消全部tour目录下的stage
$ git reset HEAD tours/
# unstage单个文件
$ git reset HEAD index.html
# 重置暂存区staging与working space，与上一次commit保持一致
$ git reset --hard

# 修改commit（只能修改最近的那个Head指向的stage index）
$ git commit --amend -m "change the commit message here"
# 感觉用处不大

# 修改repository到老版本（用处不大） 
# 通常是要重新提交一个新版本，比较容易跟踪
# 用来返回某个文件版本，看看原来文件的样子
$ git checkout d445sfg345 -- index.html

# 取消一个在repository的commit（其实就是重新提交一个commit）
# revert某个hash版本46dghj454
$ git revert 46dghj454
```

Git Ignore
-----------
```
# 通常需要每个project设置一个单独的.gitignore便于管理
# 全局ignore
$ git config --global core.excludesfile ~/.gitignore_global

# ignore已经stage的file 
# 如果之前的gitignore没有写db_config.txt，需要这么写
# git rm --cached db_config.txt

# 如果保留和跟踪empty directory？
# 比如空文件夹是explores，在里面增加.gitkeep文件即可
# 在linux下用touch最简单（如果文件存在就修改日期，否则创建新的）
$ touch explores/.gitkeep
```

Git Branch Management  
```
# 列出所有本地分支
$ git branch
# 列出所有远程分支
$ git branch -r
# 列出所有本地分支和远程分支
$ git branch -a
# 新建一个分支，但依然停留在当前分支
$ git branch [branch-name]
# 新建一个分支，并切换到该分支
$ git checkout -b [branch]
# 新建一个分支，指向指定commit
$ git branch [branch] [commit]
# 新建一个分支，与指定的远程分支建立追踪关系
$ git branch --track [branch] [remote-branch]
# 切换到指定分支，并更新工作区
$ git checkout [branch-name]
# 切换到上一个分支
$ git checkout -
# 建立追踪关系，在现有分支与指定的远程分支之间
$ git branch --set-upstream [branch] [remote-branch]
# 合并指定分支到当前分支
$ git merge [branch]
# 选择一个commit，合并进当前分支
$ git cherry-pick [commit]
# 删除分支
$ git branch -d [branch-name]
# 删除远程分支
$ git push origin --delete [branch-name]
$ git branch -dr [remote/branch]
```

Git Remote
---------
[Ralph Git Practice.pptx](https://github.com/ycj28c/Automation_Practice/blob/master/Documents/%5BAT%20Ralph%5D%20Git%20Practice.pptx)
```
# 下载远程仓库的所有变动
$ git fetch [remote]
# 显示所有远程仓库
$ git remote -v
# 显示某个远程仓库的信息
$ git remote show [remote]
# 增加一个新的远程仓库，并命名
$ git remote add [shortname] [url]
# 取回远程仓库的变化，并与本地分支合并
$ git pull [remote] [branch]
# 上传本地指定分支到远程仓库
$ git push [remote] [branch]
# 强行推送当前分支到远程仓库，即使有冲突
$ git push [remote] --force
# 推送所有分支到远程仓库
$ git push [remote] --all
```

Git Stash
---------
```
# 用户本地开发文件的临时管理，比如改了一些文件，又要临时去checkout其他branch了
# 保留当前working space到stash
$ git stash
# 还可以添加信息
$ git stash save "temp save"
# 查看所有stash
$ git stash list
# 将stash中的文件移动到working space（会删除该stash）
$ git stash pop
# 恢复指定的stash
$ git stash pop stash_id
# 恢复stash，但是不删除该stash
$ git stash apply stash_id
# 删除某个stash
$ git stash drop stash_id
# 删除所有stash
$ git stash clear
# 检查stash和目前HEAD的区别
$ git stash show
```

Git Bisect
----------
```
#主要的应用场景是不知道某个commit搞坏系统了，用二分法逐渐逼近排查
# 设定排查范围，从HEAD到commit 4d83cf
$ git bisect start HEAD 4d83cf
# 如果没有问题，告之good
$ git bisect good
# 如果有问题，告之bad
$ git bisect bad
# 最后git会定位到唯一的错误版本“b47892 is the first bad commit”
# 中途退出差错，就恢复到HEAD版本了
$ $ git bisect reset
```

Git Rebase
---------
前提：不要通过rebase对任何已经提交到公共仓库中的commit进行修改。  
因为这是比较危险的指令，因为各个客户端code不一致，可能导致某个客户端code丢失。  
如果只是复制某一两个提交到其他分支，建议使用更简单的命令:git cherry-pick，就是增加的方式。   

应用场景主要针对本地过多meanless的commit，将之合并，是本地的commit更加清晰。或者某个只有自己操作的branch。
```
# 修改离HEAD最近的4个commit
$ git rebase -i HEAD~4
# 会进入vi模式，和vi操作一样，有pick,drop,edit等指令，有提示

# 继续未完成的rebase
$ git rebase --continue
# 取消现在的rebase
$ git rebase --abort

# 如果用第3方软件比如sourcetree可能看不到变化，最好用git log直接看 
$ git log
```

Git Tag
-------
```
# 列出所有tag
$ git tag
# 新建一个tag在当前commit
$ git tag [tag]
# 新建一个tag在指定commit
$ git tag [tag] [commit]
# 删除本地tag
$ git tag -d [tag]
# 删除远程tag
$ git push origin :refs/tags/[tagName]
# 查看tag信息
$ git show [tag]
# 提交指定tag
$ git push [remote] [tag]
# 提交所有tag
$ git push [remote] --tags
# 新建一个分支，指向某个tag
$ git checkout -b [branch] [tag]
```

Reference
---------
1.[Git Learning Linkedin](https://www.linkedin.com/learning/git-essential-training-the-basics/use-git-version-control-software-to-manage-project-code?resume=false)  
2.[git教程--使用git stash保存和恢复进度](https://blog.csdn.net/longgeaisisi/article/details/101842891?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control)  
3.[git bisect 命令教程](http://www.ruanyifeng.com/blog/2018/12/git-bisect.html)  
4.[常用Git命令清单](https://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)  
5.[彻底搞懂 Git-Rebase](http://jartto.wang/2018/12/11/git-rebase/)


