//
//  UIViewControllerMyIntegral.h
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:我的积分

#import "UIViewControllerBase.h"
#import "ClassIntegral.h"
#import "TbCellIntegral.h"

@interface UIViewControllerMyIntegral : UIViewControllerBase<FZDatePickerViewDelegate>

- (IBAction)didTitleDate:(id)sender;

@end
