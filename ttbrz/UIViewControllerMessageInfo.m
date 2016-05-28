//
//  UIViewControllerMessageInfo.m
//  ttbrz
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMessageInfo.h"

#define KTbCellRowHeight  50
#define KPerDataNum 5

@interface UIViewControllerMessageInfo ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{

    IBOutlet UITableView *_tbMessageInfoView;
    UILabel *_lblTitle;
    
    UILabel *_lblFileTbFooter;
    NSInteger _iCurFileDataIndex;//当前数据的页数
    BOOL _bHasMoreFileData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_fileTbFooterAcIndicator;//加载等待
}

@end

@implementation UIViewControllerMessageInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    _lblTitle.text=[NSString stringWithFormat:@"提醒消息(%lu)",(unsigned long)self.iGetMessageAllCount];
    _lblTitle.textAlignment=NSTextAlignmentCenter;
    _lblTitle.textColor=[UIColor whiteColor];
    _lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=_lblTitle;
    
    _bHasMoreFileData=YES;
    
    if (self.arrayMessageInfo.count>0) {
        _tbMessageInfoView.dataSource=self;
        _tbMessageInfoView.delegate=self;
        _tbMessageInfoView.rowHeight=KTbCellRowHeight;
        
        NSInteger taskTbFooterLabelW=100;
        NSInteger iViewTbFooterH=30;
        NSInteger iViewW=CGRectGetWidth(self.view.frame);
        UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iViewW, iViewTbFooterH)];
        
        _lblFileTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, iViewTbFooterH)];
        _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
        _lblFileTbFooter.textAlignment=NSTextAlignmentCenter;
        _lblFileTbFooter.font=[UIFont systemFontOfSize:13];
        _lblFileTbFooter.textColor=[UIColor lightGrayColor];
        [viewTbFooter addSubview:_lblFileTbFooter];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _fileTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_fileTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _fileTbFooterAcIndicator.hidden=YES;
        [viewTbFooter addSubview:_fileTbFooterAcIndicator];
        
        _tbMessageInfoView.tableFooterView=viewTbFooter;
    }else{
        _tbMessageInfoView.dataSource=nil;
        _tbMessageInfoView.delegate=nil;
    }

    if (self.arrayMessageInfo.count<5) {
        _iCurFileDataIndex=1;
    }else{
        _iCurFileDataIndex=2;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictData=[self.arrayMessageInfo objectAtIndex:indexPath.row];
    
    NSString *reuseIdentifier = @"myCell";
    UITableViewCell *myCell;
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSInteger iLeftGap=15;
    NSInteger iBtnH=30;
    NSInteger iBtnW=60;
    NSInteger iLblW=CGRectGetWidth(tableView.frame)-iLeftGap*2-iBtnW;
    
    //标题
    UILabel *lblMessage=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap, 0, iLblW, KTbCellRowHeight)];
    NSString *sContent=[PublicFunc filterHTML:[dictData objectForKey:@"MessageContent"]];
    lblMessage.text=sContent;
    lblMessage.numberOfLines=0;
    lblMessage.font=[UIFont systemFontOfSize:14];
    [myCell.contentView addSubview:lblMessage];
    
    //button
    UIButton *btnConfirm=[[UIButton alloc] initWithFrame:CGRectMake(iLblW+iLeftGap,(KTbCellRowHeight-iBtnH)/2, iBtnW, iBtnH)];
    btnConfirm.tag=indexPath.row;
    [btnConfirm setTitle:@"知道了" forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font=[UIFont systemFontOfSize:15];
    btnConfirm.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
    [btnConfirm addTarget:self action:@selector(didFileEdit:) forControlEvents:UIControlEventTouchUpInside];
    [myCell.contentView addSubview:btnConfirm];
    
    return myCell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayMessageInfo.count;
}

#pragma mark 知道了的处理
- (void)didFileEdit:(id)sender{
    UIButton *btnObj=sender;
    NSInteger iRowIndex=btnObj.tag;
     NSDictionary *dictData=[self.arrayMessageInfo objectAtIndex:iRowIndex];
    
    [ClassSearchAndMessage updateMessageStateWithMessageID:[dictData objectForKey:@"MessageID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [self.arrayMessageInfo removeObjectAtIndex:iRowIndex];
            if (self.arrayMessageInfo.count==0) {
                _tbMessageInfoView.dataSource=nil;
                _tbMessageInfoView.delegate=nil;
                self.iGetMessageAllCount=0;
            }else{
                self.iGetMessageAllCount=self.iGetMessageAllCount-1;
            }
            _lblTitle.text=[NSString stringWithFormat:@"提醒消息(%lu)",(unsigned long)self.iGetMessageAllCount];
            
            [_tbMessageInfoView reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.iGetMessageAllCount] forKey:@"messageNumAfterUpdate"];

        }
    }];
}

#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //要划到底部才加载数据
    CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
    CGFloat contentY=scrollView.contentOffset.y;
    CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
    
    if (distanceFromBottom<=scrolHeight) {
        
        if(!_bHasMoreFileData){
            return;
        }
        //加载数据
        _lblFileTbFooter.text=@"正在加载中...";
        _fileTbFooterAcIndicator.hidden=NO;
        [_fileTbFooterAcIndicator startAnimating];
        
        [ClassSearchAndMessage getMessageInfoWithID:[SystemPlist GetUserID] strType:@"1" page:_iCurFileDataIndex rows:KPerDataNum returnBlock:^(BOOL bReturn,NSArray *returnArray) {
            if (bReturn) {
                _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    ClassSearchAndMessage *cObjectData=[returnArray firstObject];
                    NSArray *arrayGetMessageInfo=cObjectData.arrayMessageInfo;
                    if (!arrayGetMessageInfo || arrayGetMessageInfo.count==0) {
                        _lblFileTbFooter.text=@"已全部加载完毕";
                        _bHasMoreFileData=NO;
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if (_iCurFileDataIndex==1 ) {
                            //先清除进入页面时初始化的数据
                            [self.arrayMessageInfo removeAllObjects];
                            self.arrayMessageInfo=[arrayGetMessageInfo mutableCopy];
                            if (returnArray.count==KPerDataNum) {
                                _iCurFileDataIndex=2;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                        }else{
                            if (arrayGetMessageInfo.count==KPerDataNum) {
                                _iCurFileDataIndex++;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                            //插入数据
                            for (NSDictionary *dictData in arrayGetMessageInfo) {
                                [self.arrayMessageInfo addObject:dictData];
                            }
                            [_tbMessageInfoView reloadData];
                        }
                    }
                }
                _fileTbFooterAcIndicator.hidden=YES;
                [_fileTbFooterAcIndicator stopAnimating];
            }
        }];
    }
}

@end
