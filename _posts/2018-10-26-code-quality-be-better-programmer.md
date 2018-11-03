---
layout: post
title: Code Quality Be Better Programmer 
disqus: y
share: y
categories: [Test, Tools]
tags: [Quality, BeBetter]
---

My Thought
----------
Recently I read the book "Clean Code" by Robort C.Martin, have some thought here.

As a programmer, If we just focus on finishing the coding function but without care the code quality, it is definitely a disaster for the project. The bad code erode the whole workspace, Your code become ugly and bad smell, harder and harder to maintenance, until no one will want to touch this code base. 
For the programmer ourself, have a good habit and manner to write clean code is super important, and it is also good for the career path since more and more company pay attention to your code quality(because the hiring bar raise up). However, no code is perfect at beginning, there are certain phases.

+ Finish the feature
+ Fix the issue
+ Optimize the code
+ Organize the structure

If use XP, first phase is quickly having a prototype. 
If use TDD, first phase is writing test cases etc.

Finish the feature phase could include finishing the feature or function of requirement, as well as necessary test case etc. This phase is the bottom line for the developer, to be better programmer, do better communication, make sure clear the requirement, master the skill of using program language, data structure and popular technology are the direction for the phase.

Fix the issue phase could include fix the bug, fix the vulnerability, fix the code smell etc. When done the coding feature, first thing is code review and run your test case. Fortunately, we have lot of tools can assist for this phase, If you use JAVA, in the IDE there are PMD(duplicate code), FindBugs(find bug), CheckStyle(code style standard), Coverlipse(test coverage), JDepend(dependency jar check), Eclipse Metric(code complexity). Your can also use platform such as SonarQube. Those tools are super helpful and standardize the code quality especially multiple people work on one code repository. To be better programmer, try to reduce the code problem as much as possible every time you type the code, pay attention to below key words during coding: Long Method, Large Class, Long Parameter List, Lazy Class, Lazy Function, Unused Function Parameter, The Complexity is over 10, Feature Envy, Switch Abuse, Over-extend design, unread variable or function name, Alternative Classes with Different Interfaces, Message Chains, Temporary Field, Too Many Comments.

Optimize the code phase could include using the better algorithm(Dynamic programming, Union find etc.), using good naming(camel naming, better function name, better exception handler, elegant code) etc. This phase need long time accumulation, neither algorithm skill nor write elegant code is not possible to learn in one day. However, most of work not require ACM level algorithm skill or guru level beautiful code, always go back checking your code and keep doing the enhancement to your old code. If you find the code you wrote one year ago is such a trash, it means you got big improvement this year, this is good thing.

Organize the structure phase could include re-factor the code, implement the design patten, use the better OOP etc. This phase is not always necessary, in fact, many team may not even case about it. This phase became significant when your project grow big(million lines of code or hundreds of components or super complexity connection), developer start to complain the code, they find it took even more time to figure out the meaning of code than write complete new code, more and more people need to involve for same feature. It is better to re-factor as early as possible when the component hit certain scale, because no one will use the heavy code pattern at beginning, how to judge that bottleneck is totally dependent on your experience. So, to be better programmer, write good document, diagram, describe clear output and input, split big component to small piece is the good habit we should keep doing in daily job.

Those are some of my thought, try to be better myself. However, no one will paid you more because you can write super elegant code, programming is a skill, if it is your favorite skill or it is your only skill for survive, try to do it best.


Reference
----------
* [Browser Cookie Limits](http://browsercookielimits.squawky.net/)
* [Five Way Of Code Measure](https://blog.csdn.net/Guofengpu/article/details/52182124)
* [Clean Code Refactor](http://www.infoq.com/cn/articles/clean-code-refactor)
* [Improve Code Quality With Eclipse Plugin](https://www.ibm.com/developerworks/cn/java/j-ap01117/index.html)
* [Java Code Quality Scan Tools](https://blog.csdn.net/Guofengpu/article/details/52182124)
* [How To Install PMD In Eclipse](https://blog.csdn.net/lewky_liu/article/details/79735936)
* [Java Exception Handle](https://www.sojson.com/blog/251.html)