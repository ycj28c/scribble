---
layout: post
title: Python And MongoDB
disqus: y
share: y
---
Didn't get chance to use Python and MongoDB in my work, so today try them both together.
The goal is to use python to control the MongoDB, do the basic database operations.

My environment
...
+ Windows 7
+ python-3.6.0a3
+ mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed

1 Install MongoDB
-----------------
Download MongoDB Community Edition: [MongoDB Download Link](http://www.mongodb.org/downloads?_ga=1.90577299.887290330.1469727369)
Follow the official guide to install: [MongoDB Official Guide Link](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-windows/)

Here, I install in ***C:\MongoDB*** folder

After installed, setup your system environment:
for example, add ***C:\MongoDB\Server\3.2\bin*** to your Environment Variables.

Then you able to start Mongo Sever with the storage:

```
C:\> mongod.exe --dbpath c:\MongoDB\data
```

2 Connect MongoDB And Try
----------------------------
**C:\> mongo.exe**

```mango
>>> use test

# insert
>>> db.color.insert({"yellow":1,"red":2,"black":3 })
>>> db.color.insert({"pink":6 })
>>> db.color.insert({"green":8,"blue":9})

>>> db.color.insert({“_id”:1},{"pink":6 }) //this just insert _id key
>>> db.color.insert({"_id":5,"pink":6})  //this record id is 5 
>>> db.color.count()

# search
>>> db.color.find()
>>> db.color.find({“pink”:6})

# update
>>> db.color.update({"_id" : ObjectId("579a6296512931366593462a")},{"pink":9})
>>> db.color.update({"pink":9})

# delete
>>> db.color.remove({"pink ":9})
>>> db.color.remove({})
>>> db.color.drop()
```

3 Install Python
-----------------
Download Python windows version:
[Python Download Link](https://www.python.org/downloads/windows/)

For easily call, also set Environment Variables
[Python Setting Link](https://docs.python.org/2/using/windows.html)
for example, add ***C:\Python36*** to your PATH.

**C:\> py**

4 Install pymongo
-----------------
pymongo is the library for Python to connect to mango. 
Follow the mannual to install: [pymongo Install Link](https://api.mongodb.com/python/current/installation.html)

**python -m pip install pymongo**

5 Python Operate MangoDB
------------------------
Now we are able to use python operate MangoDB, the function is very similar as direct Mango command:

```
#Connect:
:>py
>>> from pymongo import MongoClient 
>>> MongoClient('localhost', 27017) 
>>>db = client.test_database 

#Insert data:
>>>db.color.insert({"green":1}) 
>>> print(db.collection_names)
>>> db.color.find_one()

#Document import example:
>>> import datetime
>>> color = {"author": "Mike",
..."text":"My first blog post!",
..."tags":["mongodb", "python", "pymongo"],
..."date":datetime.datetime.utcnow()}

>>> colors = db.colors
>>> color_id = posts.insert_one(color).inserted_id
>>> color_id
>>>db.colors.find_one({"author":"Mike"})

#Display all the tables:
>>> db.collection_names(include_system_collections=False)
```

6 Python Script
---------------
Now you can create a test.py, use windows command to run all the test together:

```
# connect to db
from pymongo import MongoClient 
client = MongoClient('localhost', 27017) 
db = client.test_database 

# insert data
db.colors.insert({"green":1}) 
db.colors.insert({"yellow":2}) 
db.colors.insert({"red":3}) 
db.colors.insert({"blue":4}) 

# print the result
print("Database basic information:")
print(db.collection_names)
print("==========================================================")

# loop the result
colors = db.colors.find()
for color in colors:
	print(color)
	
# database clean
db.colors.drop()
```

**C:\> test.py**

> Everything is simple and easy to use. Thanks for Python and Mango
