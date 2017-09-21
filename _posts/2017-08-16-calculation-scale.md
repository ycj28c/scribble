---
layout: post
title: Calculation Scale
disqus: y
share: y
categories: [Architecture]
---

It is a thought of the Calculation Scalable. In the now world, big data and cloud are still popular words, people are still struggled with the scalable of the software/service. The big data techonology let scalable become feasible, the cloud provide the infrastructure and flexiable for the computing. The powerful GPU mining is also well known for people.

Never got chance really consider about computing scale, first because the most calculation are fast, instead of using things like hadoop, we'll try to use better algorithm to solve the issue first. The database scalable is handled by the database company, the web performance is handled by web techonology such as load balance, web container etc. The smart guys always step in front of us, figure out the problem because we concern it. We are lucky boys, we just need to understand and implement those techonology.

Recently touch a little bit about calculation scale, backgroud: need to run a bunch of calculation for financial, need do lot of mathematics calculation, run for 1 sample take 2 seconds, each set has about 10-20 samples, each combination has thousands of set, we have 20 combinations. 2 * 15 * 3000 * 20 = 1,800,000 seconds, which means 21 days continue running, which is unacceptable.

When the calculation is still small, we use db store procedure to handle it, do it on the fly, but when the data set grows big, we need to change stragedy, no one will wait 21 days for the results. Here is change:

> 1. Use AWS Batch cloud technology, it run about 10 EC2 instance.
> 2. Can use Cloud Watch to run the command and check the AWS Batch status
> 3. The data source/final result should be in Postgres, use script to output/input db data to/from CSV file.
> 4. In AWS cloud side, use Amazon S3 for data storage and compute temp folder, use script to push/pull CSV.
> 5. Convert the calculation from stored procedure to Java code, use JSON for input and output format.
> 6. As AWS Batch required, make docker image and java environment for calculation.
> 7. Other things may need to improve: log file/multiple thread per docker/error handling

Above solution did inspire me a lot. 
