//
//  UIViewControllerColleagueDetailLog.h
//  ttbrz
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:个人详细日志

#import <UIKit/UIKit.h>
#import "FZDatePickerView.h"
#import "ClassLog.h"
#import "ViewControllerMember.h"
#import "TbCellLog.h"
#import "FZRefreshTableView.h"

@interface UIViewControllerColleagueDetailLog : UIViewController<FZDatePickerViewDelegate,UIScrollViewDelegate,UITableViewDataSource,
UITableViewDelegate,FZRefreshTableViewDelegate,TbCellLogDelegate,NSURLSessionDownloadDelegate>


@property (strong,nonatomic) NSArray *arrayMemberData;
@property (strong,nonatomic) NSMutableArray *arrayGetLogData;
@property (strong,nonatomic) NSString *sGetSelectedMemberName;
@property (strong,nonatomic) NSString *sGetSelectedMemberID;


- (IBAction)didTitleDate:(id)sender;
- (IBAction)didBtnSelectOtherMember:(id)sender;

//获取选中同事的编号
- (void)selectedMemberID:(NSString*)sMemberID sMemberName:(NSString*)sMemberName;

@end
