//
//  FZDatePickerView.m
//  BaseModel
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "FZDatePickerView.h"

#define  iMainContentViewH 180
#define  iControlViewH 35
#define  iControlW 50


@implementation FZDatePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithReferView:(UIView *)ReferView
{
    self = [super init];
    if (self) {
        
        referView=ReferView;
        self.frame=referView.frame;
        
        int iDatePickerViewH,iViewW,iViewH;
        iDatePickerViewH=iMainContentViewH-iControlViewH;
        iViewW=CGRectGetWidth(referView.bounds);
        iViewH=CGRectGetHeight(referView.bounds);
        
        //点击空白关闭
        UIButton *btnBg=[[UIButton alloc] initWithFrame:self.frame];
        [btnBg addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnBg];
        
        //主内容
        mainContentView=[[UIView alloc] initWithFrame:CGRectMake(0,iViewH,iViewW, iMainContentViewH)];
        [self addSubview:mainContentView];
        
        //按钮(取消,确定)
        UIView *controlView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iViewW, iControlViewH)];
        controlView.backgroundColor=[UIColor lightGrayColor];
        [mainContentView addSubview:controlView];
        
        UIButton *btnCancel=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iControlW, iControlViewH)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        btnCancel.titleLabel.font=[UIFont systemFontOfSize:15];
        [btnCancel addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        btnCancel.backgroundColor=[UIColor clearColor];
        [controlView addSubview:btnCancel];
        
        UIButton *btnOK=[[UIButton alloc] initWithFrame:CGRectMake(iViewW-iControlW, 0, iControlW, iControlViewH)];
        btnOK.titleLabel.font=[UIFont systemFontOfSize:15];
        [btnOK setTitle:@"确定" forState:UIControlStateNormal];
        [btnOK addTarget:self action:@selector(selectDate) forControlEvents:UIControlEventTouchUpInside];
        btnOK.backgroundColor=[UIColor clearColor];
        [controlView addSubview:btnOK];
        
        //即时显示选中的日期
        selectDateLable=[[UILabel alloc] initWithFrame:CGRectMake(iControlW, 0,iViewW-iControlW*2, iControlViewH)];
        selectDateLable.font=[UIFont systemFontOfSize:15];
        selectDateLable.textColor=[UIColor whiteColor];
        selectDateLable.textAlignment=NSTextAlignmentCenter;
        
        NSDate *nowDate = [NSDate date];
        NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
        [pickerFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *weekString =[PublicFunc returnWeekDateWithDate:[pickerFormatter stringFromDate:nowDate]];
        [pickerFormatter setDateFormat:@"yyyy年M月d日"];
        NSString *dateString = [pickerFormatter stringFromDate:nowDate];
        selectDateLable.text=[NSString stringWithFormat:@"%@ %@",dateString,weekString];
        
        [controlView addSubview:selectDateLable];
        
        //添加datePicker
        datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, iControlViewH, iViewW, iDatePickerViewH)];
        datePicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [mainContentView addSubview:datePicker];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged ];//重点：UIControlEventValueChanged
        
        //设置显示格式
        //默认根据手机本地设置显示为中文还是其他语言
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
        datePicker.locale = locale;
        
        
        //设置最大时间
        datePicker.maximumDate=[NSDate date];

        
        //当前时间创建NSDate
        /*
        NSDate *localDate = [NSDate date];
        //在当前时间加上的时间
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        //设置时间
        [offsetComponents setYear:0];
        [offsetComponents setMonth:0];
        [offsetComponents setDay:5];
        [offsetComponents setHour:20];
        [offsetComponents setMinute:0];
        [offsetComponents setSecond:0];
        //设置最大值时间
        NSDate *maxDate = [gregorian dateByAddingComponents:offsetComponents toDate:localDate options:0];
        //设置属性
        datePicker.minimumDate = localDate;
        datePicker.maximumDate = maxDate;
         */
        
    }
    return self;
    
}

//转动选择日期
- (void)dateChanged{

    //NSDate格式转换为NSString格式
    NSDate *pickerDate = [datePicker date];// 获取用户通过UIDatePicker设置的日期和时间
    NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    
    [pickerFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *weekString =[PublicFunc returnWeekDateWithDate:[pickerFormatter stringFromDate:pickerDate]];
    
    [pickerFormatter setDateFormat:@"yyyy年M月d日"];
    NSString *dateString = [pickerFormatter stringFromDate:pickerDate];
    
    selectDateLable.text=[NSString stringWithFormat:@"%@ %@",dateString,weekString];
}

//选择日期
- (void)selectDate{
    
    //NSDate格式转换为NSString格式
    NSDate *pickerDate = [datePicker date];// 获取用户通过UIDatePicker设置的日期和时间
    NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [pickerFormatter setDateFormat:@"yyyy年M月"];
    NSString *dateString = [pickerFormatter stringFromDate:pickerDate];
    
    [pickerFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *displayString = [pickerFormatter stringFromDate:pickerDate];
   
    [_delegate FZDatePickerViewDelegateReturnDate:dateString displayDate:displayString];
    
    [self hide];
}

//动画show
- (void)show{
    
    if (self.bFinishTaskDate) {
        datePicker.maximumDate=nil;
        datePicker.minimumDate=[NSDate date];
    }
    
    if (self.bOnlyDisplayYearAndMonth) {
        //只显示年,月 同时不显示即时时间
        selectDateLable.hidden=YES;
        datePicker.subviews[0].subviews[0].subviews[2].hidden = YES;
        UIView *monthView=datePicker.subviews[0].subviews[0].subviews[1];
        
        //向右移动70
        monthView.frame=CGRectMake(monthView.frame.origin.x+70, monthView.frame.origin.y, monthView.frame.size.width, monthView.frame.size.height);
    }
    
    [referView addSubview:self];
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        mainContentView.frame=CGRectMake(0, CGRectGetHeight(referView.bounds)-iMainContentViewH, CGRectGetWidth(referView.bounds), iMainContentViewH);
        self.alpha =1;
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    }];
}

//动画hide
-(void)hide{
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
         mainContentView.frame=CGRectMake(0, CGRectGetHeight(referView.bounds), CGRectGetWidth(referView.bounds), iMainContentViewH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
