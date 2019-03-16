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

you may curious how to made this kind of awesome photos, are people mosaic picture one by one manually? We can image that definitely a huge amount of work. Here will introduce the way to make and also the way to print the giant poster.

How to make Mosaic photo
-----------------------
Fortunately, now there is some tools can make our own collection very easy, like this tool: [AndreaMosaic](http://www.andreaplanet.com/andreamosaic/), basically we just need a target photo, and a big collection of images resource, then the tool will automatically generate the Mosaic photo you want.  
The detail guide could find in its official site: [AndreaMosaic Guide](http://www.andreaplanet.com/andreamosaic/screenshots/)

How to print giant poster
-----------------------
Ok, now we have the Mosaic photo, it kind of small when display in a A4 paper, how to print the photo in a giant photo. And we only has A4 printer, how to print the A0 by A4 printer?  
Fortunately, there is also a easy way to do it, and the only tool needed is your windows paint tool.  
1. Open your paint Tool -> Print -> Page Setup
![page-setup](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/makemosaicposter/2.png)

2. Change the fit to setting to what you want, in this case, fit 3 to 4 pages means 3 A4 page per column, print to 4 rows, use total 3 * 4 = 12 A4 pages
![page-fit](https://raw.githubusercontent.com/ycj28c/ycj28c.github.io/master/images/posts/makemosaicposter/3.png)

3. Print image, use glue to paste the 12 pages together.

Thinking of the internal logic
-----------------------
I was thinking how the tool able to generate the Mosaic photo, here is my thought:  
1. Split the original photo by tiles, each tile has 1 color value. ( can use 4 color or more to make edge more smooth)  
2. Analyze the collection of photo, each photo assign a color index, for example, if a picture is mainly red color, assign RGB red to that picture.  
3. According to the tiles value of original photo, pick the random picture in a acceptable color range of the indexed collection.
4. If no image match the color range, will need to change the resource picture color to fit it.

