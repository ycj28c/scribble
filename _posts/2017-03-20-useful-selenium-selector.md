---
layout: post
title: Useful Selenium Selector
disqus: y
share: y
categories: [Test]
tags: [Selenium, CssSelector]
---

Some selenium magic or tips (Java or Javascript)

* when you not able to use getText(), try below.

```
tickerList.add(tickerElements.get(i).getText().trim());

try below:
tickerList.add(tickerElements.get(i).getAttribute("innerText").trim());  -- works
tickerList.add(tickerElements.get(i).getAttribute("innerHTML").trim());  -- works
tickerList.add(tickerElements.get(i).getAttribute("textContent").trim());  -- works
```

* nth-child

```
td tr
tr:nth-child(3n+1) td:nth-child(-n+1)
3n+1 3 is cycle, 1 is offset

tr:nth-child(odd) tr:nth-child(even)

tr:nth-child(-n+3)
match the first three rows of any table

p:nth-child(1)
match 1st line

tr:nth-child(n+2)
match become with the second row
```

* three way of using selector

```
1.
Select archiveList = new Select(driver.findElement(By.cssSelector("#peerSelect")));
archiveList.selectByIndex(2);

2.
WebElement select = driver.findElement(By.cssSelector("#peerSelect"));
List<WebElement> allOptions = select.findElements(By.tagName("option"));
allOptions.get(2).click();

3.
driver.findElement(By.xpath("//*[@id='peerSelect']/option[2]")).click();
```

* textarea

```
WebElement ticker = driver.findElement(tickerLocator);
return ticker.getAttribute("value");
```

* check box

```
checkbox
if ( !driver.findElement(By.id("idOfTheElement")).isSelected() )
{
     driver.findElement(By.id("idOfTheElement")).click();
}
```

* radio

```
List oRadioButton = driver.findElements(By.name("toolsqa"));
bValue = oRadioButton.get(0).isSelected();
```

* get text from input

```
driver.findElement(endStockPricAvgDateLocator).getAttribute("value").trim();
```

* if trouble getText() from span, consider use javascript way

```
String spanID = "searchHeading";
String script = "return document.getElementById('"+ spanID +"').innerHTML;";
String spanText = (String) ((JavascriptExecutor) driver).executeScript(script);
return spanText;
```

* how to perform mouse over action

```
Actions action = new Actions(webdriver);
WebElement we = webdriver.findElement(By.xpath("html/body/div[13]/ul/li[4]/a"));
action.moveToElement(we).moveToElement(webdriver.findElement(By.xpath("/expression-here"))).click().build().perform();

Actions actions = new Actions(driver);
actions.moveToElement(element).click().build().perform()

mouse over, this seems work for me:
action.moveToElement(reportList.get(0))
				.click(driver.findElement(removeIconLocator)).build().perform();
```

* a element can't use clickable: try this

```
String isDisabled = textlink.getAttribute("disabled");
if (isDisabled==null || !isDisabled.equals("disabled")){
   System.out.println("View link: Enabled");
}else{
   System.out.println("View link: Disabled");
}
some attribute is ture so, also "isDisabled.equals("true")"
```

* compare css

```
driver.findElement(By.id("xxx")).getCssValue("font-size");

is css attribute existed:
String disableCSS = "deactiveCompany";
String cssValue1 = target1.getAttribute("class");
cssValue1.contains(disableCSS);
```

* xpath example

```
By locators = By.xpath("//*[@id='disClosedCalculationTSR']/div[not (contains(@class, 'bgcolor_target'))]"); //not include target company
```

* iframe

```
driver.switchTo().frame(driver.findElement(By.id("IFrameTop")));
driver.switchTo().defaultContent(); //switch back
```