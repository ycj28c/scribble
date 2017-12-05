---
layout: post
title: Local LAN Jekyll Server
disqus: y
share: y
categories: [Devops]
tags: [Jekyll]
---

The github support very well for jekyll, but how to setup jekyll server in local, there are some tricky stuff.

How The Environment setup
-----------------
```
Git
Ruby 2.2.6
Ruby DevKit-mingw64
```

How The Project Depolyment 
-----------------

	1. install ruby
	The latest Ruby so far is 2.4.2, but it doesn't work, you will fail when you install the json, I tried, that was terrible experence. So use Install Ruby version <=2.3, and install the Devkit-mingw64, you can find download at https://rubyinstaller.org/downloads/
	2. install bundle
	```
	gem install bundler
	```
	3. in jekyll folder, bundle install
	```
	bundle install
	```
	4. start up the jekyll server
	```
	# default setting in _config.yml, the local ip is override and define in _config_localhost.yml
	# it is magic command, please use this command
	jekyll serve --config _config.yml,_config_localhost.yml --host 0.0.0.0
	```

Reference
-----------------
[documentation-theme-jekyll](https://github.com/tomjoht/documentation-theme-jekyll)

[slim-pickins-jekyll-theme](https://github.com/chrisanthropic/slim-pickins-jekyll-theme)

[Transform your plain text into static websites and blogs](https://jekyllrb.com/)

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

