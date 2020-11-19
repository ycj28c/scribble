---
layout: post
title: File Upload Frontend & BackEnd
disqus: y
share: y
categories: [Web]
tags: [File Upload]
---

## 简介
文件上传是一个很常见的功能，本文使用SpringMVC + JQuery展示一个文件上传的例子。  
除了发送文件，还包括了多个参数。在展示上使用了通用的Boostrap，并使用Jquery的xhr特性加入了上传进度条。

### 前端

这是将文件以及参数都按照form的形式传输的例子

HTML
```xml
<div class="uploadDiv">
	<img class="uploadIcon" src="/images/uploadIcon.svg">
	<span class='uploadTxt'>Upload your completed file form here:</span>
	<div class="uploadFileDiv">
		<label id="fileLabel" for="file" class="text-center">
			<span class="templateFileTxt">Choose File</span>
		</label>
		<span class="selectedFile d-inline-block" id="selectedFile">No file chosen</span>
		<!-- 一个上传Excel的例子，这里做了文件限制 -->
		<input class="d-none" type="file" id="file" accept=".csv, .xls, .xlsx, .xlsm, .xlsb, .xltx, .xlt, .xlam"/>
		<img class="cancelUploadFileIcon d-none" id="cancelUploadFile" src="/images/delete-remove-less.svg">
		<div class="progress hide" id="selectedFileProgressDiv">
			<div class="progress-bar" id="selectedFileProgress" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
		</div>
	</div>
	<div id="fileSizeExceedErrorMsg" class="d-none errorMsg mt-2">File size exceeds maximum limit 10 MB.</div>
	<div id="fileNotChoosenErrorMsg" class="d-none errorMsg mt-2">Please choose a file.</div>
	<div id="selectExcelFileErrorMsg" class="d-none errorMsg mt-2">Please select an Excel file.</div>
</div>

<div id="parameter1">parameter1</div>
<div id="parameter2">parameter2</div>
<div id="parameter3" favor="11111">parameter3</div>
```

Javascript
```xml
uploadFile = function() {	
	var up_file = $('#file')[0].files[0];
	//Javascript特有的formData格式，用来替代原来的form元素标签方式
	var formData = new FormData();
	formData.append("file", up_file);
	formData.append("parameter1", $('#parameter1').val());
	formData.append("parameter2", $('#parameter1').val());
	formData.append("parameter3", $('#parameter3').attr('favor'));
	
	//如果要发送一个json文件也可以，直接包装到formData里面去就行，使用JSON.stringify进行序列化
	/*
	var jsonObj = {};	
	jsonObj.parameter1 = $('#parameter1').val();
	jsonObj.parameter3 = {};
	jsonObj.parameter3.favor = $('#parameter3').attr('favor');
	formData.append('jsonObj', JSON.stringify( jsonObj ));
	//debug
	for(var pair of formData.entries()) { console.log(pair[0]+'| '+pair[1]);} 
	*/
	
	//Ajax call for upload
	getApiStatus = $j.ajax({
		type: 'GET',
		url: "/app/getApiStatus?random=" + Math.floor(Math.random() * (new Date()).getTime() + 1),
		dataType: "json",
		contentType: "application/json"
	});
	execlUploadAjax = $j.ajax({
		url:"/app/fileupload",
		//如果设置dataType为json，那么发送和返回的文件类型都要是json，否则报错
		dataType:'json',
		type:'POST',
		async: true,
		data: formData,
		//注意这里的参数必须使用processData: false，而且必须设置contentType为false
		processData : false, 
		contentType : false,
		//jquery内置的进度跟踪方法
		xhr:function(){ 
			myXhr = $.ajaxSettings.xhr(); 
			if(myXhr.upload){ // check if upload property exists 
				myXhr.upload.addEventListener('progress',function(e){ 
					var loaded = e.loaded;
					var tot = e.total;
					var per = Math.floor(100*loaded/tot).toFixed(2); 
					$("#selectedFileProgress").css("width" , per +"%");
				}, false); // for handling the progress of the upload
			}	  
			return myXhr;  //必须retrun，否则可能进入error
		},
		success:function(data){
			console.log("upload success!");
		},
		error: function (XMLHttpResponse, textStatus, errorThrown) {
			console.log("upload fail.");
		}
	});			
	//如果getApiStatus和execlUploadAjax完成（不管失败成功，都进入这里）
	$.when(getApiStatus, execlUploadAjax).done(
	function(getApiStatusLog){			
		//进行dom的操作
	}).fail(function() {
		//跳转到错误页面
		location.href = Constants.error_page_url;
	});
});
```

SpringMVC
```java
@RequestMapping(value = "/fileupload", headers = ("content-type=multipart/*"), method = RequestMethod.POST)
	@ResponseBody //注意这里不能漏了
	public Boolean upload(
			@RequestParam("file") MultipartFile inputFile, //文件使用的是MultipartFile格式
			@RequestParam("parameter1") String parameter1,
			@RequestParam("parameter2") String parameter2,
			@RequestParam("parameter1") Long parameter3,
			//@RequestParam("jsonObj") String jsonObj, //也可以发过来一个json string，后续再用gson之类的解析
			HttpServletResponse response, HttpServletRequest request) throws Exception {
		try {
			//这里写逻辑即可
		} catch (Exception ex) {
			//如果错误返回自定义的错误代码
			LOGGER.error(methodName + "Failed ", ex);
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			response.setContentType("application/json;charset=utf-8");
		} finally {
			//统计运行时间，这里用了自定义代码
			SystemUtil.timeSpent(methodName, methodInfo.toString(), startTimeInMS, Level.INFO);
		}
		//注意返回的要是一个Object，因为规定的传输json的格式
		return Boolean.TRUE;
	}
```
另外为了支持upload的MultipartFile格式，还需要在Spring xml config里面加入
```java
<bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver" />
```

## Reference
1. [js文件异步上传进度条](https://juejin.im/post/6844903776654999566)   
2. [从前端到后端实现文件上传](https://blog.csdn.net/qq_36651625/article/details/81456254)  
3. [前后端文件上传过程以及方法](https://zhuanlan.zhihu.com/p/120834588)  
4. [Upload file and JSON data in the same POST request using jquery ajax?](https://forum.jquery.com/topic/upload-file-and-json-data-in-the-same-post-request-using-jquery-ajax)  
5. [前后分离文件上传](https://segmentfault.com/a/1190000018570206)   