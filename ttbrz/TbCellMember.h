//
//  TbCellMember.h
//  ttbrz
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:其它同事tbcell

#import <UIKit/UIKit.h>

@interface TbCellMember : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblTeamMemberName;

@property (strong, nonatomic) IBOutlet UIImageView *imageMemberIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblMemberMark;


@end
