//
//  UIViewControllerAddNewLog.h
//  ttbrz
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:新增日志/编辑日志

#import <UIKit/UIKit.h>
#import "ClassLog.h"
#import "UIViewControllerMyLog.h"

@interface UIViewControllerAddNewLog : UIViewController
@property (strong,nonatomic) NSString *sGetLogContent;
@property (strong,nonatomic) NSString *sGetLogID;


@property (strong,nonatomic) NSString *sGetLogDate;
@property (strong,nonatomic) NSString *sGetConfirmUser;
@property (strong,nonatomic) NSString *sGetConfirmUserID;
@property (assign,nonatomic) BOOL bAddNewLog;//标记是否为新增日志

@end
