//
//  UIViewControllerLogAssess.h
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日志考评

#import "UIViewControllerBase.h"
#import "ViewControllerLogEvaluation.h"
#import "ClassLog.h"
#import "TbCellAssessLog.h"
#import "PopoverView.h"
#import "FZDatePickerView.h"

@interface UIViewControllerLogAssess : UIViewControllerBase

- (IBAction)didBtnAllAssess:(id)sender;
- (IBAction)didBtnSelected:(id)sender;
- (IBAction)didBtnLogDate:(id)sender;


- (void)loadingData;
//更新需要审核的消息数量
- (void)updateConfirmNum;
@end
