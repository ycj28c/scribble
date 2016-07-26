---
layout: post
title: Windows Hard Link
---

Introduction
------------
current insight_test and insight-bdd-testing are running in EquilarPC45(10.1.6.45) machine, when make change, remember to modify the configuration on the server machine also.
 
Hard Link change
----------------
If run insight_test or insight-bdd-testing in Jenkins mode, will use the server setting which will get chrome driver from "C:\tools\selenium\drivers\chromedriver" in XXX.XXX.XXX.XXX. It must be a hard link directory.

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
