---
layout: post
title: Jquery Selector Trick
disqus: y
share: y
categories: [Javascript]
---

Front end stuff always disgusting, even the most common css selector is painful.

Here is the example:
```html
<div class="0O'SHAUGHNESSYk7aw" >
```

We know jquery can select class by $('.xxxxx'), very clear and simple, but how to select them when they have special character (single quote and start with number)?

To select them in different place you will need completely different selector path, I use chrome as example, F12 open chrome develop tool.

1.select in Elements tag

```
.0O'SHAUGHNESSYk7aw -> not work
.0O\'SHAUGHNESSYk7aw -> not work
.\3O\'SHAUGHNESSYk7aw -> this works
```
Start with number, must use \3 to specify, single quote need add \ expression

2.select in Console

Use console to debug is a very common way to troubleshoot front end issue
```
$('.0O'SHAUGHNESSYk7aw') -> not work
$(".0O'SHAUGHNESSYk7aw") -> not work
$('.0O\'SHAUGHNESSYk7aw') -> not work
$(".0O\'SHAUGHNESSYk7aw") -> not work
$('div[class=0O\'SHAUGHNESSYk7aw]') -> not work
$("div[class=0O\'SHAUGHNESSYk7aw]") -> not work
$('div[class=0O\\\'SHAUGHNESSYk7aw]') -> not work
$('.0O\\\'SHAUGHNESSYk7aw') -> this works
$(".0O\\\'SHAUGHNESSYk7aw") -> this works
```

3.select in *.js file

Now in our code we want to normalize the special character name.

According to the console, we need three \ , thus write below function,
```javascript
function normalizeSelector(str){
	return str.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g,'\\\\\\$1');
} 
```
But doesn't work, debug the output string is exactly what I want, but it doesn't work, after lots of try, find below code works

```javascript
function normalizeSelectorName(str){
	return str.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g,'\\$1');
}
```
So in *.js file, the accept format is 
```
$('.0O\'SHAUGHNESSYk7aw')
```

AAAAAAAAAAAAAA, so disgusting, XXXOOOOO
