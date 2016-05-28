//
//  UIViewControllerCreateTaskInKanBan.h
//  ttbrz
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:新增/编辑 任务

#import <UIKit/UIKit.h>
#import "ClassLog.h"
#import "FZDatePickerView.h"
#import "UIViewControllerTaskSelectMember.h"
#import "UIViewControllerTaskSelectKanBan.h"
#import "UIViewControllerKanbanInfo.h"
#import "UIViewControllerMyPlanTask.h"

@interface UIViewControllerEditCreateTaskInKanBan : UIViewController

- (IBAction)didBtnSelectExecuteUserID:(id)sender;
- (IBAction)didBtnSelectDate:(id)sender;
- (IBAction)didBtnTaskFinishDate:(id)sender;


@property (strong,nonatomic) NSString *sGetLookBoard;
@property (strong,nonatomic) NSString *sGetLookBoardID;
@property (strong,nonatomic) NSString *sGetTaskID;
@property (assign)BOOL bEditTask;
@property (assign)BOOL bFormMyPlanTaskView;//标记是否从 任务 "我的安排"中进入的
@property (strong,nonatomic) ClassLog *cClassTaskData;



- (void)displaySelectedMember:(NSArray*)arraySelectedMember;
- (void)displaySelectedLookBoard:(NSString*)sLookBoardID sLookBoardName:(NSString*)sLookBoardName;

@end
