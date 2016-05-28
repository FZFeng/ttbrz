//
//  FZDatePickerView.h
//  BaseModel
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:选择日期view

#import <UIKit/UIKit.h>
#import "PublicFunc.h"

@protocol FZDatePickerViewDelegate

-(void)FZDatePickerViewDelegateReturnDate:(NSString*)psReturnDate displayDate:(NSString*)displayDate;

@end

@interface FZDatePickerView : UIView{

    UIDatePicker *datePicker;
    UIView *referView;//将要显示在该视图上
    UIView *mainContentView;
    UILabel *selectDateLable;
}
@property(nonatomic,strong) id<FZDatePickerViewDelegate> delegate;
@property(assign)BOOL bNoDayFormatDate;
@property(assign)BOOL bFinishTaskDate; //标记是否在发任务时选择日期
@property(assign)BOOL bOnlyDisplayYearAndMonth; //标记是否只显示年,月数据

//初始化
- (id)initWithReferView:(UIView *)ReferView;
- (void)show;

@end
