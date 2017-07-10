---
layout: post
title: Useful Jenkins Shell Command
disqus: y
share: y
---

Jenkins is very popular, but most of plugins are developered by someone no one knows, lack of document (lot of tricks) and has security risk. What ever, here is some useful command for jenkins job linux shell and windows shell command.

Linux:
```bash
#!C:\cygwin64\bin\bash.exe --login -

env
whoami
```

Windows:
```bash
@echo on

set
echo %USERNAME%

netsh advfirewall show allprofiles
tasklist
```

```bash
:: must set for jenkins backend run
set HUDSON_SERVER_COOKIE=
set

:: kill all the open ie and selenium grid progress
c:\windows\system32\TASKKILL.exe /F /IM java.exe
c:\windows\system32\TASKKILL.exe /F /IM cmd.exe
c:\windows\system32\TASKKILL.exe /F /IM iexplore.exe
```