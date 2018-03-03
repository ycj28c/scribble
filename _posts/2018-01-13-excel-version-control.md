---
layout: post
title: Excel Version Control
disqus: y
share: y
categories: [Tools]
tags: [Excel]
---

Excel components
-----------------
The Excel template is a binary file, it mainly organized by 4 components: 

1. the data in the excel 
2. basic excel structure, such as multiple spreadsheet, format of cell, color etc. 
3. advance feature of excel, such as pivot, chart, image etc.
4. macro
for the above components, 1) and 4) can export to text format, 2) is in the xml file for .xlsx format excel 3) are binary files

Version Control Or Change Tracking
----------------------------------
It is not easy for tracking all the changes of the excel in readable way, because excel has too much components and versions(.xls, .xlsx, .xlsm), they are organized by different structure(for example, .xlsx is actually a zip file zipping a bunch of xml files). And the popular version control tools such as git, svn they can only compare the text format files, binary format are not human read friendly when doing the comparison. There are some tools provided by Excel or Microsoft able to do the version control such as onedrive and sharepoint, and comparison tool such as "Spreadsheet Compare 2013"(only exist after excel 2013), however, those tools will require you open the actual excel to check difference, and they are not free .

What's Our Case
---------------
Our team mainly use .xls(97-2003 version) and several .xlsm format template. For .xls, our template usually has no data, only has UI design and macro, to better tracking the changes, we can export the all the macro each time we change the code. The tools I recommend is VBASync(https://github.com/chelh/VBASync), it enable to export all macro at once so you don't need to export one by one.

PS: Alt + F11 open the macro interface

Reference
---------
[Can't Leave Excel](https://blog.codingnow.com/2014/11/excel.html)

[Xls2txt In Unit](http://wizard.ae.krakow.pl/~jb/xls2txt/)

[8.2 Customizing Git - Git Attributes](https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes#Binary-Files)

[Compare Between Xlsx File](http://forums.winmerge.org/viewtopic.php?f=4&t=1168)

[Excel Data Compare Project](https://github.com/na-ka-na/ExcelCompare)

