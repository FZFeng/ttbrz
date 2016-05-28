//
//  UIViewControllerTeamColleagueTask.h
//  ttbrz
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:查看团队任务

#import <UIKit/UIKit.h>
#import "TbCellTaskColleagueInfo.h"
#import "UIViewControllerPlanTask.h"
#import "ClassTask.h"

@interface UIViewControllerTeamColleagueTask : UIViewController

@property (strong,nonatomic)NSMutableArray *arrayGetInitData;
@property (strong,nonatomic)NSString *sGetDepartmentID;

@end
