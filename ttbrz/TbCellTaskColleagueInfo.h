//
//  TbCellTaskColleagueInfo.h
//  ttbrz
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:团队任务信息

#import <UIKit/UIKit.h>

@interface TbCellTaskColleagueInfo : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTaskDate;
@property (strong, nonatomic) IBOutlet UILabel *lblTaskName;
@property (strong, nonatomic) IBOutlet UILabel *lblTaskProgress;

@end
