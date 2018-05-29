---
layout: post
title: Solr Load Timeout
disqus: y
share: y
categories: [Search]
tags: [Solr, Search]
---

All the people know Elastic Search, which is super popular, it can use not only search keywords, also can use as a fast key/document database to response json file. It based on Lucence, which has combined with Solr. Compare to Elastic Search, Solr is not fast enough, but we have an old system still using Solr, recently got a loading issue.

Issue
-----
When we do some solr search such as name is Lili, age is 50 etc, Solr is not able to response, our application looks frozen(probably don't have timeout setting). However, when try some other criteria, it is working.

Troubleshoot
------------
Solr actually use the HTTP request, same as Elastic Search, we can debug by Solr admin page
```
http://11.11.11.11/solr
```
or use the below HTTP url 
```
http://11.11.11.11/solr/select?q=realname:"Lily" AND age:"50"
```

When we search, it take a long time load and return a long text/xml list, we find 1 record below:
```
<response>
<lst name="responseHeader">
<int name="status">0</int>
<int name="QTime">0</int>
<lst name="params">
<str name="debugQuery">true</str>
<str name="indent">true</str>
<str name="q">realname:"Lily" AND age:"50"</str>
</lst>
</lst>
<result name="response" numFound="1" start="0">
<doc>
<str name="filename">
/mnt/filings/111/111.pdf
</str>
<str name="realname">Lily</str>
<str name="age">50</str>
<str name="id">87476620170406name2017</str>
<date name="filingdate">2017-04-06T00:00:00Z</date>
<str name="name">name2017.pdf</str>
<arr name="content_type">
<str>text/plain; charset=ISO-8859-1</str>
</arr>
<arr name="content">
<str>
<PDF> begin 644 xxxx.pdf M)5!$1BTQ+C,-"B63C(N>(%)E<&]R=$QA8B!'96YE<F%T960@4$1&(&1O8W5M M96YT(&AT=' Z+R]W=W<N<F5P;W)T;&%B+F-O;0T*)2 G0F%S:6-&;VYT<R<Z M(&-L87-S(%!$1D1I8W1I;VYA<GD@#0HQ(# @;V)J#0HE(%1H92!S=&%N9&%R M9"!F;VYT<R!D:6-T:6]N87)Y#0H\/" O1C$@,B P(%(-"B O1C(K," Q,S,@ M,"!2#0H@+T8S*S @,3,W(# @4@T*("]&-"LP(#$T,2 P(%(-"B O1C4K," Q M-#4@,"!2#0H@+T8V*S @,30Y(# @4@T*("]&-RLP(#$U,R P(%(-"B O1C@K M," Q-3<@,"!2#0H@+T8Y*S @,38Q(# @4B ^/@T*96YD;V)J#0HE("=&,2<Z M(&-L87-S(%!$1E1Y<&4Q1F]N=" -"C(@,"!O8FH-"B4@1F]N="!(96QV971I M8V$-"CP\("]"87-E1F]N=" O2&5L=F5T:6-A#0H@+T5N8V]D:6YG("]7:6Y! M;G-I16YC;V1I;F<-"B O3F%M92 O1C$-"B O4W5B='EP92 O5'EP93$-"B O M5'EP92 O1F]N=" ^/@T*96YD;V)J#0HE("=&;W)M6&]B+F,U934W.60T.#9F M.#0R-#5E-#(U,V-E9C R-38V,#<Y)SH@8VQA<W,@4$1&26UA9V583V)J96-T M( T*,R P(&]B:@T*/#P@+T)I='-097)#;VUP;VYE;G0@. T*("]#;VQO<E-P M86-E("]$979I8V5#35E+#0H@+T1E8V]D92!;(#$-"B P#0H@,0T*(# -"B Q M#0H@, T*(#$-"B P(%T-"B O1FEL=&5R(%L@+T%30TE).#5$96-O9&4-
...
```

This is a pdf file, and maybe Solr don't know PDF format, so it compiled with a long long content with lots of special characters.

Romove The Index
----------------
Let's try remove this id and check how is everything going. There are 2 ways to remove the data.

* url delete it by id(not work):
```
http://11.11.11.11/solr/update?stream.body=update?stream.body=<delete><query>id:87476620170406name2017</query></delete>&commit=true
```

* use curl to delete(can use the correct Content-Type, this works for me)
```
curl -H 'Content-Type: text/xml' http://11.11.11.11/solr/update --data-binary '<delete><query>id:87476620170406name2017</query></delete>'&commit=true
```

After delete this pdf, Solr is able to load very fast, our application is loading fast as well, the issue solved.

Conclusion
----------
The Solr has its own mechanism search the content, but when the content is unformal with lots of special character, Solr is not good at parsing those characters. Which cause the slow response. However, those content are bad data, we need to fix them before insert into Solr.

Reference
---------
[Example Of Using Solr Query](http://yonik.com/solr/query-syntax/)

[Solr Delete Statement Error](https://stackoverflow.com/questions/11716535/solr-delete-statement-error)
