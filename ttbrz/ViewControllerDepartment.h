//
//  ViewControllerDepartment.h
//  ttbrz
//
//  Created by apple on 16/3/9.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:部门信息

#import <UIKit/UIKit.h>

#import "TbCellDepartment.h"
#import "ClassLog.h"
#import "UIViewControllerTeamLog.h"
#import "TbCellTeamLog.h"
#import "UIViewControllerTeamIntegral.h"


@interface ViewControllerDepartment : UIViewController

@property (strong,nonatomic) NSArray *arryDepartment;
@property (strong,nonatomic) NSString *sFromUIViewId;//标记从哪个view 进入此页面

@end
