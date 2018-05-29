---
layout: post
title: Tomcat Hanging Issue
disqus: y
share: y
categories: [Devops]
tags: [Java, Tomcat]
---

Environment
-----------
Centos 7
Postgres 9.4
Tomcat 7 
Java 8
SpringBoot 1.1.9.RELEASE
Hibernate 5.0.3.Final
Nginx use as LBS for 4 tomcat nodes

Issue Description
-----------------
Recent the tomcat stop responding very frequently. This blog is about how to locate the issue.

Here is list of issues we observation:
* When applcation hanging, if we send a new request, it just keep loading, but not do anything until timeout and return error
* There are no error in the tomcat log (catalina.out, applicaiton log, local acceess etc.) 
* We have two appliation runs in each tomcat node, only one of it not responding, another one works well
* Tomcat server load is low, cpu/memory/swap all looks fine
* Postgres Database in not in high pressure, each tocmat node has about 10 connections connect
* Lot of CLOSE_WAIT TCP connection runs in tomcat port, and they are not disappear unless stop tomcat(later we found because db block, the new db connection request will be CLOSE_WAIT status)

After some investigation, we also found
* The hanging application still able to respond the non-db API request such as /info
* When we run a script in multi threads environment like 20 threads, can reproduce the issue (scripts will call Tomcat api to complete task)



Troubleshoot
-----------------

Let me write conclusion first, finish the blog later:

We use hibernate, the hibernate database config in code with spring
```
	@Bean
	public DataSource dataSource() {
		BasicDataSource dataSource = new BasicDataSource();
		dataSource.setDriverClassName(env.getProperty("jdbc.driverClassName"));
		dataSource.setUrl(env.getProperty("jdbc.url"));
		dataSource.setUsername(env.getProperty("jdbc.username"));
		dataSource.setPassword(env.getProperty("jdbc.password"));
		return dataSource;
	}
	
	@Bean
	public LocalSessionFactoryBean sessionFactory() {
		LocalSessionFactoryBean sessionFactory = new LocalSessionFactoryBean();
		sessionFactory.setDataSource(dataSource());
		sessionFactory.setPackagesToScan(new String[] { "com.equilar.international" });
		sessionFactory.setHibernateProperties(hibernateProperties());
		sessionFactory.setMappingLocations(loadResources());
		return sessionFactory;
	}
```

The issue is BasicDataSource, based on https://commons.apache.org/proper/commons-dbcp/configuration.html, the default max database connection for BasicDataSource is 8, which is not enough, add the maxActive parameter, solve the issue.
```
	@Bean
	public DataSource dataSource() {
		BasicDataSource dataSource = new BasicDataSource();
		dataSource.setDriverClassName(env.getProperty("spring.datasource.driverClassName"));
		dataSource.setUrl(env.getProperty("spring.datasource.url"));
		dataSource.setUsername(env.getProperty("spring.datasource.username"));
		dataSource.setPassword(env.getProperty("spring.datasource.password"));
		/*
		 * Add the pool size configuration, 
		 * The default maxActive is 8 according to https://commons.apache.org/proper/commons-dbcp/configuration.html
		 */
		dataSource.setMaxActive(env.getProperty("spring.datasource.max-active", Integer.class));
		dataSource.setInitialSize(env.getProperty("spring.datasource.initial-size", Integer.class));
		return dataSource;
	}
```

Easter Egg
---------
```
## A script to restart tomcat when it hanging
curl -v http://10.10.10.10/api/health --max-time 30 || (echo "tomcat is hanging" && curl -X POST --data-urlencode "payload={\"channel\": \"#slackchannel\", \"username\": \"I'm Broken\", \"text\": \"*Restarting 10.10.10.10 Tomcat Because API Hanging*\", \"icon_emoji\": \":scream:\"}" https://hooks.slack.com/services/TTTTTTTTT/BBBBBBBBBBBBBBBBBBBBBBBBBBBBB)
```

Reference
---------
1. [How to Debug / Log Tomcat JDBC Connection Pool's connections?](https://stackoverflow.com/questions/36587023/how-to-debug-log-tomcat-jdbc-connection-pools-connections)

2. [jConsole – JMX remote access on Tomcat](https://www.mkyong.com/tomcat/jconsole-jmx-remote-access-on-tomcat/)
