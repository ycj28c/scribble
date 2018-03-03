---
layout: post
title: Out Of Memory Troubleshot
disqus: y
share: y
categories: [Language]
tags: [Oom]
---

Background
----------
Recently has lot of OOM issue, the common part is they all alert "Out Of Memory" alert, the different part all the OOM has different cause. Will list each of them and share some common thoughts.

Run Java Script OOM
-------------------
#### Issue
Has a Java script "MasterCalc.sh", which run with "java -Xmx2048m", the script start at 3AM, failed at 7AM, the error log is "Out Of Memory".

#### Troubleshot
+ First use tool Jmap to dump the memory when OOM happens, find thousands of Company Objects, each take about 0.5% memory, which exhausted all the memory 
+ The MasterCalc.sh will read all the Company Object at beginning, persistent at List<Company> companies, then use multi-threads read Manager into the Company object. 
+ So The issue is at beginning List<Company> only take 500m memory, but 1 Company could have many managers, when looping, the List<Company> memory continue increasing, 4 hours later, run out of the 2G memory.

#### Solution
Change the code, in the multi-Thread loop, new a Company Ojbect as shadow object, which can be released after process is done
```
public MasterCallable(Company mc) {
	Company mcShadow = new Company(mc.getCompanyId());
	mcShadow.setCompanyId(mc.getCompanyId());
	mcShadow.setTicker(mc.getTicker(), mc.getTicker() == DataUtil.DB_NA);
	mcShadow.setCusip(mc.getCusip(), mc.getCusip() == DataUtil.DB_NA);
}
```  

Tomcat alert OOM
----------------
#### Issue
Get exception stack trace in tomcat api server log
```
ERROR: out of memory
  Detail: Failed on request of size 23.; nested exception is org.postgresql.util.PSQLException: ERROR: out of memory
  Detail: Failed on request of size 23.
```

#### Troubleshot
PSQLException is tomcat side exception, but the error "ERROR: out of memory Detail: Failed on request of size 2 " is originally from the Postgres DB, actually the Postgres Out Of Memory.


Run Jenkins Maven Test OOM
--------------------------
#### Issue
We use Jenkins to run maven project for Junit tests, then upload result to Sonar, but get "java.lang.OutOfMemoryError: Heap space" in the Jenkins console

Have below configuration:
```
# project
pom.xml <argLine>-Xms1024m -Xmx2048m</argLine>
```

#### Troubleshot
At beginning we think it is because the tests data set too large cause out of memory, but read the console, didn't find which test fail. Notice all the out of memory Jenkins log is 1G, it is very possible the Jenkins constraints. Since we are maven project, add below config for Maven build:
```
# Job -> Build -> Advanced
MAVEN_OPTS: -Xmx2048m
```

Common Think
------------
1. Analyze memory dump very helpful locate the issue.
2. OutOfMemory may not your application issue, any route could be out of memory, such as Jenkins.
3. If no clue, can always try increase the physical memory or memory configuration.

Reference
---------
[Builds failing with OutOfMemoryErrors](https://wiki.jenkins.io/display/JENKINS/Builds+failing+with+OutOfMemoryErrors)

[How do I give Jenkins more heap space when it's running as a daemon on Ubuntu?](https://stackoverflow.com/questions/14762162/how-do-i-give-jenkins-more-heap-space-when-its-running-as-a-daemon-on-ubuntu)

[java.lang.OutOfMemoryError: Java heap space in Maven](https://stackoverflow.com/questions/4066424/java-lang-outofmemoryerror-java-heap-space-in-maven)

[How do I increase the amount of memory available to Maven when it runs the test cases?](https://confluence.slac.stanford.edu/pages/viewpage.action?pageId=38246)

