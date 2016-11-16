---
layout: post
title: Windows Hard Link
disqus: y
share: y
---
 
Hard Link
----------------

Here is the command to create hard link for a folder:
mklink [flag] link target
 
Example:

```
mklink /D xxx chromedriver_win32
```

Current use chromedriver 2.18:

```
mklink /D chromedriver chromedriver_win32\2.18
```
 
PS:
must run in Administrator command line mode