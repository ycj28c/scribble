---
layout: post
title: Java RMI Test
disqus: y
share: y
categories: [Language]
tags: [Java, Rmi, Test]
---

RMI is a light way of remote communicate, different from HTTP restful api, RMI require using JAVA in both side. We have a production using RMI, recently need add a test for it.

The easiest way is using the lookup
```java
public class TestRMIConnection {

	private static final String RMI_SERVER_URL = "rmi://10.10.10.10:1099/RMI_SERVICE";
	   
	public static void main(String args[]) throws Exception {	
		
        if (System.getSecurityManager() == null) {
            System.setSecurityManager(new RMISecurityManager());
        }

        try {
            System.out.println("Connecting to " + RMI_SERVER_URL);
            
            long beginTime = System.currentTimeMillis();
            CalculationService service = (CalculationService) Naming.lookup(RMI_SERVER_URL);
            long endTime = System.currentTimeMillis();

            System.out.println("end printing response"); 
        }
        catch (Exception e) {
            logger.error("Exception occured: " + e + " - " + RMI_SERVER_URL);
            logger.error(e);
            e.printStackTrace();
        }
        System.out.println("The test complete");
    }
}

```

I was blocked by the error
```
java.security.AccessControlException: access denied ("java.net.SocketPermission" "10.10.10.10:1099" "connect,resolve")
```

After search, this issue may because of the RMI policy setting, to get more useful information, first need to add debug config. I use eclispe, add below arguments into -> run configuration -> (x)=Arguments -> VM arguments:
```
-Djava.security.debug=access,failure
-Djava.security.policy=client.policy
```

now we are able to print more information:
```
access: access denied ("java.net.SocketPermission" "10.10.10.10:1099" "connect,resolve")
java.lang.Exception: Stack trace
	at java.lang.Thread.dumpStack(Thread.java:1365)
	at java.security.AccessControlContext.checkPermission(AccessControlContext.java:362)
	at java.security.AccessController.checkPermission(AccessController.java:559)
	at java.lang.SecurityManager.checkPermission(SecurityManager.java:549)
	at java.lang.SecurityManager.checkConnect(SecurityManager.java:1051)
	at java.net.Socket.connect(Socket.java:574)
	at java.net.Socket.connect(Socket.java:528)
	at java.net.Socket.<init>(Socket.java:425)
	at java.net.Socket.<init>(Socket.java:208)
	at sun.rmi.transport.proxy.RMIDirectSocketFactory.createSocket(RMIDirectSocketFactory.java:40)
	at sun.rmi.transport.proxy.RMIMasterSocketFactory.createSocket(RMIMasterSocketFactory.java:147)
	at sun.rmi.transport.tcp.TCPEndpoint.newSocket(TCPEndpoint.java:613)
	at sun.rmi.transport.tcp.TCPChannel.createConnection(TCPChannel.java:216)
	at sun.rmi.transport.tcp.TCPChannel.newConnection(TCPChannel.java:202)
	at sun.rmi.server.UnicastRef.newCall(UnicastRef.java:341)
	at sun.rmi.registry.RegistryImpl_Stub.lookup(Unknown Source)
	at java.rmi.Naming.lookup(Naming.java:101)
	at traff.TestRMIConnection.main(TestRMIConnection.java:34)
access: access allowed ("java.security.SecurityPermission" "getPolicy")
```

checked the client.policy and server.policy, they accept all the permission.
```
grant { permission java.security.AllPermission; };
```

Still wrong, after lots of test, it is because the "client.policy" file location is not right. because I using windows, change the path to absolute path:
```
-Djava.security.debug=access,failure
-Djava.security.policy=C:\git\rmi\conf\client.policy
```

Finally, issue solved, now we can test the RMI heart beat test.

Reference
---------
[RMI: access denied](https://community.oracle.com/thread/1177999?start=0)
