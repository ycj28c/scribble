---
layout: post
title: Pixel Vs Point
disqus: y
share: y
categories: [Image]
tags: [pixel]
---

Background
-----------
Recently working on some PDF related work. We use IText library, and follow the design in the Invision. We just convert the Invision unit into the pdf unit, for example, 26 size Invision to 26 size in IText, however, we have a hard time to match the design with result PDF.

Pixel VS Point
--------------
To figure out problem, first we need to know the difference of pixel and point.  
Pixel is *relative* length, it dependent on the resolution, so it is different in different device, the MAC has better screen, so it has smaller pixel compare to regular PC.  
Point, or we can see pt, is *absolute* length, it doesn't change for screen density, it has similar concept as meter, centimeter. It first implement in the IOS world, Apple standardize that 1px=1pt in the iphone 3G. But after the iPhone4 and later device, they are better screen, so 1pt=2px in that case.

For IText, it is using PT as unit. 1 pt is exactly 1/72 inches, on a 72 ppi display, 1 point = 1 pixel.

Page Size
---------
Next step is to figure out the relation among the IText page size, actual page size and Invision page size.

In IText, by default is using A4 page size, which is (595 pt x 842 pt).  
In Invision, design is using Letter page size, which is (612pt x 792pt).  
In actual world, the Letter size page is more popular.

Letter(612pt x 792pt), 8.5 inches x 11 inches.
A4(595pt x 842pt), 8.27 inches x 11.69 inches.  
If interest, can check your office page, see which one is mostly using.

Conclusion
----------
Now the thing for us is easy, change the IText page size to Letter, then just strict follow the designer's mock up.  
Some IText point unit example:
```
//Document
Document document = new Document(PageSize.A4, 35f, 35f, 50f, 100f);
//Font
Font font = new Font(avenirLTComMedium, 8f, style, nameColor);
//Table
table.setTotalWidth(537f);
//Image
image.scaleToFit(149, 21);
```
All the number use above are PT.


Reference
---------
[Point vs Pixel: What is the difference?](https://graphicdesign.stackexchange.com/questions/199/point-vs-pixel-what-is-the-difference)  
[Invision](https://www.invisionapp.com)