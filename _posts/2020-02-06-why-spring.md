---
layout: post
title: Why Spring
disqus: y
share: y
categories: [Architecture]
tags: [Spring]
---

Chinese Version

前言
----
从来没有想过为什么要用Spring，一直感觉没什么特别的，不用Spring也能实现功能，甚至用了有时候更麻烦，尤其是在设置配置文件，还有最最恶心的升级Spring框架版本的时候。这里了解了一下Spring的核心技术。

什么是Spring
-----------
Spring是个java企业级应用的开源开发框架。Spring主要用来开发Java应用，但是有些扩展是针对构建J2EE平台的web应用。Spring框架目标是简化Java企业级应用开发，并通过POJO为基础的编程模型促进良好的编程习惯

为什么要用Spring
----------------
轻量：Spring 是轻量的，基本的版本大约2MB。  
控制反转：Spring通过控制反转实现了松散耦合，对象们给出它们的依赖，而不是创建或查找依赖的对象们。  
面向切面的编程(AOP)：Spring支持面向切面的编程，并且把应用业务逻辑和系统服务分开。  
容器：Spring 包含并管理应用中对象的生命周期和配置。  
MVC框架：Spring的WEB框架是个精心设计的框架，是Web框架的一个很好的替代品。  
事务管理：Spring 提供一个持续的事务管理接口，可以扩展到上至本地事务下至全局事务（JTA）。  
异常处理：Spring 提供方便的API把具体技术相关的异常（比如由JDBC，Hibernate or JDO抛出的）转化为一致的unchecked 异常。  

Spring IOC
----------
Spring的核心技术就是IOC(控制反转)，后来也有说依赖注入的(DI)，这篇知乎解释的非常好：[Spring IoC有什么好处呢？](https://www.zhihu.com/question/23277575)  
所谓的依赖注入DI，则是，甲方开放接口，在它需要的时候，能够讲乙方传递进来(注入)。  
所谓的控制反转IOC，甲乙双方不相互依赖，交易活动的进行不依赖于甲乙任何一方，整个活动的进行。  

说白了就是帮助初始化对象，Car对象有Framework，Base，Tire等，程序员要Car只需要new Car()就行，不用管中间一大堆new Framework(), new Tire()之类，配置好了Spring帮你建。具体实现就是一大堆的Java Reflection反射链，比如Car car = beanFactory.getBean("car"); 再通过配置文件(xml)或者注解来描述类与类之间的关系。

依赖注入的具体实现：（多种应用场景）  
属性注入 --> 通过setter()方法注入，就是我们常用的get和set啦  
构造函数注入 --> 就是替换new啦  
工厂方法注入 --> 也是new  

普通无IOC容器调用创建对象
```
BI b = new B(new A());
b.invoke();
```
使用IOC容易的调用
```
BI b(BI) WebAppUtil.getService("b");
b.invoke();
```

面向接口编程
-----------
很好的设计模式，很容易调整修改
```
private Super super = new SuperImpl_1();
public static void main ( String[] args ) {
	// 使用Super提供的服务
	super.method_1();
	super.method_2();
	super.method_3();
}
```
当想换成SuperImpl_2的实现的时候，只需要更换new
```
private Super super = new SuperImpl_2();
```

针对接口编程结合IOC：  
普通代码
```
public class UserServiceImpl {
 private UserDao userDaoImpl
 public List<User> getAllUser(){
	userDaoImpl = new UserDaoImpl();
	return userDaoImpl.getAllUser();
 }
}
```
解耦的IOC代码，不需要new，所以是针对接口的，implement可以随便该名字之类（用配置实现修改）
```
public class UserServiceImpl {
 @Autowired
 private UserDao userDaoImpl;
 public List<User> getAllUser(){
	return userDaoImpl.getAllUser();
 }
}
```

Autowried
---------
关于Autowired，涉及到额外的知识点，比较怎么自动识别需要的Impl类，Java Annotation等：

其中这篇注意下：  
[一个接口两个实现类怎么在注入的时候优先调用某个实现类](https://blog.csdn.net/u010476994/article/details/80986435)  
使用@Primary注解设置为首选的注入Bean  
使用@Qualifier注解设置特定名称的Bean来限定注入！  
也可以使用自定义的注解来标识  

结束语
------
所以总结了下用Spring的好处：  
1.代码更简洁，因为少了很多New，Spring容易帮你创建对象，看起来比较干净。  
2.面向接口编程，这是比较好的设计模式，易于扩展和调整。  
3.解耦，结构清晰，修改代码不至于牵一发而动全身。  
3.易于维护，尤其适合团队合作，大家都按规定模式写，避免个别人的代码风格以及设计影响协作。  

总的来说，对于大规模系统，是需要有一个强制的框架来规范的。而且作为智慧的结晶，Spring也有良好的代码，是值得学习的，迭代了这么多版本，也是与时俱进的。诟病就是额外的框架导致的升级困难，以及学习成本（衍生多），不同版本的方法也有很大不同。


引用
----
1.[听涛的Spring系列](https://www.iteye.com/blog/jinnianshilongnian-1435120)  
2.[Spring IoC有什么好处呢？](https://www.zhihu.com/question/23277575)   
3.[一个接口两个实现类怎么在注入的时候优先调用某个实现类](https://blog.csdn.net/u010476994/article/details/80986435)  

