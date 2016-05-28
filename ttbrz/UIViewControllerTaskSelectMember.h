//
//  UIViewControllerSelectMemberOrKanban.h
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:选择执行人或可见人员

#import <UIKit/UIKit.h>
#import "ClassTask.h"
#import "TbCellTaskMember.h"
#import "UIViewControllerEditNewKanbanClass.h"
#import "UIViewControllerEditCreateTaskInKanBan.h"

@interface UIViewControllerTaskSelectMember : UIViewController

@property (assign) BOOL bSelectVisibleMember;
@property (strong,nonatomic) NSArray *arrayData;
@property (strong,nonatomic) NSMutableArray *arraySelectedUser;
- (IBAction)didBtnConfirm:(id)sender;

@end
