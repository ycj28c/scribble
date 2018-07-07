---
layout: post
title: Cookie Banner
disqus: y
share: y
categories: [Cryptography]
tags: [Javascript, Cookie]
---

Background
----------
Recently every company sent Email regarding GDPR(General Data Protection Regulation), it is about some security of data policy online. You can image if you view some website, it pop out some notice: are you above 18, yes or no? Everyone know it is useless but still have to click yes. 

We are implementing it for cookie banner (If user want to login automatically, cookie is necessary), here is the situations:
1. We have a super domain, let's assume it is www.food.com
2. We have other sub domains such as burger.food.com, sandwich.food.com etc.
3. We want to pop out a notice which let client know they are using cookie
4. The pop up has some link to the policy and announcement
5. If user click OK, the pop out will hide
6. User only need click once, than the pop up will gone across domain

Implement
----------
Because the situation 1 and 6, we choose to use global cookie to accomplish this feature. As we know, cookie is stored in the browser side and able to share cross domain (local storage not able to cross sub domain), thus we can use unique cookie name as key to control the cookie banner. 

Full code:
~~~javascript
function createCookie(name, value, days) {
    var expires;
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = ";expires=" + date.toGMTString();
    } else {
        expires = "";
    }
    document.cookie = encodeURIComponent(name) + "=" + encodeURIComponent(value) + expires + ";path=/;domain=food.com";
}

function readCookie(name) {
    var nameEQ = encodeURIComponent(name) + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ')
            c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0)
            return decodeURIComponent(c.substring(nameEQ.length, c.length));
    }
    return null;
}

var CookieToolkit = function(cookieName, bannerText, buttonText) {
	this.element = null;
	this.cookieName = cookieName;
	this.bannerText = bannerText;
	this.buttonText = buttonText;
	this.init();
};

CookieToolkit.prototype = {
	init: function() {
		this.create();
		this.load();
		this.actions();
	},
	load: function() {
		if (readCookie(this.cookieName) == null) {
			this._show();
		}
	},
	actions: function() {
		var accept = document.querySelector("#cookie-toolkit-accept"),
			self = this;
			accept.addEventListener("click", function(e) {
				e.preventDefault();
				createCookie(self.cookieName, "true", 3650);
				self._hide();
			}, false);
	},
	create: function() {
		var element = document.createElement("div");
		this.element = element;
		var html = '<div class="sticky-popup-outer-container"><div class="sticky-popup-inner-container"><span class="sticky-popup-text">' + this.bannerText + '</span><div class="acknowledge-button-container"><div id="cookie-toolkit-accept" class="acknowledge-button">' + this.buttonText + '</div></div></div></div>';

		element.id = "sticky-popup";
		element.innerHTML = html;
		var insertTarget = document.getElementById("headerDiv");
		insertTarget.appendChild(element);  
	},
	_show: function() {
		var self = this;
		self.element.style.display = "block";
	},
	_hide: function() {
		var self = this;
		self.element.className = "";
		jQuery("#sticky-popup").slideUp("slow");
	}
};
~~~
When we want to trigger it just simply call function:
~~~
new CookieToolkit('<%=cookieName%>', '<%=bannerText%>', '<%=buttonText%>');
~~~
Another example, trigger it when DOM load complete:
~~~
document.addEventListener("DOMContentLoaded", function() {
	var toolkit = new CookieToolkit('<%=cookieName%>', '<%=bannerText%>', '<%=buttonText%>');
});
~~~

Compatible Issue
----------
Since it is implement in client side, it has compatible risk of running in different browsers. For example, Chrome and Firefox have feature to block all the cookies, however, IE only allow block cookie for particular domain. And in IE the navigator.cookieEnabled function will always return true, which require lots of debugging. Here is a solution:
~~~
function checkCookie() {
	if (!navigator.cookieEnabled) { 
		return false;
	}
    //below is specifically for IE
	document.cookie = "*.food.com=1";
	return document.cookie.indexOf("*.food.com") != -1;
}
~~~

Reference
---------
[General Data Protection Regulation](https://en.wikipedia.org/wiki/General_Data_Protection_Regulation)
