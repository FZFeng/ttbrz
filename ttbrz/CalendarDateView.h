//
//  CalendarDateView.h
//  ttbrz
//
//  Created by apple on 16/2/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日历控件 用于显示 日期

#import <UIKit/UIKit.h>

@interface CalendarDateView : UIView

//实例化
- (id) initWithCalendarMonth:(NSString*)month
                 CalendarDay:(NSString*)day
                CalendarWeek:(NSString*)week;

@end
