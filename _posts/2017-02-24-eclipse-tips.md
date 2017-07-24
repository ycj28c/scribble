---
layout: post
title: Eclipse Tips
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
```shell
mvn dependency:tree
mvn eclipse:clean
mvn eclipse:eclipse
```

Eclipse Chines Character Display
---------------------
右键项目->Properties->Text File Encoding中没有GBK这个选项。*后来查阅资料才知道那个选项栏目中可以自己手填编码方式的*，我输入GBK，然后点确定，编码格式就成为GBK了，解决了中文乱码问题。


Refenrence:
---------------------
http://stackoverflow.com/questions/4262186/missing-maven-dependencies-in-eclipse-project