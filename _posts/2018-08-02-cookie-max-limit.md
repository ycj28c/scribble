---
layout: post
title: Cookie Max Limit
disqus: y
share: y
categories: [Cryptography]
tags: [Javascript, Cookie]
---

Background
----------
A weired issue occurs recently regarding the new GDPR cookie feature. The implement of the cookie banner is adding the certain cookie key into the domain (let's say cookie key "cookie-banner" and domain name "aa.bbb.com"), if client browser find this certain key not exist, will display the GDPR popup. However, this banner sometimes just disappear for unknown reason, thus the GDPR popup come out again which is annoying.

Troubleshot
----------
Even it happens frequently in our internal network, however, did not hear any client complain about it. Look like something only inside the black box. Is it because the network? doesn't seem to effect; Is it because HTTP and HTTPS protocol? if so, why sometimes happens, but sometimes no; Is it because the browser cache? we disable the cache, same issue again; How about the exception or error causing the issue? Unfortunately, no error log point to the root cause.

Struggle with this issue, it is like a ghost, sometimes it comes, sometimes it gone. 

Until,

We found there is maximum limit for the browser cookie, this weired issue was finally show his whole body to us.

Solution
----------
Same as local storage has space limit, all the browser limit for cookie as well, don't know why has hard code limit for the stuff save in the disk, but that's the implement of most of the browsers. For example, the IE6 only has maximum 20 cookies, safari 5 has 600 cookie limit. Different browser has different configurations, here is a very good website to diagnose your browser cookie: 

[Browser Cookie Limits](http://browsercookielimits.squawky.net/)

Based on the test page above, my chrome has 180 maximum cookie limit per domain. I could reproduce the cookie issue by click different features in qa.bbb.com, stage.bbb.com and prod.bbb.com. Because each feature will generate some cookie (the session also count as cookie not sure why) When my total cookies approach 180, the cookie monitor will alert cookie consent was evict. Then the cookie banner displayed. Seems like the chrome prefer to delete the super domain cookie first, because our cookie target in *.bbb.com super domain, it looks like always got removed first when hit the cookie limit. 

So the issue is because max cookie limit per domain. Actually we are not able do anything about it, because all our application and environment are under the same bbb.com domain. However, the client will not face the same issue, because only one application is open for client.

Also recommend an good plugin for cookie troubleshot in Chrome "cookie monitor extension" 

Reference
----------
* [Browser Cookie Limits](http://browsercookielimits.squawky.net/)

