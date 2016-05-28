//
//  TbCellLog.h
//  ttbrz
//
//  Created by apple on 16/3/7.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日志cell

#import <UIKit/UIKit.h>
#import "ClassLog.h"
#import "PopoverView.h"

//返回状态
typedef NS_ENUM(NSInteger, TbCellLogDelegateType){
    TbCellLogDelegateTypeLogAddNew,   //新日志
    TbCellLogDelegateTypeLogEdit,    //工作日志编辑返回
    TbCellLogDelegateTypeUpFileEdit, //上传文件返回
    TbCellLogDelegateTypeSubmitLog,  //提交日志
    TbCellLogDelegateTypeFileEdit    //文件操作返回
};


@protocol TbCellLogDelegate 

- (void)didTbCellButtonDelegate:(id)sender curLogData:(ClassLog*)curLogData returnType:(TbCellLogDelegateType)returnType;

@end

@interface TbCellLog : UITableViewCell{
    IBOutlet UILabel *_lblLogState;
    IBOutlet UIImageView *_imageBtnEdit;
    
    CGPoint curLocation;
}

//明细内容view  动态加载
@property (strong, nonatomic) IBOutlet UIView *logTbCellDetailView;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong, nonatomic) IBOutlet UILabel *weekLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) id<TbCellLogDelegate>delegate;
@property (strong, nonatomic) ClassLog *cLogObject;
@property (assign,nonatomic) BOOL bColleagueLog; //标记是否为同事日志
- (IBAction)didBtnEdit:(id)sender;

//初始化数据
- (void)initData;

@end
