//
//  UIViewControllerFirstAd.h
//  ttbrz
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:首次进入App 广告页面

#import <UIKit/UIKit.h>

@protocol UIViewControllerFirstAdDelegate

- (void)didFirstAdFinished;

@end

@interface UIViewControllerFirstAd : UIViewController
@property (assign) BOOL bFromAbout;//标记是否从我的中的关于中进入的;

@property (weak,nonatomic) id<UIViewControllerFirstAdDelegate> delegate;


@end
