//
//  UIViewControllerTeamIntegral.h
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerBase.h"
#import "TbCellTeamIntegral.h"
#import "FZDatePickerView.h"
#import "ClassIntegral.h"
#import "ViewControllerDepartment.h"

@interface UIViewControllerTeamIntegral : UIViewControllerBase

- (IBAction)didTitleDate:(id)sender;
- (IBAction)didSelectDepartment:(id)sender;
//获取选中部门编号
- (void)selectedDepartmentID:(NSString*)sDepartmentID sDepartmentName:(NSString*)sDepartmentName;

@end
