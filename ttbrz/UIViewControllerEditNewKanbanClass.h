//
//  UIViewControllerAddNewKanban.h
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:新增/编辑看板分类

#import <UIKit/UIKit.h>
#import "PopoverView.h"
#import "ClassTask.h"
#import "UIViewControllerTaskSelectMember.h"
#import "UIViewControllerTask.h"

@interface UIViewControllerEditNewKanbanClass : UIViewController

- (IBAction)didBtnRoot:(id)sender;
- (IBAction)didBtnSelectMember:(id)sender;

@property (assign)BOOL bEditKanban;
@property (strong,nonatomic) ClassTask *cClassTaskData;

- (void)displaySelectedMember:(NSArray*)arraySelectedMember;

@end
