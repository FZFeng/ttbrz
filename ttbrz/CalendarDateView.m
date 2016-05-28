//
//  CalendarDateView.m
//  ttbrz
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "CalendarDateView.h"

#define KViewWidth  45
#define KViewHeight 65

#define KMonthHeight 15
#define KDayHeight  30

@implementation CalendarDateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithCalendarMonth:(NSString *)month CalendarDay:(NSString *)day CalendarWeek:(NSString *)week{

    self = [super initWithFrame:CGRectMake(0, 0,KViewWidth,KViewHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIView *monthAndDayView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, KViewWidth, KMonthHeight+KDayHeight)];
        monthAndDayView.backgroundColor=[UIColor clearColor];
        //monthAndDayView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        //monthAndDayView.layer.borderWidth=1.0;
        monthAndDayView.layer.masksToBounds=YES;
        monthAndDayView.layer.cornerRadius =5.0;
        [self addSubview:monthAndDayView];
        
        //月份
        UIImageView *monthImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,KViewWidth,KMonthHeight) ];
        monthImageView.image=[UIImage imageNamed:@"CalendarDateMonthBg.png"];
        [monthAndDayView addSubview:monthImageView];

        
        UILabel *monthLable=[[UILabel alloc] initWithFrame:CGRectMake(0,0,KViewWidth,KMonthHeight)];
        monthLable.text=month;
        monthLable.font=[UIFont systemFontOfSize:12];
        monthLable.textColor=[UIColor whiteColor];
        monthLable.textAlignment=NSTextAlignmentCenter;
        [monthAndDayView addSubview:monthLable];
        
       
        //日期
        UIImageView *dayImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,KMonthHeight,KViewWidth,KDayHeight) ];
        dayImageView.image=[UIImage imageNamed:@"CalendarDateDayBg.png"];
        [monthAndDayView addSubview:dayImageView];
        
        UILabel *dayLable=[[UILabel alloc] initWithFrame:CGRectMake(0,KMonthHeight,KViewWidth,KDayHeight)];
        dayLable.text=day;
        
        dayLable.font=[UIFont systemFontOfSize:18];
        dayLable.textColor=[UIColor lightGrayColor];
        dayLable.textAlignment=NSTextAlignmentCenter;
        [monthAndDayView addSubview:dayLable];
        
        //星期
        UILabel *weekLable=[[UILabel alloc] initWithFrame:CGRectMake(0,KMonthHeight+KDayHeight,KViewWidth,KViewHeight-KMonthHeight-KDayHeight)];
        weekLable.text=week;
        weekLable.backgroundColor=[UIColor clearColor];
        weekLable.font=[UIFont systemFontOfSize:12];
        weekLable.textColor=[UIColor lightGrayColor];
        weekLable.textAlignment=NSTextAlignmentCenter;
        [self addSubview:weekLable];
        
    }
    return self;
}

@end
