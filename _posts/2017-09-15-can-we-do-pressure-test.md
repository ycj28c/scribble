---
layout: post
title: Can We Do Pressure Test
disqus: y
share: y
---

> ps: All the numbers and cases in this page are fake number, just for example

#General Concept
Pressure test is based on performance test, which run a bunch of parallel requests targeting a function or a system work flow. The goals are:
1. Break down the system, get the test data such as TPS, PV
2. Find the system bottle neck
3. Show the result and see if boss or user satisfy with the current system capability
So it is best to run in production, but we has same mirror system stage, it is OK to test in stage.

#Pressure Test Precondition
1. Are we pressure test particular function or test the whole system
	* If test particular function, we only need to produce the pressure for that function
	* If test whole system, we need to simulate the general user behavior
2. Check the current user peer
user_session talbe: max login per minute is 7, max login per hour is 234 according to previous 6 month
Google Analytics: 842 active user per day in average
Sumologic: around 11 times of keywords "stormpath" per minute
3. Discuss the goal we want to achieve
for example: we want to handle max 30 users on time at same time, we want 50 users can visit this function  

#Pressure Test Metrics
Throughput: Request per seconds
TPR: Time Per Request, TPR = time cost of all request / concurrent user
The number of concurrent connection
PV: page view
...

#Feasibility Pressure Test For Your System
To answer this, we need to think about two parts of the pressure test: pressure producer and system monitor

###First, pressure producer
We have two system component require to do the pressure test:
1. Jboss
There are two ways to produce the pressue:
	* Manually make pressure, 30 or more people operate system together, produce pressure. This is the best way to simulate the real user behavior, but we need 30 people to test, however, if 30 person not able to break down system, we need to find more people.
	* Automation test, we can run the selenium UI test to produce pressure. One server can run multiple automation test, don't need humun intercept. The concern is the test server performance. One windowns VM maximun run 6-7 tests at the same time, to mockup 30 people, we need at least 5 server to run the tests, however, we only has 2 test server so far.
2. Tomcat
The tomcat is handling the API, use tools such as Jmeter or other test tools, we're able to create a large amount of API request in one node, which is able to make lots of pressure.

###Secondly, system monitor:
This is the pain part, when we produce the pressure outside, we also need to capture the system running metrics in the server side. It is hard to manually record the data during the pressure test. Here is the list of server we'll want to monitor:
| Name        		   | Monitor                                               |
| -------------------- |:-----------------------------------------------------:| 
| jboss/tomcat/database/redis server | we can directly use top command get metrics such as cpu, memory, swap, io, etc, but we don't have the tool to continues tracking and record the data change. |
| jboss      | need perfessional jboss monitor      | 
| tomcat | need perfessional tomcat monitor      |
| database | need perfessional postgres monitor      |
| network | usually system traffic should not be a problem for our network, we can check from ping or many tools|
| front end | if you don't have large front end resource and fancy javascript, the only time consume is download the css, javascript lib stuff, and front end runs in client side, it is not a performance issue for you.  |


#The Meaning Of Pressure Test For system
Is it meaning for the do the pressure test for system? Yes and no. "Yes" because it is always good to know how is our system performance, how much user we can handle. "No" because we don't have a big amount of client access daily, we don't has a feature which facing sudden large requests.

#Conclusion:
In this case,
- Can we do the pressure test for system, the answer is yes.
- Can we do the pressure test for system with current resource, the answer is no.

The main reason we can't is because we don't have a good monitor tool which able to capture the performance of the Jboss/Tomcat/Postgres/Redis in realtime and persistent it, thus it is hard to identify the bottle neck and generate report. In addition to this, we don't have enough test servers to produce pressure, unless more people participate into the pressure test.
