//
//  TbCellTeamLog.h
//  ttbrz
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassLog.h"

@protocol TbCellTeamLogDelegate

- (void)didTbCellButtonDelegate:(id)sender curLogData:(ClassLog*)curLogData;

@end

@interface TbCellTeamLog : UITableViewCell{

    IBOutlet UIImageView *_imageMemberIcon;
    IBOutlet UILabel *_lblMemberMark;
    IBOutlet UILabel *_lblTeamMemberName;
    IBOutlet UILabel *_lblTeamLogState;
}

@property (strong, nonatomic) IBOutlet UIView *viewTeamLogDetail;
@property (strong, nonatomic) ClassLog *cLogObject;
@property (weak, nonatomic) id<TbCellTeamLogDelegate>delegate;

//初始化数据
- (void)initData;

@end
