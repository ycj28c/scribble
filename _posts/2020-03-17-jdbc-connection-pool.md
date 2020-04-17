---
layout: post
title: JDBC Connection Pool Change Example
disqus: y
share: y
categories: [Database]
tags: [HikariCP]
---

Recently after upgrade to Postgres 12, performance become an sensitive situation. After doing lots of optimization, the performance is getting better, here is an example to improve to our current DB connection.

What DB connection pool we're using now
--------------------------------------

Environment:  
~~~
Java: 1.8
Sprint-boot: 1.1.9.RELEASE
Sprint-core: 4.1.3.RELEASE (Which embodied in spring-boot 1.1.9)
commons-dbcp: 1.4
Hibernate: 5.0.3.Final (We actually use the Hibernate 4.1.3.RELEASE embodied in the spring-boot 1.1.9)
~~~

application configuration code:
--------------------------------------
The db connection is configured at HibernateConfig.java, by default the spring-boot 1.1.9 is using the Tomcat JDBC connection(springboot2 will use hikariCP by default), however, we override the connection in order to compatible with old hibernate code. So right now there are two DB connection source defined at HibernateConfig.java

1. dbcp connection  
Related code below
~~~
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
~~~

This is using the commons-dbcp library (version 1.4)  
~~~
<dependency>
<groupId>commons-dbcp</groupId>
<artifactId>commons-dbcp</artifactId>
</dependency>
~~~

Since we custom the db connection instead of using spring-boot default, so it only accept below properties defined at application.properties:
~~~
spring.datasource.driverClassName
spring.datasource.url
spring.datasource.username
spring.datasource.password
spring.datasource.max-active
~~~

2. Hibernate connection  
Which is used to be compatible with the old code. Related code below
~~~
@Bean
public LocalSessionFactoryBean sessionFactory() {
LocalSessionFactoryBean sessionFactory = new LocalSessionFactoryBean();
sessionFactory.setDataSource(dataSource());
sessionFactory.setPackagesToScan(new String[] { "com.aaa.bbb" });
sessionFactory.setHibernateProperties(hibernateProperties());
sessionFactory.setMappingLocations(loadResources());
return sessionFactory;
}
private Properties hibernateProperties() {
Properties properties = new Properties();
properties.put("hibernate.show_sql", env.getProperty("spring.jpa.hibernate.show_sql"));
properties.put("hibernate.dialect", env.getProperty("spring.datasource.dialect"));
return properties;
}
~~~

It is using the same setting as dbcp setting, in addition to that, hibernate required its own properties defined at application.properties:
~~~
spring.jpa.hibernate.show_sql
spring.datasource.dialect
~~~

What is the pain point
---------------------
1. The connection pool library we use is commons-dbcp, which is old version and low performance as DB connection pool
2. There are only limit configuration/properties we can use to adjust DB connection pool setting

How to improve
--------------
1. Use HikariCP library to replace the commons-dbcp  
HikariCP is a "zero-overhead" production ready JDBC connection pool, it is the best performance JDBC connection pool so far. Can find the performance difference chart at [HikariCP Github](https://github.com/brettwooldridge/HikariCP). In a heavy db connection transaction ( frequently open and close) environment, the performance improvement will be more obvious.

2. Refract the HibernateConfig.java, allow it to accept more custom configuration from properties  
Currently the DB pool configuration only has "max-active" and "initial-size", it is better to refract the code to accept more useful setting parameters such as "connectionTimeout", "idleTimeout", "maxLifetime", "minimumIdle" etc. All the support parameter can also be found here: [HikariCP Github](https://github.com/brettwooldridge/HikariCP)

3. Since we upgrade to postgres 12, it is better to upgrade the Postgres driver as well(which is in the JBoss side), the current version is "9.4.1212.jre7".


Reference
----------
1.[Guide to Hibernate 4 with Spring](https://www.baeldung.com/hibernate-4-spring)    
2.[Springboot + JPA配置多数据源](https://www.zhyui.com/articles/2019082001.html)    
3.[Configuring a Hikari Connection Pool with Spring Boot](https://www.baeldung.com/spring-boot-hikari)  
4.[光 HikariCP Github](https://github.com/brettwooldridge/HikariCP)  
5.[Several database connection pool performance comparison hikari druid c3p0 dbcp jdbc](http://www.programmersought.com/article/549798096/)  
