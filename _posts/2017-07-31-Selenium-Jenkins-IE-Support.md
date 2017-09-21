---
layout: post
title: Selenium Jenkins IE support
disqus: y
share: y
categories: [Test]
---

We want to use Jenkins run selenium IE test, because the limit resource and lots of tricks on integrate, list the only available solution so far here.

Environment
-----------
+ Test Server: **windows7(1.1.1.45)**
+ Selenium version: **3.2**
+ Selenium Grid: **standalone version 3.4**
+ IE driver: **IEDriverServer.exe 3.4**

Environment Configuration
-------------------------
Currently use my account(xxx123) for selenium grid script running in 1.1.1.45

+ 1.1 remote to 1.1.1.45, configure the windows as below instruction

The IEDriverServer exectuable must be downloaded and placed in your PATH.
On IE 7 or higher on Windows Vista or Windows 7, you must set the Protected Mode settings for each zone to be the same value. The value can be on or off, as long as it is the same for every zone. To set the Protected Mode settings, choose "Internet Options..." from the Tools menu, and click on the Security tab. For each zone, there will be a check box at the bottom of the tab labeled "Enable Protected Mode".

Additionally, "Enhanced Protected Mode" must be disabled for IE 10 and higher. This option is found in the Advanced tab of the Internet Options dialog.

The browser zoom level must be set to 100% so that the native mouse events can be set to the correct coordinates.

For IE 11 only, you will need to set a registry entry on the target computer so that the driver can maintain a connection to the instance of Internet Explorer it creates. For 32-bit Windows installations, the key you must examine in the registry editor is HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE. For 64-bit Windows installations, the key is HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE. Please note that the FEATURE_BFCACHE subkey may or may not be present, and should be created if it is not present. Important: Inside this key, create a DWORD value named iexplore.exe with the value of 0.

+ 1.2 disable the "domain network" of windows firewall, which allow the selenium grid port(4444,5555,5556) works

Start up the selenium grid host and node

host windows bat script(startHub.bat):
```bash
start /B java -jar selenium-server-standalone-3.4.0.jar -role hub
```
node windows bat script(startNode.bat):
```bash 
java -jar selenium-server-standalone-3.4.0.jar -role node -hub http://1.1.1.45:4444/grid/register -port 5556 -host 1.1.1.45 -nodeStatusCheckTimeout 60000
```

add the new testng.xml in test_project to support selenium grid ie running, for example:
```
<suite name="All Suite" parallel="tests" thread-count="1">
	<test name="xxx">
		<parameter name="browser" value="ie" />
		<parameter name="nodeUrl" value="http://1.1.1.45:5556" />
		<classes>
			<class name="test.xxx.ui">
				<methods>
					<include name="testXXXworkflow" />
				</methods>
			</class>
		</classes>
	</test>
</suite>
```
set up a jenkins job for integration
run jenkins and it works

Tips
----
if the remote desktop is open, you can get screenshot when test fail. otherwise you just got black screenshot
current the selenium grid host/node script can be found in 1.1.1.45 C:\tools\SeleniumGrid
selenium grid host: C:\tools\SeleniumGrid\startHub.bat
selenium grid node:  C:\tools\SeleniumGrid\startNode.bat
IE has issue close driver and browser, may occupy lots of machine resource, don't have good way integration yet, use below script to manually clean.
```bash
c:\windows\system32\TASKKILL.exe /F /IM IEDriverServer.exe
c:\windows\system32\TASKKILL.exe /F /IM iexplore.exe
```
can check the selenium grid status by url http://1.1.1.45:4444/grid/console
to be continue...