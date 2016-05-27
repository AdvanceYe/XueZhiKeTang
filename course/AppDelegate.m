//
//  AppDelegate.m
//  公开课项目1
//
//  Created by AdvanceYe on 15/7/7.
//  Copyright (c) 2015年 AdvanceYe. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MotherViewController.h"
#import "leftViewController.h"
#import "CoreDataDownloadingManager.h"
#import "CacheViewManager.h"
#import "ASIDownloadManager.h"
#import "ActiveCacheModelManager.h"
#import "CacheView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    MotherViewController *motherVC = [[MotherViewController alloc]init];
    
    motherVC.leftViewController = [[leftViewController alloc]init];
    
    ViewController *vc = [[ViewController alloc]init];
    motherVC.rightViewController = [[UINavigationController alloc]initWithRootViewController:vc];
    [motherVC addChildViewController:motherVC.rightViewController];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(printAction)];
    
    //[motherVC.rightViewController.view addGestureRecognizer:tap];
    //[motherVC.rightViewController.view removeGestureRecognizer:tap];
    
    [motherVC.rightViewController addChildViewController:vc];
    self.window.rootViewController = motherVC;
    
    return YES;
}

#pragma mark - 设置可以旋转
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscapeLeft |UIInterfaceOrientationMaskLandscapeRight;
        //return UIInterfaceOrientationMaskLandscapeLeft;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait |UIInterfaceOrientationMaskLandscapeLeft |UIInterfaceOrientationMaskLandscapeRight;
    //return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    return UIInterfaceOrientationPortrait;
}

//删除所有正在进行的的request
-(void)allRequestStopAction
{
    NSArray *array = [[CacheViewManager sharedManager]fetchAllCacheView];
    //每个cacheView对应一个coreData,存值。
    for (CacheView *cacheView in array) {
        LessonDownload *lesson = [[CoreDataDownloadingManager manager]returnLessonByVid:cacheView.model.vid];
        lesson.percentage = @(cacheView.progressView.progress);
        lesson.downloadStatus = @(0);//表示暂停
        [[CoreDataDownloadingManager manager]updateLesson:lesson];
    }
    
    //将queue里面的停掉
    ASINetworkQueue *asiqueue = [[ASIDownloadManager sharedManager]asiQueue];
    NSArray *requestArr = [asiqueue operations];
    
    for (ASIHTTPRequest *request in requestArr) {
        [request cancel];
    }
    
    //将cacheView中request停掉，并删除掉
    [[CacheViewManager sharedManager]deleteAllCacheView];
    
    //cachemodel中request停掉，并删除掉
    [[ActiveCacheModelManager sharedManager]deleteAllCacheModel];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self allRequestStopAction];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self allRequestStopAction];
}




@end
