//
//  AppDelegate.h
//  ttbrz
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemPlist.h"
#import "PublicFunc.h"

#import "UIViewControllerBase.h"
#import "UIViewControllerFirstAd.h"
#import "UIViewControllerUserLoad.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UIViewControllerFirstAdDelegate,UIViewControllerUserLoadDelegate,UITabBarControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (strong,nonatomic)id backgroundSessionCompletionHandler;


@end

