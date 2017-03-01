---
layout: post
title: Spring Boot Swagger Tip
disqus: y
share: y
---

Here is how I integrate a existing spring boot with swagger and some problem encounter

How To Integrate Swagger
---------------------
It is very easy to integrate swagger with spring-boot. There are resources everywhere in internet.
[GETTING STARTED WITH SWAGGER](http://swagger.io/getting-started/)

In project pom.xml
```
<properties>
    ...
    <springfox.version>2.6.0</springfox.version>
</properties>
...
<dependencies>
...
    <!-- Swagger2 Core -->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger2</artifactId>
        <version>${springfox.version}</version>
    </dependency>
    <!-- Swagger2 UI Package, Show API in Html -->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger-ui</artifactId>
        <version>${springfox.version}</version>
    </dependency>
...
</dependencies>
...
```

Add SwaggerConfig.java in your sprint boot
```
package com.equilar.insightapi;
 
@Configuration
@EnableSwagger2
public class SwaggerConfig {
    /**
     * swagger summary bean
     * @return
     */
    @Bean
    public Docket restApi() {
        Docket docket = new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.xxx.xxx"))
                .paths(PathSelectors.any())
                .build();
        return docket;
    }
    /**
     * API document major information
     * @return
     */
    private ApiInfo apiInfo(){
        ApiInfo apiInfo= (new ApiInfoBuilder())
                .title("xxxx API")
                .description("xxxx API Swagger Document")
                .version("1.0")
                .build();
        return apiInfo;
    }
}
```

How To Set Annotations
---------------------
Swagger is very smart to recognize the existing api and generate pretty document, you can customize the report, there are many resource all over the internet.
[Swagger-Core Annotations](https://github.com/swagger-api/swagger-core/wiki/Annotations-1.5.X)

For example:
```
@ApiOperation(value="clearXXXX",notes="The REST API and script to clear the data in cache and DB for the given company id.")
@ApiResponses({ //swagger - describe return status code
        @ApiResponse(code=200,message="Success. Request completed."),
        @ApiResponse(code=400,message="BAD REQUEST if any validation are failed, like negative company id, invalid metric id."),
        @ApiResponse(code=401,message="Unauthorized Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided."),
        @ApiResponse(code=404,message="Not Found - resource doesn't exist for the specified id."),
        @ApiResponse(code=500,message="Internal Server error."),
})
@RequestMapping(method = RequestMethod.GET, value="/clearFinancialMetricCalc/{companyId}")
@ResponseBody
public Boolean clearXXXX (@PathVariable Long companyId) throws Exception {
    ....
}
```

How To Run SpringBoot With Swagger
---------------------
* Run project by spring-boot:
```
$ mvn spring-boot:run
```
Type http://localhost:8080/swagger-ui.html# in your browser and check the swagger report.
 
* Run project by in tomcat:
(please check 5 Deploy Service To Local Tomcat document)
```
$ cd C:\git\springbootproject
$ mvn clean package
```
Copy the springbootproject.jar to tomcat, then startup tomcat.
Type http://localhost:8080/insight-api/swagger-ui.html# in your browser and check the swagger report.

Troubleshot When Using Swagger
---------------------
* DNS

when use swagger "try it now", but display below error in Response Header:
{
  "error": "no response from server"
}
You may need to add DNS into C:\Windows\System32\drivers\etc\hosts
10.10.10.10 qa-tomcat.xxx.com #qa tomcat

* CORS

When use swagger "try it now", but display below error in browser console
XMLHttpRequest cannot load http://qa-tomcat.xxx.com/clearXXXX
No 'Access-Control-Allow-Origin' header is present on the requested resource.
Origin 'http://10.10.10.10' is therefore not allowed access.
Means you're in CORS situation, If use chrome, install "Allow-Control-Allow-Origin: *" plugin will solve this problem
http://stackoverflow.com/questions/20035101/no-access-control-allow-origin-header-is-present-on-the-requested-resource












