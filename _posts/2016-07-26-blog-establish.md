---
layout: post
title: My Blog Establish
disqus: y
share: y
categories: [Blog]
tags: [Jekyll]
---

Two days ago use the Jekyll template/theme from https://github.com/muan/scribble.

Today succssfully add feature to my Jekyll blog, here is some **Tips**:

Google search
--------------
Insert below html to the blog, then able to use google search to search your blogs

```html
<form class="search" method="GET" action="https://www.google.com/search">
  <input type="text" name="as_q" class="search-query" placeholder="Internal Search">
  <input type="hidden" name="as_sitesearch" value="ycj28c.github.io">
</form>
```
It is the same behavior as the chef site:ycj28c.github.io, to let google find you, also need to link your site to google account. Just follow the steps guided by google, next day you will be able to search your publish.

disqus Comments feature
-----------------------
At beginning follow the Scribble theme mannual, but can't make it work. here is the steps how it works:
1. register your site in http://disqus.com
2. setting your website in disqus, make sure shortname, sitename, url is filled up.
3. add your site in disqus trusted domain
4. insert the disqus to your site, below is the script work for me 

```html
<div class="block">
    <div id="disqus_thread"></div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = "{{ site.disqus_shortname }}"; // required: replace example with your forum shortname
        // var disqus_developer = 1; // Comment out when the site is live
        // var disqus_identifier = "{{ page.url }}";
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
</div>
```
5. if not work, try use the chrome develop tools check the network, and use the disqus_developer = 1 to debug
