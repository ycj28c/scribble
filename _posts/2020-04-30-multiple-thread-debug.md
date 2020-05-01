---
layout: post
title: Multiple Thread Debug
disqus: y
share: y
categories: [Dev]
tags: [MultiThread]
---

Background
----------
Recently has an issue that sending a list of request to backend, but sometimes the return result is mismatch. It looks like typical concurrency issue.

After some investigation, found the attribute defined at SearchDAOImpl may have potential concurrency issue, such as applicableCriteria or criteria. Because Spring @Autowired is likely singleton implement, so those attribute defined at SearchDAOImpl may mismatch in multi-thread environment (synchronized lock the hasApplicableCriteria() method, but applicableCriteria value still could change before it is called later by SearchDAOImple.search() method). For example, thread1 use CFO criteria first time, it set CFO to applicableCriteria, but then thread2 override it by
```
applicableCriteria = new HashSet<SearchCriterion>();
```
which may cause concurrent issue.

Simulation
----------
In order to figure out the cause, I did some local multi-thread test to simulate the executive matching, it looks like runSearchForPDF may got mismatch when run for more thread and more executive, attach code here:

SearchDaoImpl:
```
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class SearchDAOImpl {

    private static SearchDAOImpl single_instance = null;
    private SearchDAOImpl(){}
    public static SearchDAOImpl getInstance()
    {
        if (single_instance == null)
            single_instance = new SearchDAOImpl();
        return single_instance;
    }

    private List<Integer> applicableCriteria;
    //private List<Integer> criteria;
    private Set<Long> companyIds; //dummy criteria for simulation

    public synchronized void hasApplicableCriteria(List<Integer> criteria, Set<Long> companyIds) {
        applicableCriteria = new ArrayList<>();
        //this.criteria = criteria;
        this.companyIds = companyIds;

        hasApplicableCriteria(criteria);
    }
    private void hasApplicableCriteria(List<Integer> criteria) {
        synchronized (applicableCriteria) {
            for(int tmp : criteria){
                applicableCriteria.add(tmp);
            }
        }
    }
    public List<Integer> search(){
        return new ArrayList<>(applicableCriteria);
    }

}
```
TCRSearchServiceImpl:
```
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class TCRSearchServiceImpl {

    private final long preProcessTime = 1000;
    private final long processTime = 1;
    private final long postProcessTime = 1000;
    private static AtomicInteger totalMismatch = new AtomicInteger();

    public void runSearchForPDF(List<Integer> criteria){
        // process time before use TCRSearchServiceImpl.applicableCriteria
        pause(preProcessTime);

        /////////////// Simulate RunSearchForPDF /////////////////////
        List<Integer> criteriaCopy = new ArrayList<>(criteria);
        SearchDAOImpl.getInstance().hasApplicableCriteria(criteria, null);

        // assume it is immediately call TCRSearchServiceImpl.applicableCriteria
        //pause(processTime);

        List<Integer> searchResult = SearchDAOImpl.getInstance().search();

        // when we compare the result, could still mismatch
        if(!criteriaCopy.equals(searchResult)){
            System.out.println(totalMismatch.addAndGet(1) + ".Find Mismatch, "
                    + "Original Criteria: " + criteriaCopy + ", Run Search Criteria: " + searchResult);
        }
        //////////////////////////////////////////////////////////////

        // process time after use TCRSearchServiceImpl.applicableCriteria
        pause(postProcessTime);
    }

    private static void pause(long time){
        try {
            Thread.sleep(time);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```
SimulateMutiThreadExecSearchCall:
```
import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

class RunSearchCall implements Callable {
    List<Integer> criteria;
    public RunSearchCall(List<Integer> criteria){
        this.criteria = criteria;
    }
    @Override
    public Object call() {
        TCRSearchServiceImpl tmp = new TCRSearchServiceImpl();
        tmp.runSearchForPDF(criteria);
        return null;
    }
}
public class SimulateMutiThreadExecSearchCall {

    private static final int executives = 100;
    private static final int criteria = 3;
    private static final int threadPool = 10;

    public static void main(String args[]){
        List<Callable<List<Integer>>> callableList = new ArrayList<>();
        for(int i = 0; i< executives; i++){
            List<Integer> criteria = new ArrayList<>();
            for(int j = 0; j< SimulateMutiThreadExecSearchCall.criteria; j++){
                Integer rand = new Random().nextInt(99999999); //use random number to simulate different criteria
                criteria.add(rand);
            }
            Callable<List<Integer>> runSearchCall = new RunSearchCall(criteria);
            callableList.add(runSearchCall);
        }

        ExecutorService executor = Executors.newFixedThreadPool(threadPool);
        try {
            executor.invokeAll(callableList);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            executor.shutdown();
        }

    }
}
```

Some Observation here:
```
3.Find Mismatch, Original Criteria: [37449549, 58851796, 23987916], Run Search Criteria: []
2.Find Mismatch, Original Criteria: [55574938, 65409236, 10801371], Run Search Criteria: []
1.Find Mismatch, Original Criteria: [90407127, 27503600, 97463696], Run Search Criteria: []
4.Find Mismatch, Original Criteria: [89873975, 35250693, 10605031], Run Search Criteria: []
5.Find Mismatch, Original Criteria: [31007994, 92745167, 48061356], Run Search Criteria: []
```
Which appears that applicableCriteria will be empty value when calling search, in this case the search function may try to search all the executives, which cause slowness.


Reference
----------
1.[Spring @Autowired 注入小技巧](https://juejin.im/post/5b557331e51d45191c7e64d2)    
2.[SpringBoot 单例Bean中实例变量线程安全研究](https://blog.csdn.net/lililuni/article/details/92376523)    

