//
//  UIViewControllerMyLog1.h
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:我的日志

#import "UIViewControllerBase.h"
#import "TbCellLogReceiveTask.h"
#import "UIViewControllerAddNewLog.h"
#import "UIViewControllerPlanTask.h"
#import "UIViewControllerUploadFile.h"
#import "TbCellLog.h"

#import "ClassLog.h"
#import "ClassSearchAndMessage.h"
#import "FZRefreshTableView.h"

@interface UIViewControllerMyLog : UIViewControllerBase<TaskProgressViewDelegate,
FZDatePickerViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
TbCellLogDelegate,
FZRefreshTableViewDelegate,
UIAlertViewDelegate,
NSURLSessionDownloadDelegate>

- (IBAction)didTitleDate:(id)sender;
- (IBAction)didTitleToday:(id)sender;

- (void)initTodayLogData;

@end
