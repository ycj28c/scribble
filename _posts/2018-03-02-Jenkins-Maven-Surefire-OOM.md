---
layout: post
title: Jenkins Maven Surefire OOM
disqus: y
share: y
categories: [Test, Devops]
tags: [Sonar, OOM]
---

Issue
-----
Use Eclipse run single Junit test and run whole Junit test are ok, but when run in jenkins, the Junit test is not able to complete only, the console alert the below error
```bash
Exception in thread "ThreadedStreamConsumer" java.lang.OutOfMemoryError: Java heap space
	at java.lang.AbstractStringBuilder.<init>(AbstractStringBuilder.java:68)
	at java.lang.StringBuffer.<init>(StringBuffer.java:128)
	at org.apache.maven.plugin.surefire.report.PrettyPrintXMLWriter.escapeXml(PrettyPrintXMLWriter.java:134)
	at org.apache.maven.plugin.surefire.report.PrettyPrintXMLWriter.writeText(PrettyPrintXMLWriter.java:126)
	at org.apache.maven.plugin.surefire.report.PrettyPrintXMLWriter.writeText(PrettyPrintXMLWriter.java:108)
	at org.apache.maven.surefire.shade.org.apache.maven.shared.utils.xml.Xpp3DomWriter.write(Xpp3DomWriter.java:64)
	at org.apache.maven.surefire.shade.org.apache.maven.shared.utils.xml.Xpp3DomWriter.write(Xpp3DomWriter.java:56)
	at org.apache.maven.surefire.shade.org.apache.maven.shared.utils.xml.Xpp3DomWriter.write(Xpp3DomWriter.java:56)
	at org.apache.maven.surefire.shade.org.apache.maven.shared.utils.xml.Xpp3DomWriter.write(Xpp3DomWriter.java:42)
	at org.apache.maven.plugin.surefire.report.StatelessXmlReporter.testSetCompleted(StatelessXmlReporter.java:134)
	at org.apache.maven.plugin.surefire.report.TestSetRunListener.testSetCompleted(TestSetRunListener.java:131)
	at org.apache.maven.plugin.surefire.booterclient.output.ForkClient.consumeLine(ForkClient.java:105)
	at org.apache.maven.plugin.surefire.booterclient.output.ThreadedStreamConsumer$Pumper.run(ThreadedStreamConsumer.java:67)
	at java.lang.Thread.run(Thread.java:745)
```
ps: how it run in local
```bash
# may need mvn build dependency first
mvn eclipse:eclipse
# run test
mvn clean cobertura:cobertura sonar:sonar -Ddeployment.environment=jenkins -DskipTests=false -Dlogback.level=ERROR -fn
```

Troubleshot
-----------
The Heap space usually because the JVM exhausted the memory, tried did below configuration:
1.config memory in /module/pom.xml

```bash
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-surefire-plugin</artifactId>
	<configuration>
		<argLine>-Xms1024m -Xmx2048m</argLine>
		<includes>
			<include>**/*Test.java</include>
			<include>**/*Tests.java</include>
		</includes>
		<excludes>
			<exclude>**/*IT.java</exclude>
		</excludes>
		<skipTests>${skipTests}</skipTests>
	</configuration>
</plugin>
```
2.set maven jvm memory

```bash
jenkins -> API Sonar -> Build -> Advance -> MAVEN_OPTS 
add "-Xmx2048m"
```

3.others attempts

```bash
# add maven debug mode (but no useful information print out)
mvn  -e
# output heapdump, (but it is in jenkins slave)
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=E:/
# check jenkins memory / slave memory
# we are using the dev-ubuntu-build-2 jenkins slave, which is 8G memory VM, we can customize the slave by add JAVA_ARGS="-Xmx2048m", but it is controlled by IT
```

Big Found
---------
Tried download and check the console log, no clue, but find that the failed tests usually fail at the same step, and the log size is about 1G. Then I found below link:
https://stackoverflow.com/questions/8630091/jenkins-goes-out-of-heap-outofmemoryerror-when-the-tests-print-a-lot-of-log-me
```
First of, the surefire plugin by default forks a new JVM for running tests, and this JVM does not inherit JVM properties of the maven JVM, i.e. if you've set the maven process to have 2048MB Max Heap, it will not be set for the JVM forked by the surefire plugin.
So for setting JVM args of the forked JVM, use the 'argLine' property of the surefire plugin. That way you'll be able to set the Max heap for the forked JVM and not the maven JVM.

Secondly, It looks like the surefire plugin redirects the stdout/stderr and keeps the contents of stuff written to these 2 streams in memory, that's why you may be running out of memory.
So you can also try setting 'redirectTestOutputToFile' property to 'true', that way all sdtout goes to a file, may be that will avoid storing the stream contents in memory,
Or try setting the forkmode='always', that way it will fork one JVM per test-class, keeping the memory consumption from piling up, one test after another.
```

The issue is only when we use combination jenkins + surefire maven test, the surefire output will stay in jenkins node memory!!! That's why when we have big log output, consume all the memories of jenkins node.

Solution
--------
Reduce the log print, add "-Dlogback.level=ERROR" maven command

Result
------
It only print 53MB after changing log level (before is 800MB-2G), and it can complete test in 1h35m, it could take 4 hours before.


Reference
---------
[java.lang.OutOfMemoryError: Java heap space in Maven](https://stackoverflow.com/questions/4066424/java-lang-outofmemoryerror-java-heap-space-in-maven)

[How do I increase the amount of memory available to Maven when it runs the test cases?](https://confluence.slac.stanford.edu/pages/viewpage.action?pageId=38246)

[java.lang.OutOfMemoryError: PermGen with Jenkins and Maven](https://stackoverflow.com/questions/20852013/java-lang-outofmemoryerror-permgen-with-jenkins-and-maven/20876642)

[Builds failing with OutOfMemoryErrors](https://wiki.jenkins.io/display/JENKINS/Builds+failing+with+OutOfMemoryErrors)

[How do I give Jenkins more heap space when it's running as a daemon on Ubuntu?](https://stackoverflow.com/questions/14762162/how-do-i-give-jenkins-more-heap-space-when-its-running-as-a-daemon-on-ubuntu)

[Java.lang.OutOfMemoryError: Java heap space when loading jobs on Jenkins](https://stackoverflow.com/questions/25371965/java-lang-outofmemoryerror-java-heap-space-when-loading-jobs-on-jenkins)

[How do I give Jenkins more heap space when it's running as a daemon on Ubuntu?](https://stackoverflow.com/questions/14762162/how-do-i-give-jenkins-more-heap-space-when-its-running-as-a-daemon-on-ubuntu)

[Jenkins goes out of heap (OutOfMemoryError) when the tests print a lot of log messages to System.out](https://stackoverflow.com/questions/8630091/jenkins-goes-out-of-heap-outofmemoryerror-when-the-tests-print-a-lot-of-log-me)

[out of memory when logging more messages than heap size](https://issues.apache.org/jira/browse/SUREFIRE-938)

[java.lang.OutOfMemoryError: Java heap space in Maven](https://stackoverflow.com/questions/4066424/java-lang-outofmemoryerror-java-heap-space-in-maven)
