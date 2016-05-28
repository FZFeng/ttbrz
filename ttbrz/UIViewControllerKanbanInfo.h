//
//  UIViewControllerKanbanInfo.h
//  ttbrz
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:看板信息

#import <UIKit/UIKit.h>
#import "ClassTask.h"
#import "TbCellTaskInfo.h"
#import "PopoverView.h"
#import "UIViewControllerEditCreateTaskInKanBan.h"

@interface UIViewControllerKanbanInfo : UIViewController

@property (strong,nonatomic) NSMutableArray *arrayInitData;
@property (strong,nonatomic) NSString *sGetTitle;
@property (strong,nonatomic) NSString *sGetLookBoardTypeID;

- (IBAction)didBtnAdd:(id)sender;


//操作(增,删,改)看板后更新UI和数据
- (void)initViewAndDataAfterOperateLookBoard;


@end
