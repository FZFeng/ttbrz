//
//  TbCellLogReceiveTask.h
//  ttbrz
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日志模块中 接到任务的cell

#import <UIKit/UIKit.h>

@interface TbCellLogReceiveTask : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tbCellTaskTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *tbCellTaskFinsihDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *tbCellTaskPersentLabel;

@end
