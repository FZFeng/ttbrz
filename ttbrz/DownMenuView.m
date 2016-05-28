//
//  DownMenuView.m
//  ttbrz
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "DownMenuView.h"

#define KRowHeight 44.0

@interface DownMenuView()<UITableViewDataSource,UITableViewDelegate> {

    UIView *_referView;//将要显示在该视图上
    
    UITableView *_tableView;
    NSInteger _meunItemHeight,_menuItemY,_viewWidth,_viewHeight;
    NSArray *_menuItemArray;
}

@end

@implementation DownMenuView

#pragma mark 初始化
- (id)initWithReferView:(UIView *)ReferView
              menuItems:(NSArray *)items
             hasNavItem:(BOOL)hasNavItem;
{
    self = [super init];
    if (self) {
        
        _referView=ReferView;
        self.frame=_referView.frame;
        
        if (hasNavItem) {
            _menuItemY=64;
        }else{
            _menuItemY=20;
        }
        
        _menuItemArray=items;

        _meunItemHeight=items.count*KRowHeight;
        _viewWidth=CGRectGetWidth(self.frame);
        _viewHeight=CGRectGetHeight(self.frame);
        
        //点击空白关闭
        UIButton *bgButton=[[UIButton alloc] initWithFrame:self.frame];
        [bgButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgButton];
        
        //主内容
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -_meunItemHeight,_viewWidth, _meunItemHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.alwaysBounceHorizontal = NO;
        _tableView.alwaysBounceVertical = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight=KRowHeight;
        [self addSubview:_tableView];

        
        //去掉左边的空白
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }

    }
    return self;
    
}

#pragma mark 刷新tbView数据
- (void)tbViewReloadData{
    [_tableView reloadData];
}

#pragma mark 动画show
- (void)show{
    
    [_referView addSubview:self];
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        _tableView.frame=CGRectMake(0, _menuItemY,_viewWidth, _meunItemHeight);
        self.hasShow=YES;
        self.alpha =1;
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    }];
    
}

#pragma mark 动画hide
-(void)hide{
    [UIView animateWithDuration:0.35f animations:^{
        self.alpha = 0;
        _tableView.frame=CGRectMake(0,-_meunItemHeight, _viewWidth, _meunItemHeight);
        self.hasShow=NO;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_menuItemArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *sTitle=[_menuItemArray objectAtIndex:indexPath.row];
    NSInteger iLblTitleW=65;
    NSInteger iLeftGap=15;
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap, 0, iLblTitleW, KRowHeight)];
    lblTitle.text=sTitle;
    lblTitle.font=[UIFont systemFontOfSize:15];
    lblTitle.lineBreakMode =NSLineBreakByTruncatingMiddle;
    [cell.contentView addSubview:lblTitle];
    
    NSInteger iNum=[[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"ConfirmLogNum"] ] integerValue];
    
    if ([sTitle isEqualToString:KTitleLog_LogAssess] &&  iNum>0) {
        NSInteger ilblWaittingCheckNoticeSize=15;
        UILabel *lblWaittingCheckNotice=[[UILabel alloc]initWithFrame:CGRectMake(iLeftGap+iLblTitleW, 10,ilblWaittingCheckNoticeSize,ilblWaittingCheckNoticeSize)];
        lblWaittingCheckNotice.textAlignment=NSTextAlignmentCenter;
        lblWaittingCheckNotice.textColor=[UIColor whiteColor];
        lblWaittingCheckNotice.font=[UIFont systemFontOfSize:10];
        lblWaittingCheckNotice.text=[NSString stringWithFormat:@"%ld",(long)iNum];
        lblWaittingCheckNotice.backgroundColor=[UIColor redColor];
        lblWaittingCheckNotice.layer.masksToBounds=YES;
        lblWaittingCheckNotice.layer.cornerRadius =lblWaittingCheckNotice.frame.size.height/2;
        [cell.contentView addSubview:lblWaittingCheckNotice];
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [_delegate downMenuView:self didMenuItemIndex:indexPath.row];
    [self hide];
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KRowHeight;
}

@end
