---
layout: post
title: Tomcat JMX Monitor
disqus: y
share: y
categories: [Devops]
tags: [Java, JMX, Monitor]
---

Backgroud
-----------------
Recently we have Tomcat issue, finally we solve it, this document is about the JMX tool we use to help troubleshoot issue and how to setup.

Server Environment
------------------
Tomcat 7,8 
Linux Centos 7

Local Environment
-----------------
Java 8

Install JMX
-----------------
Here are the steps open JMX monitor for Insight QA(10.10.10.10):
1) add setenv.sh under your tomcat bin directory (/opt/tomcat/bin etc.)

2) add below content into setenv.sh, (please use the same parameters as below, don't use the stuff find on internet, a lot of traps waste your time)

```
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8050 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=10.10.10.10 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.rmi.port=8050"
```

The parameter means we will open the JMX port 8050, don't require ssl and authentication when start Tomcat (if use authenticate, need addition steps for user, please goolge)

3) Open the 8050 port in firewall for 10.10.10.10

4) if you already have Java 8 install in your local, you can use  jconsole and java visual VM tool to begin monitor
run jconsole or jvisualvm native Java tools
here use jconsole as example, the java visual vm configuration is very similar.

5) in the jconsole login, type 10.10.10.10:8050 in remote process, no need for username and password since we didn't set it, click Connect

6) When the tool ask for secure connection, just choose Insecure since we use none SSL

7) now you sucessfully connected to tomcat JMX, it provide lot of useful information help you locate issue

Reference
---------
1.[How to Debug / Log Tomcat JDBC Connection Pool's connections?](https://stackoverflow.com/questions/36587023/how-to-debug-log-tomcat-jdbc-connection-pools-connections)

2.[jConsole – JMX remote access on Tomcat](https://www.mkyong.com/tomcat/jconsole-jmx-remote-access-on-tomcat/)
