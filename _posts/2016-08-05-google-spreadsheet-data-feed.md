---
layout: post
title: Google Spreadsheet Data Feed
disqus: y
share: y
---

Recently, I want to display the news update and our Jira status update in our google scrum docs.

News Feed
=========
Google Spreadsheet already has the script function which support the RSS feed, what I need to be is to find the News feed I interest, import into one sheet, and format it.

+ Import feed: Get CBS news
```javascript
=IMPORTFEED("http://www.cbsnews.com/latest/rss/us", "items", False, 5)
```

+ Format data: Combine news and display today news only
```javascript
= CONCATENATE ( A4, "; ", A5, "; ", A6, "; ", A7, "; ", A8)
```
```javascript
=if(B2=TODAY() , C10 , "Only Support Today's News") 
```

Here is the google docs example: [Google Docs Feed](https://docs.google.com/spreadsheets/d/1eLLajya485g7gG7GvBjqaPXtmTcqXEiRWX0jEp-27bg/edit?usp=sharing)

Jira Status Feed
================
This is the same idea as News Feed, get the data update in Jira, generate the csv or other google script support format, import into google spreadsheet. However, the Jira is using internal network, google docs is public network, it means we have to find a public file server as well.

+ Get Jira data and generate CSV:
Use Java code, the library I use [Jira](https://github.com/rcarz/jira-client)
```java
		BasicCredentials creds = new BasicCredentials("username", "password");
		JiraClient jira = new JiraClient("https://xxx.equilar.com", creds);

		try {
			SearchResult sr = jira
					.searchIssues("project = project AND sprint in openSprints() AND status changed during (-24h, now()) ORDER BY priority DESC, updated DESC");
			
			String csvFile = "./scrum.csv";
	        FileWriter writer = new FileWriter(csvFile);
	        CSVUtils.writeLine(writer, Arrays.asList("Key", "Assignee", "Summary", "Link", "Status"));
			
			for (Issue item : sr.issues) {
				List<String> list = new ArrayList<String>();
				System.out.println(item.getKey());
				System.out.println(item.getAssignee());
				System.out.println(item.getSummary());
				System.out.println(item.getSelf());
				System.out.println(item.getStatus());
				
				list.add(item.getKey());
				list.add(item.getAssignee()==null?"null":item.getAssignee().getName());
				list.add(item.getSummary());
				list.add(item.getSelf());
				list.add(item.getStatus().getName());
				
				CSVUtils.writeLine(writer, list);
			}
	        writer.flush();
	        writer.close();
		} catch (JiraException e) {
			e.printStackTrace();
		} catch (IOException ex){
			ex.printStackTrace();
		}
```

+ Push the scrum.csv to public file server:
The generated source file is was in internal network, need to push to public network, thus google can import it. The storage requirement would be:

1) Can upload the file by script or api
2) Can edit or reload the file
3) It has permanent link for update
4) Free and quick response

I has seek and tried lots of online storage, such as Google driver, Dropbox, Box, FTP, none of them works as I want. Finially I use the github as file server(I only has 1 file need to update), use SSH and windows schedular for submit scripts.

+ Import scrum.csv to Google Spreadsheet:
Similar to Importfeed, we use `=importdata("https://xxxx/scrum.csv")` to import data. 

+ Format data:
Same as new feed, kinds of like `= CONCATENATE ( A4:A8)` 
