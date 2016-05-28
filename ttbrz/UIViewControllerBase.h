//
//  UIViewControllerBase.h
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:所有UIViewController的基类 用于统一构建 NavigationItem.title,leftButton,rightButton

#import <UIKit/UIKit.h>
#import "DownMenuView.h"
#import "FZDatePickerView.h"
#import "CalendarDateView.h"
#import "TaskProgressView.h"
#import "UIBarButtonItem+Badge.h"
#import "UIViewControllerSearchInfo.h"
#import "UIViewControllerMessageInfo.h"


#import "ClassLog.h"

extern NSString *KTitleLog_MyLog;
extern NSString *KTitleLog_TeamLog;
extern NSString *KTitleLog_ColleagueLog;
extern NSString *KTitleLog_LogAssess;

extern NSString *KTitleTask_Task;
extern NSString *KTitleTask_TeamTask;
extern NSString *KTitleTask_MyTask;

extern NSString *KTitleIntegral_MyIntegral;
extern NSString *KTitleIntegral_TeamIntegral;

extern NSString *KTitleMy;

extern NSInteger  const KTabBarIndexLog;
extern NSInteger  const KTabBarIndexTask;
extern NSInteger  const KTabBarIndexIntegral;
extern NSInteger  const KTabBarIndexMy;

@interface UIViewControllerBase : UIViewController

@property (strong,nonatomic) UILabel *lblWaittingCheckNotice_Base;
@property (strong,nonatomic) NSString *sUIViewIdenitfy;

- (void)initNavigationWithTabBarIndex:(NSInteger)tabBarIndex
                            menuItemTitle:(NSString*)itemTitle;


@end
