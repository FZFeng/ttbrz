//
//  TaskProgressView.h
//  ttbrz
//
//  Created by apple on 16/2/19.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:填报任务进度view

#import <UIKit/UIKit.h>

@protocol  TaskProgressViewDelegate

@optional
- (void)taskProgressView:(UIView*)taskProgressView didProgressItem:(NSString*)progressItem;

@end

@interface TaskProgressView : UIView

@property (assign,nonatomic) BOOL hasShow;
@property (weak,nonatomic) id<TaskProgressViewDelegate> delegate;
//初始化
- (id)initWithReferView:(UIView *)ReferView;
- (void)show;

@end
