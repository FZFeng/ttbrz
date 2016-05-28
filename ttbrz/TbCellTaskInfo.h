//
//  TbCellTaskInfo.h
//  ttbrz
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:任务信息

#import <UIKit/UIKit.h>

@interface TbCellTaskInfo : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblTaskName;
@property (strong, nonatomic) IBOutlet UILabel *lblTaskTimeEnd;
@property (strong, nonatomic) IBOutlet UILabel *lblTaskProgress;
@property (strong, nonatomic) IBOutlet UIView *viewUsers;
@property (strong, nonatomic) IBOutlet UIView *viewDetail;

@end
