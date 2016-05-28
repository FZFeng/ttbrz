//
//  FZNoticeView.m
//  BaseModel
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "FZNoticeView.h"
#define  iViewH 35


@implementation FZNoticeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithReferView:(UIView*)ReferView bHasNavItem:(BOOL)bHasNavItem
{
    self = [super init];
    if (self) {
        
        referView=ReferView;
        self.frame=referView.frame;
        
        if (bHasNavItem) {
            iNoticeY=64;
        }else{
            iNoticeY=20;
        }
        
        lblNotice=[[UILabel alloc] initWithFrame:CGRectMake(0,-iViewH, CGRectGetWidth(referView.bounds), iViewH)];
        lblNotice.textAlignment=NSTextAlignmentCenter;
        lblNotice.backgroundColor=[UIColor redColor];
        lblNotice.alpha=0.4;
        lblNotice.textColor=[UIColor whiteColor];
        lblNotice.font=[UIFont systemFontOfSize:15];
        [self addSubview:lblNotice];
    }
    return self;
    
}

//动画show
- (void)showWithNotice:(NSString*)Notice{
    
    //UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    //完成按钮添加到window
    //[tempWindow addSubview:self];
    
    [referView addSubview:self];
    lblNotice.text=Notice;
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        lblNotice.frame=CGRectMake(0,iNoticeY, CGRectGetWidth(referView.bounds), iViewH);
        self.alpha =1;
        
    } completion:^(BOOL finished) {
        sleep(2);
        [UIView animateWithDuration:0.75f animations:^{
            self.alpha = 0;
            lblNotice.frame=CGRectMake(0,-iViewH, CGRectGetWidth(referView.bounds), iViewH);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
    
}

@end
