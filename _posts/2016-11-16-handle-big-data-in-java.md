---
layout: post
title: Handle big data OOM in java
disqus: y
share: y
categories: [Language]
tags: [OOM, Java]
---

Handle OOM
==========
There are several ways to handle with the large data if you have only limit memory
+ if support, get source data from stream (jbdc also support stream large data)
+ stored data in the file, then read it by stream in java
+ for on the fly data, use one and remove one from list or string
+ split the string to more pieces and dispatch

Example
------------
```java
ResultSet rset = stmt.executeQuery("select DATECOL, LONGCOL, NUMBERCOL from TABLE");
while rset.next()
{
	//get the date data
	java.sql.Date date = rset.getDate(1);

	// get the streaming data
	InputStream is = rset.getAsciiStream(2); 

	// Open a file to store the gif data
   FileOutputStream file = new FileOutputStream ("ascii.dat");

   // Loop, reading from the ascii stream and 
   // write to the file
   int chunk;
   while ((chunk = is.read ()) != -1)
	  file.write(chunk);
   // Close the file
   file.close();

   //get the number column data
   int n = rset.getInt(3);  
}
```
