//
//  UIViewControllerMyPlanTask.h
//  ttbrz
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerBase.h"
#import "ClassTask.h"
#import "TbCellTaskInfo.h"
#import "UIViewControllerEditCreateTaskInKanBan.h"

@interface UIViewControllerMyPlanTask : UIViewControllerBase
//操作(增,删,改)看板后更新UI和数据
- (void)initViewAndDataAfterOperateLookBoard;

@end
