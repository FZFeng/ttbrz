//
//  FZNoticeView.h
//  BaseModel
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:通知提示控件

#import <UIKit/UIKit.h>

@interface FZNoticeView : UIView{
    int iNoticeY;
    UIView *referView;
    UILabel *lblNotice;
}

//初始化 //bHasNavItem referView中是否有UINavigationItem控件
- (id)initWithReferView:(UIView*)ReferView bHasNavItem:(BOOL)bHasNavItem;
- (void)showWithNotice:(NSString*)Notice;

@end
