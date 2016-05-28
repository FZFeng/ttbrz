//
//  UIViewControllerTeamLog.h
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:团队日志

#import "UIViewControllerBase.h"
#import "ViewControllerDepartment.h"
#import "ClassLog.h"
#import "TbCellTeamLog.h"

@interface UIViewControllerTeamLog : UIViewControllerBase<FZDatePickerViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,TbCellTeamLogDelegate,NSURLSessionDownloadDelegate>

- (IBAction)didTitleDate:(id)sender;
- (IBAction)didSelectDepartment:(id)sender;

//获取选中部门编号
- (void)selectedDepartmentID:(NSString*)sDepartmentID sDepartmentName:(NSString*)sDepartmentName;

@end
