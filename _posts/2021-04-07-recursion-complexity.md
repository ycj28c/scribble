---
layout: post
title: Recursion Complexity
disqus: y
share: y
categories: [Algorithm]
tags: [Recursion, Complexity]
---

The time complexity estimate in recursion senario.

递归情况复杂度
-------------
对于一个排序算法的复杂度我们很熟悉，对于基本的循环迭代复杂度也比较明显。但是在递归状态下的复杂度是比较难判断的，好在有模板master theorem主定理，可以套路化复杂度计算。

先写主定理公式：  
```
T(n) = aT(n/b) + O(n^d)

1.d > logb(a) then T(n) = O(n^d)
2.d == logb(a) then T(n) = O(n^dlogn)
3.d < logb(a) then T(n) = O(n^logb(a))
```

主定理计算实例
-------------
1.比如经典二分场景
```
public void func(int n){
  if(n < 0) {
    return 1;
  }
  return func(n/2) + func(n/2);
}
```
可以套路出公式T(n) = 2 * T(n/2) + O(1)  
这里的T(n/2)就是递归参数变化，而O(1)是每一个递归的操作，因为没操作所以就是O(1)。  
于是得到a = 2, b = 2, d = 0 (注意O(1)这里相当于O(n^0))  
因为d < log2(2)，所以复杂度就是O(n^logb(a)) = O(n)  
空间复杂度可以根据时间复杂度来计算，一共O(logn)次递归，每次递归O(1)空间，所以是O(logn)空间。  

2.再比如在递归中进行了O(n)循环的情况
```
public void func(int n){
  if(n < 0) {
    return 1;
  }
  int s = 0;
  for(int i=0;i<n;i++){
    s += i;
  }
  return s + func(n/2) + func(n/2);
}
```
这里每个循环内有O(n)的操作，所以套路公式T(n) = 2 * T(n/2) + O(n)  
于是得到a = 2, b = 2, d = 1  
因为d == log2(2)，所以复杂度就是O(n^dlogn)就是O(nlogn)  
空间复杂度是O(logn)次递归，每次递归O(1)空间(只有s)，所以是O(logn)空间。

memorization的递归情况
---------------------
时间复杂度公式with meorization：  
> Time complexity: |# of subproblems| * |exclusive running time of a subproblem|  

空间复杂度公式with meorization：  
> Space complexity:|# of subproblems|  + |max recursion depth| * |space complexity of a subproblem|  

1.类似fibonacci的情况
```
public void func(int n){
  if(n < 0) {
    return 1;
  }
  return func(n-1) + func(n-3);
}
```
这种情况是比较复杂的，不好算T(n) = 2 * T(n) + O(1)  
a = 2, b = 1, d = 0, log1(2)，因为1是无法作为底数的，所以这里是无法套用主定理公式的。  
不过我们知道fibonacci是需要使用memorization加速的，所以每个n只需要用到一次。  
所以时间复杂度是O(n)，空间复杂度也是O(n)。

2.带循环的memorization的情况
```
public void func(int left, int right){
  int min = 0;
  for(int i=left;i<=right;i++){
    min = Math.min(min, func(left,i)+func(i,right));
  }
  cache[left][right] = min;
}
```
这种情况因为cache是二维的，所以复杂度是O(n^2)，每种left和right的情况只会计算一次。  
但是由于在每次递归内部又进行了n次的循环，所以复杂度就变成是O(n^3)了。  
空间复杂度则套用公式是O(n^2) + O(n) * O(1) = O(n^2)  
其中cache的复杂度是O(n^2)，递归深度是O(n)，每次递归是O(1)空间。  

排列组合复杂度
-------------
1.permutation排列   
permutation的复杂度是O(n!)  
比如{1,2,3}，就有3*2*1 = 6种，  
{1,2,3},{1,3,2},{2,1,3},{2,3,1},{3,1,2},{3,2,1}  
理解上就是第1位有n种可能，第2位就是剩下的n-1种可能，第3为就是n-2中可能  
n * (n-1) * (n-2) * ... * 1 = n!  

2.combination组合  
combination的复杂度是O(2^n)，如果只是计算一种组合，复杂度是Cn(x)。  
比如{1,2,3，4}个里面取2个的组合有C4(2) = 4 * 3 / (2 * 1) = 6种  
{1,2},{1,3},{1,4},{2,3},{2,4},{3,4}  
而所有的组合有2^4 = 16种  
{},{1},{2},{3},{4},{1,2},{1,3},{1,4},{2,3},{2,4},{3,4},{1,2,3},{1,2,4},{1,3,4},{2,3,4},{1,2,3,4}

Cheatsheet
----------

| Equation  | Time   | Space  | Example  | 
|---|---|---|---|
| T(n) = 2*T(n/2) + O(n) | O(nlogn)  |  O(logn) | quick_sort  |  
| T(n) = 2*T(n/2) + O(n)  | O(nlogn)  | O(n + logn)  | merge_sort  |  
| T(n) = T(n/2) + O(1)  | O(logn)  | O(logn)  | Binary search  |  
| T(n) = 2*T(n/2) + O(1))  | O(n)  | O(logn)  | Binary tree traversal  |  
| T(n) = T(n-1) + O(1)  | O(n) | O(n)  | Binary tree traversal  |  
| T(n) = T(n-1) + O(n)  | O(n^2)  | O(n) | quick_sort(worst case)  |  
| T(n) = n * T(n-1)  | O(n!) | O(n) | permutation |  
| T(n) = T(n-1)+T(n-2)+…+T(1)  | O(2^n)  | O(n)  | combination  |

复杂度分析还是比较难的，上面是一些套路的内容，注意平时做完题想一想时间和空间复杂度。

Reference
---------
1.[花花酱 Time/Space Complexity of Recursion Functions SP4](http://zxi.mytechroad.com/blog/sp/time-space-complexity-of-recursion-functions-sp4/)  
2.[主定理 Master Theorem](https://zhuanlan.zhihu.com/p/100531135)




