---
layout: post
title: CompletableFuture Implement At Multiple Thread
disqus: y
share: y
categories: [Dev]
tags: [MultiThread]
---

Background
----------
最近有这么一个问题：  
1.数据库返回一个List的数据，要求对每个数据点结构进行过滤，满足要求的加入result。  
2.每个数据点都是独立的，是从cache中获取的，相互间没有依赖关系。  
3.如果result数量达到了上限比如250，那么就终止多线程，直接返回结果。  

Thinking
--------
多线程从Java1.5就有了，之前使用多线程就无脑的拷贝旧代码，比如Executor, Callable, Future啥的，但是这些都是老API了，应用上是有缺陷的，比如
```java
List<Future<?>> futureList = executor.invokeAll(callableList);
for (Future<List<?>> future : futureList) {
    future.get();
}
```
如果invokeAll就会运行直到全部线程结束，中途无法终止。这样提前跳出多线程就无法实现。也可以将future写在循环内
```java
for(int i=0;i<100;i++){
    Callable<A> callable = () -> new AnyFunction();
    Future future = executor.submit(profileGDFVDataCallable);
    future.get();
}
```
这样的话可以获取每个线程的结果，然后根据结果就可以call executorService.shutdownNow()直接中断，但是future.get()会阻塞主线程，所以这个实际上就是单线程在跑了。

如果解决呢，一种方式就是使用CompletionService抱在ExecutiveService之上，见[reference[1](https://www.cnblogs.com/dennyzhangdd/p/7010972.html)]
```
public static void main(String[] args)  {
    Long start = System.currentTimeMillis();
    //开启3个线程
    ExecutorService exs = Executors.newFixedThreadPool(5);
    try {
        int taskCount = 10;
        //结果集
        List<Integer> list = new ArrayList<Integer>();
        //1.定义CompletionService
        CompletionService<Integer> completionService = new ExecutorCompletionService<Integer>(exs);  
        List<Future<Integer>> futureList = new ArrayList<Future<Integer>>();
        //2.添加任务
        for(int i=0;i<taskCount;i++){
            futureList.add(completionService.submit(new Task(i+1)));
        }

        //使用内部阻塞队列的take()
        for(int i=0;i<taskCount;i++){
            Integer result = completionService.take().get();//采用completionService.take()，内部维护阻塞队列，任务先完成的先获取到
            System.out.println("任务i=="+result+"完成!"+new Date());
            list.add(result);
        }
        System.out.println("list="+list);
        System.out.println("总耗时="+(System.currentTimeMillis()-start));
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        exs.shutdown();//关闭线程池
    }	 
}
```
但是感觉还是缺乏灵活性

CompletableFuture
-----------------
在Java1.8有了CompletableFuture，功能上比较多，可以用lambda，可以catch exception，比较好用。  
而且最重要的是使用CompletableFuture可以在多线程的同时还处理返回数据，也就是说get()不block，性能好又好用，所以在Java8后无脑用这个就行。 

[reference[1](https://www.cnblogs.com/dennyzhangdd/p/7010972.html)]的例子很好，这里再抄一个
```java
public static void main(String[] args) {
    Long start = System.currentTimeMillis();
    //结果集
    List<String> list = new ArrayList<String>();
    List<String> list2 = new ArrayList<String>();
    //定长10线程池
    ExecutorService exs = Executors.newFixedThreadPool(10);
    List<CompletableFuture<String>> futureList = new ArrayList<>();
    final List<Integer> taskList = Lists.newArrayList(2,1,3,4,5,6,7,8,9,10);
    try {
        ////方式一：循环创建CompletableFuture list,调用sequence()组装返回一个有返回值的CompletableFuture，返回结果get()获取
        //for(int i=0;i<taskList.size();i++){
        //    final int j=i;
        //    //异步执行
        //    CompletableFuture<String> future = CompletableFuture.supplyAsync(()->calc(taskList.get(j)), exs)
        //        //Integer转换字符串    thenAccept只接受不返回不影响结果
        //        .thenApply(e->Integer.toString(e))
        //        //如需获取任务完成先后顺序，此处代码即可
        //        .whenComplete((v, e) -> {
        //            System.out.println("任务"+v+"完成!result="+v+"，异常 e="+e+","+new Date());
        //            list2.add(v);
        //        })
        //        ;
        //    futureList.add(future);
        //}
        ////流式获取结果：此处是根据任务添加顺序获取的结果
        //list = sequence(futureList).get();
		 
        //方式二：全流式处理转换成CompletableFuture[]+组装成一个无返回值CompletableFuture，join等待执行完毕。返回结果whenComplete获取
        CompletableFuture[] cfs = taskList.stream().map(object-> CompletableFuture.supplyAsync(()->calc(object), exs)
            .thenApply(h->Integer.toString(h))
            //如需获取任务完成先后顺序，此处代码即可
            .whenComplete((v, e) -> {
                System.out.println("任务"+v+"完成!result="+v+"，异常 e="+e+","+new Date());
                list2.add(v);
            })).toArray(CompletableFuture[]::new);
        //等待总任务完成，但是封装后无返回值，必须自己whenComplete()获取
        CompletableFuture.allOf(cfs).join();
        System.out.println("任务完成先后顺序，结果list2="+list2+"；任务提交顺序，结果list="+list+",耗时="+(System.currentTimeMillis()-start));
    } catch (Exception e) {
        e.printStackTrace();
    }finally {
        exs.shutdown();
    }
} 
```

下面是我最后使用的到达limit就跳出的例子：
```java
//get test data in multi threading
List<TestData> resultList = new ArrayList<>();
//using the CompletableFuture instead of future to avoid the blocking the main thread
List<CompletableFuture<TestData>> futureList = new ArrayList<>();
for (int i=0;i<10000000;i++) {
    CompletableFuture<TestData> future = CompletableFuture.supplyAsync(() ->{
        //这里可以写上处理逻辑，也可以将某些logic写法stream lambda的表达式中去比如thenCombine（）
        RawData rawData = TestDao.findRawData(i);
        if(rawData != null){
            return convertToRealData(rawData);
        }
        return null;
    }, executorService).exceptionally(e -> {
        System.out.println("Failed to get test Data", e.getCause());
        return null;
    });
    futureList.add(future);
}
if(!Util.isNullOrEmpty(futureList)){
    for(int i=0; i < futureList.size(); i++){
        CompletableFuture<TestData> future = futureList.get(i);
        TestData data = future.get(1, TimeUnit.MINUTES);
        if(data != null){
            if(resultList.size() < 250){
                resultList.add(data);
            } else {
                // jump out early when hit the company limit
                executorService.shutdownNow();
                break;
            }
        }
    }
}
```

唯一的缺点就是也要写不少代码，虽然CompletableFuture.supplyAsync处理比较方便，不过对于每个线程的异常还是需要单独处理，如果内部方法丢出Exception(不是RuntimeException)的话还要再去try catch，而不同直接用stream来处理。stream的调用过程中也要避免有错误，否则stream就被破坏了，结果未知呵呵。

Reference
----------
1.[CompletableFuture原理解析](https://www.jianshu.com/p/abfa29c01e1d)      
2.[多线程并发执行任务，取结果归集。终极总结：Future、FutureTask、CompletionService、CompletableFuture](https://www.cnblogs.com/dennyzhangdd/p/7010972.html)      

