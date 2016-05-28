//
//  DownMenuView.h
//  ttbrz
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:下拉菜单

#import <UIKit/UIKit.h>
#import "UIViewControllerBase.h"

@protocol  DownMenuViewDelegate

@optional
- (void)downMenuView:(UIView*)downMenuView didMenuItemIndex:(NSInteger)itemIndex;

@end

@interface DownMenuView : UIView

@property (weak,nonatomic) id<DownMenuViewDelegate> delegate;
@property (assign,nonatomic) BOOL hasShow;

//初始化
- (id)initWithReferView:(UIView *)ReferView
              menuItems:(NSArray *)items
             hasNavItem:(BOOL)hasNavItem;

- (void)show;
- (void)tbViewReloadData;
- (void)hide;

@end
