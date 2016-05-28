//
//  ViewControllerLogEvaluation.h
//  ttbrz
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:考评日志

#import <UIKit/UIKit.h>
#import "ClassLog.h"
#import "UIViewControllerLogAssess.h"

@interface ViewControllerLogEvaluation : UIViewController

@property (strong,nonatomic) NSArray *arrayCommentTemplate;
@property (strong,nonatomic) NSArray *arrayData;


//保存考评时的logID
//-1 单篇日志 logid
//0 全选时 logid 空
//1 先全选  部分取消 logid 不需要考评的日志(logid 间用逗号隔开)
//2 未全选  部分勾选 logid 需要考评的日志(logid 间用逗号隔开)
@property (strong,nonatomic) NSString *sGetLogID;
@property (assign,nonatomic) LogEvaluationType getLogEvaluationType;
@property (strong,nonatomic) NSString *sGetSelectDate;


@end
