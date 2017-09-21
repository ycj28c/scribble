---
layout: post
title: Java Object To Json
disqus: y
share: y
categories: [Language]
tags: [Jackson, Java, Json]
---

Here is the example of using Java jackson to convert object to json trick.

we have a class like below, pay attention to the isActive attribute.
```java
//original class
public abstract class AbstractLookup implements ILookup {

	private Integer lookupId;
	private String description;
	private Integer sortOrder;
	private Boolean isActive;

	public AbstractLookup() {
	}
	public AbstractLookup(Integer lookupId) {
		setLookupId(lookupId);
	}
	public Integer getLookupId() {
		return lookupId;
	}
	public void setLookupId(Integer lookupId) {
		this.lookupId = lookupId;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Integer getSortOrder() {
		return sortOrder;
	}
	public void setSortOrder(Integer sortOrder) {
		this.sortOrder = sortOrder;
	}
	private Boolean getIsActive() {
		return isActive;
	}
	public Boolean isActive() {
		return getIsActive() == null ? false : getIsActive().booleanValue();
	}
	public void setIsActive(Boolean isActive) {
		this.isActive = isActive;
	}
}

public PeerCode extends AbstractLookup{
	...
}
```

We tried to convert the PeerCode modle class to json
```java
PeerCode peerCode = new PeerCode ();
...
ObjectMapper mapper = new ObjectMapper();
String peerCodeStr =  mapper.writerWithDefaultPrettyPrinter().writeValueAsString(peerCode);
```

We got the exception:
```
Caused by: com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException: Unrecognized field "active" (class com.xxx.PeerCode), not marked as ignorable (4 known properties: "sortOrder", "isActive", "lookupId", "description"])
 at [Source: java.io.PushbackInputStream@188daa2; line: 12, column: 21] (through reference chain: com.xxxx.PeerCode["active"])
	at com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException.from(UnrecognizedPropertyException.java:51)
```

Because we have a method "isActive()" which is not belong to the standard model class, jackson think there is a attribute call "active", thus it not able to match this attribute to the target class.

Two solution:	
https://stackoverflow.com/questions/14708386/want-to-hide-some-fields-of-an-object-that-are-being-mapped-to-json-by-jackson
	
1. use @JsonIgnoreProperties annotation
```java
@JsonIgnoreProperties(ignoreUnknown = true)
public abstract class AbstractLookup implements ILookup {
...
}
```
We got the result json
```
{
  "PeerCode" : {
    "lookupId" : null,
    "description" : null,
    "sortOrder" : null,
    "p4pPeerGroupId" : 2,
    "active" : false
  }
}
```
It is not right, because isActive become active

2. use @JsonIgnore annotation
```
@JsonIgnore
public Boolean isActive() {
	return getIsActive() == null ? false : getIsActive().booleanValue();
}
```
We got the result json
```
{
  "PeerCode" : {
    "lookupId" : null,
    "description" : null,
    "sortOrder" : null,
    "p4pPeerGroupId" : 2
  }
}
```
The active is gone, not seems right

So we need add addition annotation to customize the name of the getIsActive method
```
import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
...
@JsonGetter("isActive")
private Boolean getIsActive() {
	return isActive;
}
```
Finally it display correct:
```
{
  "PeerCode" : {
    "lookupId" : null,
    "description" : null,
    "sortOrder" : null,
    "p4pPeerGroupId" : 2,
    "isActive" : true
  }
}
```

Final abstract class AbstractLookup
```java
public abstract class AbstractLookup implements ILookup {

	private Integer lookupId;
	private String description;
	private Integer sortOrder;
	private Boolean isActive;

	public AbstractLookup() {
	}
	public AbstractLookup(Integer lookupId) {
		setLookupId(lookupId);
	}
	public Integer getLookupId() {
		return lookupId;
	}
	public void setLookupId(Integer lookupId) {
		this.lookupId = lookupId;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Integer getSortOrder() {
		return sortOrder;
	}
	public void setSortOrder(Integer sortOrder) {
		this.sortOrder = sortOrder;
	}
	@JsonGetter("isActive")
	private Boolean getIsActive() {
		return isActive;
	}
	@JsonIgnore
	public Boolean isActive() {
		return getIsActive() == null ? false : getIsActive().booleanValue();
	}
	public void setIsActive(Boolean isActive) {
		this.isActive = isActive;
	}
}
```
