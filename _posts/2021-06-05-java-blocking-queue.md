---
layout: post
title: Java Blocking Queue
disqus: y
share: y
categories: [Dev]
tags: [Queue, MultiThread, Java]
---

Multiple ways to implement the blocking queue in Java in multiple threads environment.

生产者消费者问题是一个很经典的问题，这里用多种方式展示了Java中写Blocking Queue的方式

1.使用Java自带的Blocking Queue结构，最简单
```
class BoundedBlockingQueue {
    private LinkedBlockingQueue<Integer> queue;
    public BoundedBlockingQueue(int capacity) {
        this.queue = new LinkedBlockingQueue<>(capacity);
    }
    
    public void enqueue(int element) throws InterruptedException {
        queue.put(element);
    }
    
    public int dequeue() throws InterruptedException {
        return queue.take();
    }
    
    public int size() {
        return queue.size();
    }
}
```

2.使用信号量的方式  
信号量就是标准的多锁模式，可以设置锁的数量， 应用比较简单，    
一个信号量equeueSema对enqueue进行阻塞，一个信号量dequeueSema对dequeue进行阻塞。
```
class BoundedBlockingQueue {

    private Queue<Integer> queue;
    private Semaphore equeueSema;
    private Semaphore dequeueSema;
    public BoundedBlockingQueue(int capacity) {
        this.queue = new LinkedList<>();
        this.equeueSema = new Semaphore(capacity);
        this.dequeueSema = new Semaphore(0);
    }
    
    public void enqueue(int element) throws InterruptedException {
        equeueSema.acquire();
        queue.offer(element);
        dequeueSema.release();
    }
    
    public int dequeue() throws InterruptedException {
        dequeueSema.acquire();
        int val = queue.poll();
        equeueSema.release();
        return val;
    }
    
    public int size() {
        return queue.size();
    }
}
```

3.最古老传统的synchronized的方式  
比较重量级的锁，需要使用wait和notifyAll的方法来切换线程。  
```
class BoundedBlockingQueue {

    //lock的做法
    private Queue<Integer> queue;
    private int cap;
    public BoundedBlockingQueue(int capacity) {
        this.cap = capacity;
        this.queue = new LinkedList<>();
    }
    
    public synchronized void enqueue(int element) throws InterruptedException {
        while(queue.size() == cap){
            wait(); //当前挂起
        }
        queue.offer(element);
        notifyAll();
    }
    
    public synchronized int dequeue() throws InterruptedException {
        while(queue.isEmpty()){
            wait(); 
        }
        int val = queue.poll();
        notifyAll();
        return val;
    }
    
    public int size() {
        return queue.size();
    }
}
```

4.使用轻量级的可重入锁ReenTrantLock方法  
和synchronized的思路是完全一样的，不过是基于CAS的所以特别快，而且减少了死锁的可能性，  
对应的lock操作是condition，lock，unlock和await功能， 模板就是如下：  
```
lock.lock();
try {
	//do something
} finally {
	lock.unlock();
}
```
ReenTrantLock是使用Condition对象来实现wait和notify的功能。  
和synchronized对比的话就是：  
Signal = Notify  
SignalAll = NotifyAll  
Await = Wait  
```
class BoundedBlockingQueue {
    private ReentrantLock lock = new ReentrantLock();
    private Condition full = lock.newCondition();
    private Condition empty = lock.newCondition();
    private Queue<Integer> queue;
    private int cap;
    public BoundedBlockingQueue(int capacity) {
        this.queue = new LinkedList<>();
        this.cap = capacity;
    }
    
    public void enqueue(int element) throws InterruptedException {
        lock.lock();
        try{
            while(queue.size() == cap){
                full.await();
            }
            queue.offer(element);
            empty.signal();
        } finally {
            lock.unlock();
        }
    }
    
    public int dequeue() throws InterruptedException {
        lock.lock();
        try {
            while(queue.isEmpty()){
                empty.await();
            }
            int val = queue.poll();
            full.signal();
            return val;
        } finally{
            lock.unlock();
        }
    }
    
    public int size() {
        lock.lock();
        try {
            return queue.size();
        } finally{
            lock.unlock();
        }
    }
}
```

5.更优雅的读写锁  
使用了ReentrantReadWriteLock读写锁，因为在调用size（）的时候只是读取，无需阻塞。  
写的比较复杂，要从ReadWriteLock分出read锁和write锁，而且其中的write锁还要根据queue的大小来锁定。  
读写锁的特点是：
1）write的时候阻塞，只有一个线程能够执行，用于enqueue和dequeue
2）read的时候可以独立执行，随便读，用于获取queue.size()
在写比较多的场景下，性能是最好的。
```
class BoundedBlockingQueue {

    private ReadWriteLock lock = new ReentrantReadWriteLock();
    private Lock read = lock.readLock();
    private Lock write = lock.writeLock();
    private Condition full = write.newCondition();
    private Condition empty = write.newCondition();
    private Queue<Integer> queue;
    private int cap;
    public BoundedBlockingQueue(int capacity) {
        this.queue = new LinkedList<>();
        this.cap = capacity;
    }
    
    public void enqueue(int element) throws InterruptedException {
        write.lock();
        try{
            while(queue.size() == cap){
                full.await();
            }
            queue.offer(element);
            empty.signal();
        } finally {
            write.unlock();
        }
    }
    
    public int dequeue() throws InterruptedException {
        write.lock();
        try {
            while(queue.isEmpty()){
                empty.await();
            }
            int val = queue.poll();
            full.signal();
            return val;
        } finally{
            write.unlock();
        }
    }
    
    public int size() {
        read.lock();
        try {
            return queue.size();
        } finally{
            read.unlock();
        }
    }
}
```

Reference
----------
1.[使用ReadWriteLock](https://www.liaoxuefeng.com/wiki/1252599548343744/1306581002092578)  



