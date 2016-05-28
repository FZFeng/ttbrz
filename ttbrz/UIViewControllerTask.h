//
//  UIViewControllerTask.h
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:任务看板

#import "UIViewControllerBase.h"
#import "ClassTask.h"
#import "UIViewControllerEditNewKanbanClass.h"
#import "UIViewControllerKanbanInfo.h"


@interface UIViewControllerTask : UIViewControllerBase
@property (strong,nonatomic)NSMutableArray *arrayLookBoardData;

//加载数据
- (void)loadingTaskData;

@end
