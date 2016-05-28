//
//  TbCellAssessLog.h
//  ttbrz
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日志考评

#import <UIKit/UIKit.h>
#import "ClassLog.h"

@protocol TbCellAssessLogDelegate
- (void)didTbCellAssessLogButtonDelegate:(id)sender curLogData:(ClassLog*)curLogData;
@end

@interface TbCellAssessLog : UITableViewCell{

    IBOutlet UILabel *_lblMemberName;
    IBOutlet UILabel *_lblLogDate;
    IBOutlet UILabel *_lblMemberMark;
    IBOutlet UIImageView *_imageMemberIcon;
    
}
@property (strong, nonatomic) IBOutlet UIButton *btnAssess;
@property (strong, nonatomic) IBOutlet UIView *viewTeamLogDetail;
@property (strong, nonatomic) IBOutlet UIButton *btnSelected;
@property (assign, nonatomic) BOOL bSelected;
@property (strong, nonatomic) ClassLog *cLogObject;
@property (weak, nonatomic) id<TbCellAssessLogDelegate>delegate;

//初始化数据
- (void)initData;

@end
