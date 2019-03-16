---
layout: post
title: Make Mosaic Poster
disqus: y
share: y
categories: [Tools]
tags: [Poster, Picture]
---

Introduce
----------
We can see many Mosaic photo in the Internet, like this Mark Zuckerberg Mosaic, 
![mark-zuckerberg](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/makemosaicposter/1.png)

you may curious how to made this kind of awesome photos, are people mosaic picture one by one manually? We can image that definitely will be a huge amount of work. This article will introduce a easy way to follow as well as the way to print into the giant poster.

How to make Mosaic photo
-----------------------
Fortunately, now there are some tools you can find in Internet, which can make our own Mosaic photo very easy, personal suggest this tool: [AndreaMosaic](http://www.andreaplanet.com/andreamosaic/). Basically you just need to choose a target photo, then select a big collection of pictures as resource, the tool will able to automatically generate the Mosaic photo for you.  
The detail guide could find in its official site: [AndreaMosaic Guide](http://www.andreaplanet.com/andreamosaic/screenshots/)

How to print giant poster
-----------------------
Ok, now we have the Mosaic photo, but it kind of small when we try to print it in a A4 paper, how about a giant photo. And we only has A4 printer, is it possible to print the A0 size by A4 printer?  
Fortunately, there is also a super easy way to archive that, the only tool you needed is your windows paint tool. Here is the detail step:  
1. Open your paint Tool -> Print -> Page Setup
![page-setup](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/makemosaicposter/2.png)

2. Change the fit to setting to what you want, in this case, fit 3 to 4 pages means 3 A4 page per column, print to 4 rows, use total 3 * 4 = 12 A4 pages
![page-fit](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/makemosaicposter/3.png)

3. Print image, use glue to paste the 12 pages together.

Thinking of the internal logic
-----------------------
I was thinking how the tool able to generate the Mosaic photo, here is my thought:  
1. Split the original photo by many tiles, each tile has 1 color value. ( or 4 color or more to make edge more smooth)  
2. Analyze the collection of photo, each photo will be assigned a color index. For example, if a picture is mainly red color, assign RGB red to that picture.  
3. According to its tiles value of original photo, pick the random picture in a acceptable color range of the indexed collection.
4. If no image match the color range, will need to change the resource picture color to fit it.

