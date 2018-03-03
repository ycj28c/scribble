---
layout: post
title: Sonar Test
disqus: y
share: y
categories: [Test]
tags: [Sonar, SonarQube]
---

## Environment
> SonarQube 6.0
> MAVEN 3.0+
> JAVA 1.8+
>
> Local Sonar link: http://localhost:9000

## How to run sonar
```
# below command can use to run in local
# Attention, the command must in order, and exactly the same
mvn clean findbugs:findbugs cobertura:cobertura sonar:sonar -Dsonar.host.url=http://localhost:9000 -Ddeployment.environment=jenkins -DskipTests=false -Dlogback.level=ERROR -fn
# if only want to test single class
mvn clean findbugs:findbugs cobertura:cobertura sonar:sonar -Dsonar.host.url=http://localhost:9000 -Ddeployment.environment=jenkins -DskipTests=false -Dlogback.level=ERROR -fn -Dtest=AAA
# if want to test single method
mvn clean findbugs:findbugs cobertura:cobertura sonar:sonar -Dsonar.host.url=http://localhost:9000 -Ddeployment.environment=jenkins -DskipTests=false -Dlogback.level=ERROR -fn -Dtest=AAA#BBB
```
Explain
```
mvn clean -> regular MAVEN command
findbugs:findbugs -> findbug plugin help find all kinds of java issue
cobertura:cobertura -> run for coverage (some may use Jacoco, but insight so far only work for Cobertura)
sonar:sonar -> run sonar test
-Dsonar.host.url=http://localhost:9000-> customize the sonarQube, default sonar:sonar will go to http://localhost:9000/
-Ddeployment.environment=jenkins -> used for some customize setting when run in jenkins
-DskipTests=false -> must add this, means don't skip the tests
-Dlogback.level=ERROR -> the parameters dependent on module's logback.xml setting, can change different log level
```

## How to configure sonar
### Maven Configuration
1. skip current module

```
<properties>
	sonar.skip>true</sonar.skip>
</properties>
```

2. exclude the test result(use sub-module/pom.xml as example)

```
<properties>
	<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	<start-class>com.xxx.Application</start-class>
	<sonar.exclusions>
		<!-- Excluding domain objects from sonar report -->
		src/main/java/com/xxx/Application.java,
		src/main/java/com/xxx/WebInitializer.java,
		src/main/java/com/xxx/ExceptionControllerAdvice.java,	
	</sonar.exclusions> 
	<tomcat.version>7.0.61</tomcat.version>
	<spring-boot.version>1.1.9.RELEASE</spring-boot.version>
	<slf4j.version>1.7.7</slf4j.version>
</properties>
```

3. exclude from coverage(still run tests, use parent/pom.xml for example)

```
<plugin>
	<groupId>org.codehaus.mojo</groupId>
	<artifactId>cobertura-maven-plugin</artifactId>
	<version>${cobertura-maven-plugin.version}</version>
	<configuration>
	   <maxmem>1024m</maxmem>
		<formats>
			<format>xml</format>
		</formats>
		<!--if run in multi-level, use the aggregate parameter-->
		<!--aggregate>true</aggregate-->
		  <instrumentation>
			 <excludes>
				<!-- Excluding model package from cobertura code coverage -->
				<exclude>com/xxx/international/model/**/*.class</exclude>
				<!-- Excluding com.xxx from cobertura coverage as these are model objects  -->
				<exclude>com/xxx/calc/**/*.class</exclude>
				<!-- Excluding yyy model objects from cobertura code coverage -->
				<exclude>com/yyy/model/*.class</exclude>
				<exclude>com/yyy/model/**/*.class</exclude>
				<exclude>com/yyydatum/*.class</exclude> 
				<exclude>com/yyy/download/*.class</exclude>
				<exclude>com/yyy/service/*DownloadServiceImpl.class*</exclude>	
			</excludes>
		</instrumentation>
	</configuration>
	<executions>
		<execution>
			<phase>package</phase>
			<goals>
				<goal>cobertura</goal>
			</goals>
		</execution>
	</executions>
</plugin>
```

### Jenkins Configuration
Plug-in: Publish Cobertura Coverage Report
Since Insight is multi-level project, when publish files please add the correct folder, such as "sub-module/target/site/cobertura/coverage.xml"

### SonarQube Configuration
Tip: If the project has a big code refract, sonar may fail to recognize the new upload, need manually remove the old sonar result. 
(Administration -> Project -> remove the old project, need SonarQube admin account)

## Reference
[Installing and Configuring Maven](http://docs.sonarqube.org/display/SONARQUBE51/Installing+and+Configuring+Maven)

[Code Coverage by Unit Tests for Java Project](http://docs.sonarqube.org/display/PLUG/Code+Coverage+by+Unit+Tests+for+Java+Project)

[Maven cobertura plugin - one report for multimodule project](http://stackoverflow.com/questions/3768517/maven-cobertura-plugin-one-report-for-multimodule-project)
