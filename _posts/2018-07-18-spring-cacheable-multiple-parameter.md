---
layout: post
title: Spring Cacheable Multiple Parameter
disqus: y
share: y
categories: [Database]
tags: [Redis, Cookie]
---

Background
----------
This is a weird issue from spring @Cacheable annotation implement, eventually didn't figure out the root cause, however, I got the the solution for it --!

The environment is SpringBoot 1.1.9 (which use spring-core 4.1.3) and Redis, we use SpringBoot function to interact with the Redis.

Issue
-------
We have a simple cache like below:
~~~
@Override
@Cacheable(value = "PerfData")
public List<User> getPerfDataForUserId(Long peerUserId, Long targetUserId) throws Exception {
	return perfDAO.getPerfDataForUserId(peerUserId, targetUserId);
}
@Override
@CacheEvict(value = "PerfData", allEntries = true)
public void clearAllCachePerfData() {
	LOGGER.info("Clear Cache for all PerfData ");
}
@Override
@CacheEvict(value = "PerfData")
public void clearCachePerfDataForUserId(Long peerUserId, Long targetUserId) {
	LOGGER.info("Clear Cache PerfData ");
}
~~~
The issue is if we passed the parameter which are different value such as (peerUserId: 111L, targetUserId: 222L), we are able to get correct value from cache. However, if we passed the same value such as (peerUserId: 111L, targetUserId: 111L), then next time when the value got change, we still got old data from cache.

Troubleshot
----------
After lots of time spent, I identified it was a cache issue because of the Spring @Cacheable annotation. Here is the step to reproduce:

1.flush all the Redis cache

2.read data from application for (peerUserId: 111L, targetUserId: 111L)

3.check the Redis cache, the new record has added
~~~
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 keys *PerfData*
# find cache
"PerfData:\xac\xed\x00\x05sr\x00/org.springframework.cache.interceptor.SimpleKeyL\nW\x03km\x93\xd8\x02\x00\x02I\x00\bhashCode[\x00\x06paramst\x00\x13[Ljava/lang/Object;xp\x00\x12z\xe1ur\x00\x13[Ljava.lang.Object;\x90\xceX\x9f\x10s)l\x02\x00\x00xp\x00\x00\x00\x02sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x00\x00\x00\x00\x93\xb9q\x00~\x00\a"
~~~
4.call the clearAndWarm cache API which evict then cache the keys again for (peerUserId: 111L, targetUserId: 111L)

5.check the Redis cache again, old record still there, and a new record was added
~~~
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 keys *PerfData*
# find cache
"PerfData:\xac\xed\x00\x05sr\x00/org.springframework.cache.interceptor.SimpleKeyL\nW\x03km\x93\xd8\x02\x00\x02I\x00\bhashCode[\x00\x06paramst\x00\x13[Ljava/lang/Object;xp\x00\x12z\xe1ur\x00\x13[Ljava.lang.Object;\x90\xceX\x9f\x10s)l\x02\x00\x00xp\x00\x00\x00\x02sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x00\x00\x00\x00\x93\xb9sq\x00~\x00\x05\x00\x00\x00\x00\x00\x00\x93\xb9"
~~~
6.the application still got the old value

Thus, the issue is because we have two cache value, the getPerfDataForUserId(111L, 111L) original was reading some key with "~\x00\a", looks like it means empty. I tried decode the string with HEX, Unicode and UTF-8, unfortunately I was not able to decode it, the @Cacheable created weird key for some reason.

Test
---------
I realize there was issue regarding @Cacheable before Spring 4.0, it has collapse, however, we are using Spring-core 4.1.3, should be find. To verify, tried below test cases:
~~~
public static void main(String[] args) {
	SimpleKeyGenerator skg = new SimpleKeyGenerator();
	
	Object m1 = skg.generateKey(new Object[] { 109, 434 });
	Object m2 = skg.generateKey(new Object[] { 110, 403 });
	System.out.println(m1.hashCode() +"," +(m2.hashCode()));//same
	System.out.println(m1.equals(m2)); //false
	
	Long l1 = new Long(37817);
	Long l2 = new Long(37817);
	Long l3 = new Long(37817);
	Object key1 = skg.generateKey(l1, l2);
	Object key2 = skg.generateKey(l1, l3);
	System.out.println(key1.hashCode() + "," + key2.hashCode());
	System.out.println(key1.equals(key2)); //true
	
	DefaultKeyGenerator dkg = new DefaultKeyGenerator();
	
	Object n1 = dkg.generateKey(new Object[] { 109, 403 });
	Object n2 = dkg.generateKey(new Object[] { 403, 109 });
	System.out.println(n1.hashCode() +"," +(n2.hashCode())); //same
	
	System.out.println(dkg.generate(null, null, 1, 0)); // 16368
	System.out.println(dkg.generate(null, null, 0, 31)); // 16368
	
	Object key3 = dkg.generate(null, null, l1, l2);
	Object key4 = dkg.generate(null, null, l1, l3);
	System.out.println(key3.hashCode() +","+ key4.hashCode());
	System.out.println(key3.equals(key4)); //true
}
~~~
Tried the default Key Generate "SimpleKeyGenerator" if didn't specify the Key generate in annotation, it can generate the key correctly.

Solution
--------
Didn't find the cause why it create the wrong cache key, but It came out with the solution, we can customize the key to match the Redis, did below change:
~~~
@Override
@Cacheable(value = "PerfData", key = "{#peerUserId.longValue() + '_'+ #targetUserId.longValue()}")
public List<User> getPerfDataForUserId(Long peerUserId, Long targetUserId) throws Exception {
	return perfDAO.getPerfDataForUserId(peerUserId, targetUserId);
}
@Override
@CacheEvict(value = "PerfData", allEntries = true)
public void clearAllCachePerfData() {
	LOGGER.info("Clear Cache for all PerfData ");
}
@Override
@CacheEvict(value = "PerfData", key = "{#peerUserId.longValue() + '_'+ #targetUserId.longValue()}")
public void clearCachePerfDataForUserId(Long peerUserId, Long targetUserId) {
	LOGGER.info("Clear Cache PerfData ");
}
~~~
After this change, the cache read and evict will work fine, it will use only one unique key for the case (peerUserId: 111L, targetUserId: 111L)
~~~
$ /usr/local/bin/redis-cli -h 10.10.10.10 -p 6389 keys *PerfData*
# find cache
"PerfData:\xac\xed\x00\x05sr\x00\x13java.util.ArrayListx\x81\xd2\x1d\x99\xc7a\x9d\x03\x00\x01I\x00\x04sizexp\x00\x00\x00\x01w\x04\x00\x00\x00\x01t\x00\n111_111x"
~~~

Reference
---------
[@Cacheable key on multiple method arguments](https://stackoverflow.com/questions/14072380/cacheable-key-on-multiple-method-arguments)

[Spring Junit Test](https://github.com/spring-projects/spring-framework/blob/master/spring-context/src/test/java/org/springframework/cache/interceptor/SimpleKeyGeneratorTests.java)


