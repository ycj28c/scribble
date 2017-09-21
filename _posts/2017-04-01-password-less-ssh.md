---
layout: post
title: Password Less SSH
disqus: y
share: y
categories: [OS]
tags: [Ssh]
---

Purpose
-------------------------
Want to ssh to server without password? want to use *.pem ssh server like Amazon EC2? You can find lot of material on internet, but there are some tricky part still.

Backgroup About RSA
-------------------------

We are going to use RSA algorithm create ssh key, here are some backgroup knowledge about RSA algorithm:

[RSA Theory 1 - ruan yifeng](http://www.ruanyifeng.com/blog/2013/06/rsa_algorithm_part_one.html)

[RSA Theory 2 - ruan yifeng](http://www.ruanyifeng.com/blog/2013/07/rsa_algorithm_part_two.html)

Steps For Password Less SSH
-------------------------

```bash
# generate the private and public rsa key
ssh-keygen -t rsa -f test
# it will generate test(private key) and test.pub(public key) in ~/.ssh folder
# if folder not there, you may need to create it, assign 700 permission
# for windows, it will be in C:\Users\username\.ssh folder

# copy the public key to target server, you will ask for password first time
ssh-copy-id -i test.pub username@host
# replace username, host, pem name with your situation
# alternative way1: cat ~/.ssh/test.pub | ssh username@host 'cat >> .ssh/authorized_keys'
# alternative way2: manully create authorized_key and paste the test.pub content

# check the key permisson in both your machine and target server, otherwise it not work!
# .ssh folder: 700 (drwx------)
# test (private key): 600 (-rw-------)
# authorized_keys (public key): 644 (-rw-r--r--)

# after all those done, you can directly connect without password
ssh username@host
```

[Example From Reference][1]

```bash
not-marco@rinzwind-desktop:~$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/not-marco/.ssh/id_rsa): 
Created directory '/home/not-marco/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/not-marco/.ssh/id_rsa.
Your public key has been saved in /home/not-marco/.ssh/id_rsa.pub.
The key fingerprint is:
b1:25:04:21:1a:38:73:38:3c:e9:e4:5b:81:e9:ac:0f not-marco@rinzwind-desktop
The key's randomart image is:
+--[ RSA 2048]----+
|.o= . oo.        |
|*B.+ . .         |
|*=o .   o .      |
| = .     =       |
|. o     S        |
|E.               |
| o               |
|  .              |
|                 |
+-----------------+
not-marco@rinzwind-desktop:~$ ssh-copy-id not-marco@127.0.0.1
not-marco@127.0.0.1's password: 
Now try logging into the machine, with "ssh 'not-marco@127.0.0.1'", and check in:

  ~/.ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.
```

AWS Pem
-------------------------

AWS pem introduce:

[Amazon EC2 Key Pair](http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

Actually Amazon *.pem is the also RSA key, we keep the private key, amazon maintain the public key. However, we can also generate our ssh key use the way above, copy the public key to EC2 node, then you can connect with key you create:

```bash
# generate private key and public key in your local
ssh-keygen -t rsa -f awsnode
# login into ec2 node
# append the public key to aws ec2 node
vi ~/.ssh/authorized_keys
# now in authorized_keys will have two public key, one from Amazon, one from your
# you're able to connect by your own key
ssh -i ~/.ssh/awsnode username@ec2host
```

Reference
-------------------------

[RSA encryption explain](http://honglu.me/2014/11/09/RSA%E5%8A%A0%E5%AF%86%E6%B5%85%E6%9E%90/)

[How can I set up password-less SSH login?](https://askubuntu.com/questions/46930/how-can-i-set-up-password-less-ssh-login)

[1]https://unix.stackexchange.com/questions/4484/ssh-prompts-for-password-despite-ssh-copy-id

