---
layout: post
title: Eclipse Import Maven
disqus: y
share: y
---

Eclipse is my favorite IDE, Maven is also my favorite, sometimes there are issue when import maven project to Eclipse, which may waste lots of time to find out.

Import Maven To Eclipse
---------------------
1. install the maven eclipse plugin m2m, can find in Help -> Eclipse Marketplace
2. in your project space, right click, choose import
3. choose Maven -> Existing Maven Projects -> Next
4. Browse choose the root (pom.xml) of your maven project -> Finish

Now is the annoying part, you succssful import maven project, but why there are so much error?
check the project -> Properties -> Libraries, find only one line "JRE System Library[JavaSE-1.7]".
The maven dependency jar is not there.

If tried Project -> Clean, refresh, not work. Do below:
```
mvn dependency:tree
mvn eclipse:clean
mvn eclipse:eclipse
```

Refenrence:
---------------------
http://stackoverflow.com/questions/4262186/missing-maven-dependencies-in-eclipse-project