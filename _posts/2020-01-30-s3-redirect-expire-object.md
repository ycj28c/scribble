---
layout: post
title: S3 Redirect Expire Object
disqus: y
share: y
categories: [Architecture]
tags: [S3]
---

Introduce
---------
Haven't update my blog for a while, this time will update something popular and every one knows: S3.  
We want to handle then situation that expire the object in S3, and when client visit the expire link, link them to a custom web page.

Solution
--------
There are two steps to archive the target:

1. How to expire s3 object  
We can set the life cycle for the bucket. To expire or delete the object after certain days base on configuration.   
How to create life cycle, please check: [How Do I Create a Lifecycle Policy for an S3 Bucket?](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-lifecycle.html)

2. How to redirect the error page when expire  
By default it will show 404 page like below:  
```
404 Not Found
Code: NoSuchWebsiteConfiguration
Message: The specified bucket does not have a website configuration
BucketName: xxxxxxx
RequestId: *************
HostId: ***************************************=
to custom the error, we need do below steps:
```
We would like to provide addition information when client visit those expired link, luckily, S3 also have solution for redirection. We need two step:  
1) First we need host that s3 as *Static Web Hosting*.  
2) Secondly configure the redirect page and error redirect role, please check: [(Optional) Configuring a Webpage Redirect](https://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html)
3) S3 will generate the new host name, please use this host url instead of the original s3 url.

Before I just think S3 is a web storage, but it really make difference when the disk path become an HTTP url path. A lot of feature like access control, host etc were coming out, the engineer don't need to consider lot of troublesome space or permission issues, just need to concern for the money cost, lol.


