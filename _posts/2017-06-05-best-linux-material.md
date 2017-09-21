---
layout: post
title: Best Linux Material
disqus: y
share: y
categories: [OS]
---

Purpose
-------------------------

Collect the best material about linux(keep updating):
[Linux交换空间swap space](https://segmentfault.com/a/1190000008125116)

Find large find:
[How to Find Out Top Directories and Files (Disk Space) in Linux](https://www.tecmint.com/find-top-large-directories-and-files-sizes-in-linux/)
Example:
```bash
#How to Find Biggest Files and Directories in Linux:
du -a /home | sort -n -r | head -n 5

#Find Largest Directories in Linux
du -a | sort -n -r | head -n 5

#Some of you would like to display the above result in human readable format. i.e you might want to display the largest files in KB, MB, or GB.
du -hs * | sort -rh | head -5

#To display the largest folders/files including the sub-directories, run:
du -Sh | sort -rh | head -5

#Find Out Top File Sizes Only
find -type f -exec du -Sh {} + | sort -rh | head -n 5
```

Delete the old log files:
```bash
# Find the log longer than 5 days from today
find /opt/jboss-insight/server/default/log/* -mtime +5

# Delete those log files
find /opt/jboss-insight/server/default/log/* -mtime +5 -delete
```

Get the file path you want in linux shell:
```yest=$(date --date="yesterday" +"%Y-%m-%d")
echo $yest
targetfilepath=$(locate -r "/opt/tomcat-insightws/logs/insight_script_restapp"|grep $yest)
echo $targetfilepath
```