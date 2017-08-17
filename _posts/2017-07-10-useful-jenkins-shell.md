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

```bash
#!/bin/bash +x

mkdir -p "${WORKSPACE}"/logs/
cd "${WORKSPACE}"
cmd="./etl.sh -ip ${IP} -u ${USER} -port ${PORT} -db ${DATABASE} -etl ${ETL} -batch ${BATCHSIZE} -cl ${COPYLIST_LOCATION} -ids ${USER_INPUT_IDS}"

export PGPASSWORD=${PASSWORD}
$cmd 2>&1 | while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"; done | tee -a "${WORKSPACE}/logs/${ETL}.`date +%m-%d-%Y`.log"

exit  ${PIPESTATUS[0]}
```

export password: https://stackoverflow.com/questions/38690710/jenkins-passing-variable-password-to-external-shell
PIPESTATUS: https://neeohw.wordpress.com/2013/11/28/bash-pipestatus-get-return-code-from-process-with-pipes/

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