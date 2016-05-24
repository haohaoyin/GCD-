//
//  ViewController.m
//  GCD信号量
//
//  Created by yinhao on 16/3/31.
//  Copyright © 2016年 yinhao. All rights reserved.
//

/**
 控制并发有 信号量 or NSOperationQueue
 */
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self semaphoreTest];
    
    [self semaphoreTest];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 
 <#dispatch_semaphore_t dsema#> 
 信号量
 
 dispatch_semaphore_create(<#long value#>)    ****相当于剩余的车位
 创建一个信号量为value的信号量 value的值必须大于0
 
 
 dispatch_semaphore_signal(<#dispatch_semaphore_t dsema#>)   ****相当于走了一辆车
 返回值是一个long类型 如果返回值大于0 表示有可用的线程(可用线程为返回值) 唤醒当前等待的一条或多条线程
 如果返回值为0 则信号量加1
 
 
 dispatch_semaphore_wait(<#dispatch_semaphore_t dsema#>, <#dispatch_time_t timeout#>) ****相当于来了一辆车
 返回值是一个long类型 如果返回值大于0 表示可用的线程要被占用一个 信号量的值需要减去这个数值 
 如果这时候信号量为0 则表示需要等待timeout时间 如果信号量一直为0 等待timeout后 则所处线程自动执行后面的语句
 
 
 */
- (void)semaphoreTest
{
    //创建一个信号量为5的信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 100; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //
        
        dispatch_group_async(group, queue, ^{
            NSLog(@"%i",i);
            sleep(2);
            dispatch_semaphore_signal(semaphore);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

}



- (void)NSOperationQueueTest
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //队列中最大操作数
    queue.maxConcurrentOperationCount = 10;
    
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 100; i++) {
            
            NSLog(@"执行并发队列1:%d",i);
        }
    }];
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^(){
        
        for (int i = 0; i < 100; i++) {
            
            NSLog(@"执行并发队列2:%d",i);
        }
    }];
    
    //添加操作与操作之间的依赖 (一个操作完成后才会进行第二个操作)
    [operation1 addDependency:operation2];
    //将操作加入队列中 自动开线程执行操作
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    
}
@end
