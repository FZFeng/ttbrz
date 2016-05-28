//
//  AppDelegate.m
//  ttbrz
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //有三种情况
    //1.首次安装App进入后弹出广告页
    if (![SystemPlist ExistSystemPlist]) {
        //初始化系统全局信息
        [SystemPlist CreateSystemPlist];

        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@ "Main" bundle: nil ];
        UIViewControllerFirstAd *firstAdView = [storyboard instantiateViewControllerWithIdentifier:@"UIViewFirstAd"];
        firstAdView.delegate=self;
        self.window.rootViewController = firstAdView;
    }else{
        //2.非首进入App 用户未登录 直接进入登录界面
        if (![SystemPlist GetLogin]) {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@ "Main" bundle: nil ];
            UIViewControllerUserLoad *loadView = [storyboard instantiateViewControllerWithIdentifier:@"UIViewUserLoad"];
            loadView.delegate=self;
            self.window.rootViewController = loadView;
        }else{
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@ "Main" bundle: nil ];
            UINavigationController *navMain = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationMain"];
            
            //得到对应的UITabBarController 并设置回调 要storyboard 中 nav的 root view 就是firstObject
            UITabBarController *tabBarMain=(UITabBarController*)[navMain.viewControllers firstObject];
            tabBarMain.tabBar.selectedImageTintColor = defaultColor;
            tabBarMain.delegate=self;
            self.window.rootViewController = navMain;
            
            [self getUserLimitInfo];
        }
    }
    return YES;
}

#pragma mark 获取软件使用期限及日志填报时限
- (void)getUserLimitInfo{
    //3.非首进入App 用户已登录 验证使用期限
    [ClassUser getLoginInfoWithUserName:[SystemPlist GetLoadUser] pwd:[SystemPlist GetLoadPwd] returnBlock:^(BOOL bReturn, ClassUser *cUserObject) {
        if (bReturn) {
            BOOL bOutTime=NO;  //是否已过期
            BOOL bNeedAlert=NO;//是否要提示
            
            NSString *sLimitText=@"";
            NSInteger iEndDay=[cUserObject.sEndDay integerValue];
            
            if (iEndDay<=5 && iEndDay>0) {
                bNeedAlert=YES;
            }else if (iEndDay<0){
                bOutTime=YES;
            }
            
            if ([cUserObject.sBuyEmployee isEqualToString:@"0"]) {
                //试用用户
                if (bOutTime) {
                    sLimitText=[NSString stringWithFormat:@"试用已到期,到期时间:%@ \n请登录 PC 付费购买",cUserObject.sEndTime];
                }else{
                    sLimitText=[NSString stringWithFormat:@"授权使用剩余 %ld 天\n试用到期时间:%@ \n请登录 PC 付费购买",(long)iEndDay,cUserObject.sEndTime];
                }
            }else{
                //正式用户
                if (bOutTime) {
                     sLimitText=[NSString stringWithFormat:@"授权已到期,到期时间:%@ \n请登录 PC 付费购买",cUserObject.sEndTime];
                }else{
                     sLimitText=[NSString stringWithFormat:@"授权使用剩余 %ld 天\n授权到期时间:%@ \n请登录 PC 付费购买",(long)iEndDay,cUserObject.sEndTime];
                }
            }
            
            if (bNeedAlert) {
                if (bOutTime) {
                    //超时提示 让程序不能使用
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:sLimitText delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    //未超时但在5天内的
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:sLimitText delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
    }];
}

#pragma mark UIViewControllerFirstAd 的delegate
- (void)didFirstAdFinished{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@ "Main" bundle: nil ];
    UIViewControllerUserLoad *loadView = [storyboard instantiateViewControllerWithIdentifier:@"UIViewUserLoad"];
    loadView.delegate=self;
    self.window.rootViewController = loadView;
}

#pragma mark UIViewControllerUserLoadDelegate
- (void)didUserLoadFinished{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@ "Main" bundle: nil ];
    UINavigationController *navMain = [storyboard instantiateViewControllerWithIdentifier:@"UINavigationMain"];
    //得到对应的UITabBarController 并设置回调 要storyboard 中 nav的 root view 就是firstObject
    UITabBarController *tabBarMain=(UITabBarController*)[navMain.viewControllers firstObject];
    tabBarMain.tabBar.selectedImageTintColor = defaultColor;
    tabBarMain.delegate=self;
    self.window.rootViewController = navMain;
    
    //获取软件使用期限及日志填报时限
    [self getUserLimitInfo];
}

#pragma mark 实现UITabBarController代理
- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController{
    
    UIViewControllerBase *baseView=((UIViewControllerBase*)viewController);
    NSString *sUIViewIdentify=baseView.sUIViewIdenitfy;
    
    NSString *sTitle=viewController.tabBarItem.title;
    if ([sTitle isEqualToString:@"日志"]) {
        if ([sUIViewIdentify isEqualToString:KTitleLog_MyLog]) {
            [baseView initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_MyLog];
        }else if ([sUIViewIdentify isEqualToString:KTitleLog_TeamLog]){
            [baseView initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_TeamLog];
        }else if ([sUIViewIdentify isEqualToString:KTitleLog_ColleagueLog]){
            [baseView initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_ColleagueLog];
        }else{
            [baseView initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_LogAssess];
        }
    }else if ([sTitle isEqualToString:@"任务"]){
        if ([sUIViewIdentify isEqualToString:KTitleTask_Task]) {
            [baseView initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_Task];
        }else if ([sUIViewIdentify isEqualToString:KTitleTask_TeamTask]){
            [baseView initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_TeamTask];
        }else{
            [baseView initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_MyTask];
        }
    }else if ([sTitle isEqualToString:@"积分"]){
        if ([sUIViewIdentify isEqualToString:KTitleIntegral_MyIntegral]) {
            [baseView initNavigationWithTabBarIndex:KTabBarIndexIntegral menuItemTitle:KTitleIntegral_MyIntegral];
        }else{
            [baseView initNavigationWithTabBarIndex:KTabBarIndexIntegral menuItemTitle:KTitleIntegral_TeamIntegral];
        }
    }else{
        [baseView initNavigationWithTabBarIndex:KTabBarIndexMy menuItemTitle:KTitleMy];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}


//-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
//    
//    //backgroundSessionCompletionHandler是自定义的一个属性
//    self.backgroundSessionCompletionHandler=completionHandler;
//    
//}
//
//-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    //Other Operation....
//    
//    if (appDelegate.backgroundSessionCompletionHandler) {
//        
//        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
//        
//        appDelegate.backgroundSessionCompletionHandler = nil;
//        
//        completionHandler();
//        
//    }
//}

@end
