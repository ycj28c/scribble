---
layout: post
title: Mobile Alert App Idea
disqus: y
share: y
---

Alert App
=========

Idea:
----
Never get a change to develop a mobile app, feel like missing something in my life. So recently get an idea to develop an Alert App can use for public and our internal use.
Support two monitor:
+ Directly URL status check, check URL access HTTP/HTTPS code is 200, which works for internet server status.
+ JSON status check, the client use the HTTP API to update the Health Check Job status.

Structure:
----------
Mobile, server, client

+ Server:
Include web service and database and mobile fresh scheduler.
Web service: provide API for client, client can update the alert status.
Database: use Postgres. It persist the user and alert information.
Mobile fresh scheduler (or a module at beginning): it similar to windows scheduler, period check the database, based on the scheduler setting, send notification to client Mobile.
+ Popular HTTP client, no matter how you complete it, just call the server API.
Plan to use OATH2 for login, can create job, upload the status, whatever you do.
Example API:
Server/user
Server/user/alerts
Server/user/alerts/alertid
+ Mobile:
Allow multiple users to login as same account, therefore they can see same alert.
Create a HTTP alert: will sync to server, server will push notification to mobile period. Client will store the history record.
Create a JSON job: Can create a job with a name, then it will sync to the server, server will provide the mobile a JSON address. Then client can use that JSON address to program the status update in client app.

Not sure how notification push works? Need to research on it.

JSON format:
------------
{
	userId: 123456
	jobId: 123456
	ip: 172.16.1.111
	name: Insight Check Job
	status: ok
	comment: the connection code is 403
}

Similar product:
----------------
Server density: https://developer.serverdensity.com
New relic:
App Dynamic:
