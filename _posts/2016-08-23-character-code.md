---
layout: post
title: Character code
disqus: y
share: y
categories: [Cryptography]
tags: [Encode]
---
今天在学习python过程中，提到了关于字符编码的问题。比如python可以使用比如ord()来编码，chr()来把编码换成字符。才发现我对编码不甚了解，玩了不少汉化游戏，却从来没想过怎么做的。

关于编码网上有很多，总结下我所了解的：
unicode：最大最全字符集，集合了全世界所有的字符，因为有3个字节来存
ASC：最早的编码，存存127英文体系字符啥的
utf8：为了节省unicode的空间浪费，可变长度的编码，英文用1字节就够，中文啥的用2-3字节

你用ASCII编码，我用GBK解码，肯定就乱码。所以，按我理解，汉化过程就是：
1.解包（简单的就zip包，很多公司为了保密资源，用自己的加密包）
2.找到对应的文本之类的资源文件
3.找出正确的编码格式，正确读取文本（也有可能采用特殊编码包的，或者有额外格式之类）
4.如果是支持中文的编码，比如unicode，utf8编码的，直接将资源文件改成中文，理论上就汉化成功了
5.如果该编码不支持中文，而且没有设置编码的选项，那么需要修改程序读取编码的代码，需要脱壳，反汇编，字库，涉及到OD，Reflector 之类。根据程序不同，反汇编难度会大幅度浮动。
6.很多雷，比如游戏有显示限制等等，就更麻烦了。所以有采用外挂字幕的，只要读取就行，不用考虑游戏怎么显示。

PS：
如果使用BOM，表示在文件头申明该文件编码，比如
EF BB BF － 我是UTF-8
FF FE － 我是UTF-16LE
FE FF － 我是UTF-16BE
跨平台开发请使用UTF-8 without BOM

2018-08-01更新
--------------
最近在應用中也出現了編碼相關的問題，在處理特殊字符DUEÑAS的時候，前端顯示的是DUE�AS。
原因應該是我們的系統中某個環節的編碼問題，Jboss和tomcat甚至postgres都可能使用不同編碼，衹要一個編碼順序錯誤，那麽傳遞到前端的就可能有問題，可以使用下面的Java code模擬出現的問題
~~~java
String name=java.net.URLEncoder.encode("DUEÑAS", "ISO-8859-1"); //DUE%D1AS
String name2= java.net.URLEncoder.encode("DUEÑAS", "UTF-8"); //DUE%C3%91AS

System.out.println(name);
System.out.println(name2);
System.out.println(java.net.URLDecoder.decode(name, "ISO-8859-1"));// DUEÑAS
System.out.println(java.net.URLDecoder.decode(name, "UTF-8")); //	DUE�AS
System.out.println(java.net.URLDecoder.decode(name2, "ISO-8859-1"));// DUEÃAS
System.out.println(
	java.net.URLDecoder.decode(
			java.net.URLEncoder.encode(
					java.net.URLDecoder.decode(
							java.net.URLEncoder.encode("DUEÑAS", "ISO-8859-1"), 
					"UTF-8"), 
			"UTF-8"),
	"ISO-8859-1"));// DUEï¿½AS		
~~~
我們出現的問題就是默認的ISO-8859-1編碼，而卻使用了UTF解碼，那麽就產生了亂碼。最後定位到問題是使用Jersey請求Tomcat API時候出現，
~~~
WebResource webResource = client.resource(resource);
ClientResponse response = null;
// POST method
if ("POST".equalsIgnoreCase(method)) {
	String memTaskMapJsonStr = new Gson().toJson(object);
	LOGGER.debug(methodName + methodInfo.toString()
		+ "------Request Payload--------" + memTaskMapJsonStr);
	response = webResource.accept("application/json")
		.type("application/json")
		.post(ClientResponse.class, memTaskMapJsonStr);
~~~
原因可能是Jersey太過buggy導致，根據網上搜索，Jersey本來應該默認使用UTF8的，但是顯然沒有，加上强制的UTF8文件頭，解決了亂碼問題。修改如下：
~~~
response = webResource.accept("application/json;charset=utf-8")
		.type("application/json;charset=utf-8")
		.post(ClientResponse.class, memTaskMapJsonStr);
~~~

2019-02-08更新
--------------
关于网页的编码，我们知道在html里头可以插入<meta chartset=UTF-8>，但是实际解析的时候却是根据文件保存的格式，比如在windows新建1个txt文件，写入html内容，另存为ANSI格式，那么网页用UTF-8解析就会乱码。所以编码一定要每一个步骤都是对应的编码才行，中间乱了一个就变为多重编码了。

引用
-------
* [jersey web service json utf-8 encoding](https://stackoverflow.com/questions/9359728/jersey-web-service-json-utf-8-encoding)
* [developer.51cto.com/art/200906/132667.htm](developer.51cto.com/art/200906/132667.htm)
* [字符编码笔记：ASCII，Unicode 和 UTF-8](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)
* [解决浏览器抛出乱码，（HTML、PHP等的乱码问题）](https://blog.csdn.net/txl199106/article/details/38873665)
* [浏览器打开HTML页面(UTF-8编码)是总是乱码](https://blog.csdn.net/westlake2015/article/details/49387219)