---
layout: post
title: Web Security
disqus: y
share: y
---

網站安全一直是個問題，而這種安全類技術問題很直接，你知道就是知道，不知道就是不知道，所以網站通常都有安全隱患。而對於開發人員和項目管理人員安全問題很少放在第一優先級，都是以業務的實現為優化，導致安全方面基本儲備。搞安全的人看起來都是大牛，很大一部分原因是離我們實際的工作太遠了，黑客啥的不就是搞安全的嗎，所以網絡安全基本就是内鬥啊，搞安全的和另一起搞安全的打在一起。

吐槽這麽多，我們這主要用veracode做自動掃描和個別手動測試，下面一個簡單例子：

一個簡單的<input>, 也就是輸入文本框，掃描出以下問題

Description 
It is possible to execute Javascript code by injecting ><script>pholcidCallback(9646897897)</script> into the value vcode of URI query parameter ticker at position 8 parameter on https://xxxxx/xxxxx.jsp?ticker=vcode&ticker=vcode by breaking out of an HTML element's attribute on https://xxxxx/xxxxx.jsp?ticker=vcode&ticker=%3e%3cscript%3epholcidCallback%289646897897%29%3c%2fscript%3e After breaking out of the attribute, it is possible to create additional events that when the event is triggered, such as moving the mouse over the element, will cause the injected code to execute. XSS vulnerabilities are commonly exploited to steal or manipulate cookies, modify presentation of content, and compromise confidential information, with new attack vectors being discovered on a regular basis.
Additional Resources: CWE OWASP  
Recommendations
Use contextual escaping on all untrusted data before using it to construct any portion of an HTTP response. The escaping method should be chosen based on the specific use case of the untrusted data, otherwise it may not protect fully against the attack. For example, if the data is being written to the body of an HTML page, use HTML entity escaping; if the data is being written to an attribute, use attribute escaping; etc. Both the OWASP Java Encoder library and the Microsoft AntiXSS library provide contextual escaping methods. For more details on contextual escaping, see https://www.owasp.org/index.php/XSS_%28Cross_Site_Scripting%29_Prevention_Cheat_Sheet. When displaying user input in the context of an HTML element's attributes, be sure to encode and escape quote characters. If the value vcode of URI query parameter ticker at position 8 output is used directly in an HTML element's DOM event attribute, you must be sure to escape any quote characters even if you encode them to their HTML entity value.


所以一個簡單的input，我們需要檢查它不能被sql injection，不能被javascript injection，不能被css injection啊，html injection等等，具體的測試用例可以參考這個cheet sheet： https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet

```javascript
sql injection： 比如 1 = 1
html injection： 比如 <A HREF="//www.google.com/">XSS</A>
javascript injection： 比如</script><script>alert('XSS');</script>
```

基本通用的處理方法：
1. 用regex嚴格限制parameter的格式，比如只能a->b之類
2. 通過filter在global上限制keywords比如javascript event啦
3. 通過全部upper case來限制某些script的運行比如onClick變成ONCLICK就無法運行了
4. 現在的library比如esapi-2.0.1.jar

安全永遠是個坑，沒有完全安全的系統，這個道理大家都懂。但是瞭解危險性較大的安全問題，避免被sudo rm -rf了還是有必要。
