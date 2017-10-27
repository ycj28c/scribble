---
layout: post
title: Right Way To Declare Java Log
disqus: y
share: y
categories: [Language]
tags: [Java, Log]
---

The Java log library is very commonly used such as log4j, slf4j, logback. There are multiple ways to declare your log in Class, but which is the best, and why? Here are the examples:

```
/*
 * which is better?
 * log1 private is better, because so that no other class can hijack your logger
 */
private Logger log1 = LoggerFactory.getLogger(getClass());
public Logger log2 = LoggerFactory.getLogger(getClass());

/*
 * which is better?
 * log4 static is better, because it means we create one Logger per class, not one logger per instance of your class.  
 * Generally, this is what you want - as the loggers tend to vary solely based on class.
 */
private Logger log3 = LoggerFactory.getLogger(getClass());
private static Logger LOG4 = LoggerFactory.getLogger(HowToLog.class); //usually final use uppercase

/*
 * which is better?
 * log6 final make more sense, final means that you're not going to change the value of the logger variable.
 * Which is true, since you almost always throw all log messages (from one class) to the same logger. 
 */
private static Logger LOG5 = LoggerFactory.getLogger(HowToLog.class);
private final static Logger LOG6 = LoggerFactory.getLogger(HowToLog.class);

/*
 * which is better?
 * dependents on how you want your extends class log print:
 * log7 way allows you to use the same logger name (name of the actual class) in all classes 
 * throughout the inheritance hierarchy. So if Bar extends Foo, both will log to Bar logger. Some find it more intuitive.
 */
protected final Logger log7 = LoggerFactory.getLogger(getClass());
private static final Logger LOG8 = LoggerFactory.getLogger(HowToLog.class);

/*
 * which is better?
 * I don't know
 * after Java7, we can use 
 * Logger lgr = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());instead of static logger.
 */
private static final Logger LOG9 = LoggerFactory.getLogger(HowToLog.class);
Logger log10 = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

/* you can't really use this.getClass() because this doesn't actually exists (you're running in a static context */
//	private static final Logger logger = LoggerFactory.getLogger(this.getClass().getName());
```

Reference
---------
https://stackoverflow.com/questions/6653520/why-do-we-declare-loggers-static-final