---
layout: post
title: Cookie Max Limit
disqus: y
share: y
categories: [Cryptography]
tags: [Javascript, Cookie]
---

//TODO

Background
----------
A weired issue occurs recently regarding the new GDPR cookie feature. The implement of the cookie banner is adding the certain cookie key into the domain (let's say cookie key "cookie-banner" and domain name "aa.bbb.com"), if client browser find this certain key not exist, will display the GDPR popup. However, this banner 

cookie limit
http://browsercookielimits.squawky.net/

Based on the test page above, my chrome has 180 maximum cookie limit per domain. I could reproduce issue by click different features in qa.bbb.com, stage.bbb.com and prod.bbb.com. When my total cookies approach 180, the cookie monitor will alert cookie consent was evict. Then the cookie banner displayed.
The issue is because max cookie limit per domain.

chrome
cookie monitor extension


chrome-extension://ccalldmbpkkpjcfgahbnpeffakpdldhj/cookiemon.html

