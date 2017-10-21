---
layout: post
title: Use Which Java Logs
disqus: y
share: y
categories: [Language]
tags: [Java, Log]
---

There are many options for Java logs, never consider about use which before, today migrate old log4j to logback, have more understanding about those log librarys.

# Introduce Java Log Libs
Here is the list and simple description of difference:
+ Log4J: the oldest library, has stop updating.
+ Log4J2: similar name, but not same authur, better performance than log4j and logback in multiple threads.
+ Logback: good performance, same author of log4j, so easily compatible with log4j.
+ Common-logging: it is abstract layer, no really do logging.
+ SLF4J: most popular, can use as bridge/factory which can easily compabile with different log libs.

# Migrate Log4j To Logback
Log4j is common use in old system and many old libraries, since logback has good performance and it good compatible with log4j, so we decide use logback + slf4j to upgrade. Here are the steps:

1. exclude the log4j

```
<dependency>
<groupId>${project.groupId}</groupId>
<artifactId>InsightDomainObject</artifactId>
   <exclusions>
       <exclusion>
           <groupId>log4j</groupId>
           <artifactId>log4j</artifactId>
       </exclusion>
   </exclusions>
</dependency>
```
 
2. make sure has logback classic and slf4j api dependency 

they are already include in springboot, check your dependency hierarchy, if don't include add below into pom.xml

```
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>${slf4j-version}</version>
</dependency>

<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-core</artifactId>
    <version>${logback-version}</version>
</dependency>

<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>${logback-version}</version>
</dependency>
```
 
3. change the log4j format to logback format in code

```
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
==>
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Level;
 
private static final Logger LOGGER = Logger.getLogger(xxx.class);
==>
private static final Logger LOGGER = LoggerFactory.getLogger(xxx.class);
```
 
4. fix the compatible issue

such as replace the fatal with error(fatal no support in logback), replace and getLevel() method and other compatible issue
 
5. deployment

Replace the log4j.xml by logback.xml. Use this online tool, convert your existing Log4j configuration to Logback. In Maven projects the file logback.xml must be placed into $PROJECT_HOME/src/main/resources. The file logback-test.xml must be placed into $PROJECT_HOME/src/test/resources. A simple configuration looks like this: 

```
If you do not have a custom configuration, Logback will continue with its default configuration. If you prefer to have a custom configuration, add logback.xml to the classpath with a similar configuration.
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="false">

    <contextListener class="ch.qos.logback.classic.jul.LevelChangePropagator" />

    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n
            </pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>output.log</file>
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n
            </pattern>
        </encoder>
    </appender>

    <root level="DEBUG">
        <appender-ref ref="STDOUT" />
        <appender-ref ref="FILE" />
    </root>

</configuration>
```
