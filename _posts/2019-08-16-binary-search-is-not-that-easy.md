---
layout: post
title: Binary Search Is Not That Easy
disqus: y
share: y
categories: [Algorithm]
tags: [BinarySearch]
---

Introduce
---------
二分查找真的很简单吗？并不简单。看看 Knuth 大佬（发明 KMP 算法的那位）怎么说的： Although the basic idea of binary search is comparatively straightforward, the details can be surprisingly tricky... 这句话可以这样理解：思路很简单，细节是魔鬼。

Is Binary Search really easy? No, not really. Look at the Knuth (who invent KMP algorithm) said : Although the basic idea of binary search is comparatively straightforward, the details can be surprisingly tricky...   
Short sentence: Idea is simple, detail is devil.

1. 解一直在可行区间里
2. 每次判断后可行区间都会缩小(特别是左右端点相距为0/1的时候)

1. solution always in valid area
2. valid area shrink every time after judgment

Notes
--------
1. 閉包空間(closure) [low, high],[low,high)的不同  
while(low <= high) 代入(3,2)，不存在空間  
while(low < high) 代入(2,2)，還是存在2這個值得  
2. high = mid還是high = mid -1，要根據終止條件  
3. 返回low還是high？ 這個要根據終止條件，如果while(low < high)就無所謂，因爲終止情況就是low=high，而while(low <= high)就不同了？  
4. low更新必須 low = mid + 1，這樣才能避免奇偶的影響  
5. 二分查找別用else了，老老實實else if來判斷較好  
6. low + (high - low)/2 防止整數溢出範圍  

Example Code
------------
```
二分有兩種：注意取值範圍，還有是否mid-1都是由講究的。最好寫上所有if，else if來判斷3種情況>=<，不要用else

//右值点不能取到的情况
int binary_search(vector<int>& nums,int left,int right, int target) {
    //坑点（1）right究竟能不能取到的问题，这里是不能取到的情况
    int low = left;
    int high = right; //這是[)右開包的情況
    while(low<high){
        int mid = low+(high-low)/2;             //坑点（2）这里尽量这么写，因为如果写成(i+j)/2则有溢出的风险
        if(nums[mid]==target)  high = mid;   
        else if(nums[mid]<target)  high = mid;  //坑点（3）因为右值点反正不能取到，所以j就可以等于mid
        else if(nums[mid]>target)  low = mid+1; //坑点（4）應該可以無腦這麽寫，因爲奇偶數最好每次都改變low
    }
    return low; //坑點(5) 要根據題目需要返回要求的邊界
}
//右值点能取到的情况，這是[]閉包的情況，我比較傾向這種寫法
int searchInsert(vector<int>& nums,int left,int right, int target) {
    int low = left;
    int high = right;
    while(low<=high ){
        int mid = low+(high-low)/2;
        if(nums[mid]==target) high = mid-1;
        else if(nums[mid]>target) high = mid-1;
        else if(nums[mid]<target) low = mid+1;
    }
    return low;
}
```

Reference
----------
[关于二分法的边界问题](https://www.1point3acres.com/bbs/thread-300233-1-1.html)    
[二分查找的坑点与总结](https://blog.csdn.net/haolexiao/article/details/53541837)  
[二分查找有几种写法？它们的区别是什么？](https://www.zhihu.com/question/36132386)  
