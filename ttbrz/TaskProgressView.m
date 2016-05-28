//
//  TaskProgressView.m
//  ttbrz
//
//  Created by apple on 16/2/19.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "TaskProgressView.h"
#define KHorizontallyGap 20.0
#define KVerticallyGap   100.0
#define KCloseButtonSize 30.0

@interface TaskProgressView()<UITableViewDataSource,UITableViewDelegate> {
    
    UIView *_referView;//将要显示在该视图上
    UIView *_mainView;
    
    NSInteger _mainViewHeight,_mainViewWidth;
    NSArray *_progressItemArray;
}

@end

@implementation TaskProgressView

#pragma mark 初始化
- (id)initWithReferView:(UIView *)ReferView;
{
    self = [super init];
    if (self) {
        
        _referView=ReferView;
        self.frame=_referView.frame;
        
        _progressItemArray=[[NSArray alloc] initWithObjects:@"10%",@"20%",@"30%",@"40%",@"50%",@"60%",@"70%",@"80%",@"90%",@"100%", nil];
        
        NSInteger iLblTitleH=35;
        //计算每行cell的高度
        NSInteger viewWidth=CGRectGetWidth(self.frame);
        NSInteger viewHeight=CGRectGetHeight(self.frame);
        
        _mainViewHeight=viewHeight-KVerticallyGap*2;
        _mainViewWidth=viewWidth-KHorizontallyGap*2;
        
        NSInteger rowHeight=(viewHeight-iLblTitleH-KVerticallyGap*2)/_progressItemArray.count;
        
        _mainView=[[UIView alloc] initWithFrame:CGRectMake(KHorizontallyGap, -(_mainViewHeight), _mainViewWidth, _mainViewHeight)];
        _mainView.backgroundColor=[UIColor clearColor];
        [self addSubview:_mainView];
        
        //title
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainView.frame), iLblTitleH)];
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.textAlignment=NSTextAlignmentCenter;
        lblTitle.text=@"填报进度";
        lblTitle.font=[UIFont systemFontOfSize:15];
        lblTitle.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
        [_mainView addSubview:lblTitle];
        
        //backButton
        NSInteger iBtnBackW=35;
        UIButton *btnBack=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iBtnBackW, iBtnBackW)];
        [btnBack setBackgroundImage:[UIImage imageNamed:@"modelViewBack.png"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:btnBack];
        
        //主内容
        UITableView *tableView= [[UITableView alloc] initWithFrame:CGRectMake(0, iLblTitleH, CGRectGetWidth(_mainView.frame), CGRectGetHeight(_mainView.frame)-iLblTitleH) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.alwaysBounceHorizontal = NO;
        tableView.alwaysBounceVertical = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = [UIColor clearColor];
        [_mainView addSubview:tableView];
        tableView.rowHeight=rowHeight;
        
        //去掉左边的空白
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
    }
    return self;
    
}

#pragma mark 动画show
- (void)show{
    
    [_referView addSubview:self];
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        _mainView.frame=CGRectMake(KHorizontallyGap, KVerticallyGap,_mainViewWidth, _mainViewHeight);
        self.hasShow=YES;
        self.alpha =1;
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    }];
    
}

#pragma mark 动画hide
-(void)hide{
    [UIView animateWithDuration:0.35f animations:^{
        self.alpha = 0;
        _mainView.frame=CGRectMake(KHorizontallyGap, -(_mainViewHeight), _mainViewWidth, _mainViewHeight);
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
    return [_progressItemArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundView = [[UIView alloc] init];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [_progressItemArray objectAtIndex:indexPath.row];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [_delegate taskProgressView:self didProgressItem:[_progressItemArray objectAtIndex:indexPath.row]];
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

@end
