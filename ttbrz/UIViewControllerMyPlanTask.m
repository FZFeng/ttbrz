//
//  UIViewControllerMyPlanTask.m
//  ttbrz
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMyPlanTask.h"

#define KKanBanButtonBeginTag 100
#define KKanBanLabelBeginTag  200
#define KKanBanTaskTBBeginTag  300
#define KKanBanTaskTBFooterBeginTag 400
#define KKanBanTaskTBFooterAcIndicatorBeginTag 500

#define KScrolKanBanTag    11
#define KScrolTaskTag      12
#define KAlertDeleteTask   13
#define KAlertDeleteBookBoard   14

#define KPerDataNum        5
#define KNoExecuteUserRowHeight  40



@interface UIViewControllerMyPlanTask ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>{

    NSInteger _iScrolKanBanH,_iScrolTaskH,_iViewBtnH,_iViewBtnW,_iViewW,_iViewH,_iTop;
    NSMutableArray *_arrayHasMoreData;
    NSMutableArray *_arrayCurIndexKanBan;
    
    UIScrollView *_scrolKanBan;
    UIScrollView *_scrolTask;
    
    NSInteger _iCurIndexKanBan;;
    
    UILabel *_lblKanBanLine;
    NSInteger iRowHeight;
    
    NSArray *_arrayFinishTypeItem;
    NSArray *_arrayKey;
    NSMutableDictionary *_dictInitData;

}

@end

@implementation UIViewControllerMyPlanTask

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_MyTask];
    
    _arrayFinishTypeItem=[[NSArray alloc] initWithObjects:@"进行中",@"待安排",@"已完成", nil];
    _arrayKey=[[NSArray alloc] initWithObjects:@"TaskIng",@"TaskNo",@"TaskOk", nil];
    
    _dictInitData=[[NSMutableDictionary alloc] init];
    _arrayHasMoreData=[[NSMutableArray alloc] init];
    _arrayCurIndexKanBan=[[NSMutableArray alloc] init];
    
    _iCurIndexKanBan=0;//默认第一个看板
    
    
    _iTop=64;
    _iScrolKanBanH=45;
    _iViewBtnH=45;
    _iViewW=CGRectGetWidth(self.view.frame);
    _iViewH=CGRectGetHeight(self.view.frame);
    _iScrolTaskH=_iViewH-_iViewBtnH-_iScrolKanBanH-_iTop;
    
    _scrolKanBan=[[UIScrollView alloc] initWithFrame:CGRectMake(0, _iTop, _iViewW, _iScrolKanBanH)];
    _scrolKanBan.bounces=NO;
    _scrolKanBan.tag=KScrolKanBanTag;
    _scrolKanBan.delegate=self;
    _scrolKanBan.scrollEnabled=YES;
    _scrolKanBan.showsHorizontalScrollIndicator=NO;
    _scrolKanBan.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_scrolKanBan];
    
    //line
    NSInteger iLineH=2;
    _lblKanBanLine=[[UILabel alloc] initWithFrame:CGRectMake(0,_iTop+_iScrolKanBanH-iLineH,_iViewW, iLineH)];
    _lblKanBanLine.backgroundColor=[UIColor lightGrayColor];
    _lblKanBanLine.alpha=0.5;
    _lblKanBanLine.hidden=YES;
    [self.view addSubview:_lblKanBanLine];
    
    _scrolTask=[[UIScrollView alloc] initWithFrame:CGRectMake(0, _iTop+_iScrolKanBanH, _iViewW, _iScrolTaskH)];
    _scrolTask.bounces=NO;
    _scrolTask.tag=KScrolTaskTag;
    _scrolTask.delegate=self;
    _scrolTask.scrollEnabled=YES;
    _scrolTask.pagingEnabled=YES;
    _scrolTask.showsHorizontalScrollIndicator=NO;
    _scrolTask.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_scrolTask];
    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 初始化数据
- (void)loadingData{
    [ClassTask getSelfPlanTaskAllCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] fatherObject:self returnBlock:^(BOOL bReturn,NSDictionary *returnDictionary) {
        if (bReturn) {
            [_dictInitData removeAllObjects];
            
            for (UIView *subView in _scrolKanBan.subviews) {
                [subView removeFromSuperview];
            }
            for (UIView *subView in _scrolTask.subviews) {
                [subView removeFromSuperview];
            }
            
            _dictInitData=[returnDictionary mutableCopy];
            [self initView];
        }
        _lblKanBanLine.hidden=NO;
    }];

}

#pragma mark 初始化页百内容
- (void)initView{
    
    NSInteger iLblLineH=2;
    NSInteger iCurScrolKanBanOriginX=0;
    _iViewBtnW=_iViewW/3;
    
    [_arrayHasMoreData removeAllObjects];
    [_arrayCurIndexKanBan removeAllObjects];
    
    //生成scrolKanBan内容
    if (_dictInitData) {
        
        _lblKanBanLine.hidden=NO;
        
        for (int i=0; i<=_arrayFinishTypeItem.count-1; i++) {
            
            [_arrayHasMoreData addObject:[NSNumber numberWithBool:YES]];
            NSArray *arrayTaskInfo=[_dictInitData objectForKey:[_arrayKey objectAtIndex:i]];
           
            //每个作任务集不超过KPerDataNum规定的数据的 默认第一行 等于KPerDataNum 的 默认第二行
            if (arrayTaskInfo ) {
                if (arrayTaskInfo.count>=KPerDataNum) {
                    [_arrayCurIndexKanBan addObject:[NSNumber numberWithInteger:2]];
                }else{
                    [_arrayCurIndexKanBan addObject:[NSNumber numberWithInteger:1]];
                }
            }else{
                [_arrayCurIndexKanBan addObject:[NSNumber numberWithInteger:1]];
            
            }

            //view
            UIView *viewKanBan=[[UIView alloc] initWithFrame:CGRectMake(iCurScrolKanBanOriginX, 0, _iViewBtnW, _iScrolKanBanH)];
            [_scrolKanBan addSubview:viewKanBan];
            
            //button
            UIButton *btnKanBan=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,_iViewBtnW,_iScrolKanBanH-iLblLineH)];
            btnKanBan.titleLabel.font=[UIFont systemFontOfSize:15];
            btnKanBan.backgroundColor=[UIColor clearColor];
            btnKanBan.tag=KKanBanButtonBeginTag+i;
            [btnKanBan setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btnKanBan setTitle:[_arrayFinishTypeItem objectAtIndex:i] forState:UIControlStateNormal];
            [btnKanBan addTarget:self action:@selector(didBtnSelectKanBan:) forControlEvents:UIControlEventTouchUpInside];
            [viewKanBan addSubview:btnKanBan];
            
            //selectedlineLable
            UILabel *lblSelectedLine=[[UILabel alloc] initWithFrame:CGRectMake(0,_iScrolKanBanH-iLblLineH,_iViewBtnW, iLblLineH)];
            lblSelectedLine.textAlignment=NSTextAlignmentCenter;
            lblSelectedLine.tag=KKanBanLabelBeginTag+i;
            if (i==_iCurIndexKanBan) {
                lblSelectedLine.backgroundColor=[UIColor darkGrayColor];
            }else{
                lblSelectedLine.backgroundColor=[UIColor clearColor];
            }
            [viewKanBan addSubview:lblSelectedLine];
            iCurScrolKanBanOriginX=iCurScrolKanBanOriginX+_iViewBtnW;
            
            //---------scrolTask-------------//
            //UITableview
            UITableView *tbTaskView=[[UITableView alloc] initWithFrame:CGRectMake(_iViewW*i, 0, _iViewW, _iScrolTaskH)];
            
            //去掉左边的空白
            if ([tbTaskView respondsToSelector:@selector(setLayoutMargins:)]) {
                [tbTaskView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            if ([tbTaskView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tbTaskView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            
            
            tbTaskView.tag=KKanBanTaskTBBeginTag+i;
            [_scrolTask addSubview:tbTaskView];
            
            //TB footer
            if (arrayTaskInfo.count>0) {
                tbTaskView.dataSource=self;
                tbTaskView.delegate=self;
                
                //注册cell
                UINib *nibCell=[UINib nibWithNibName:@"TbCellTaskInfo" bundle:nil];
                [tbTaskView registerNib:nibCell forCellReuseIdentifier:@"TbCellTaskInfo"];
                
                TbCellTaskInfo*cell=[tbTaskView dequeueReusableCellWithIdentifier:@"TbCellTaskInfo"];
                iRowHeight=CGRectGetHeight(cell.frame);
                
                NSInteger taskTbFooterLabelW=100;
                NSInteger iViewTbFooterH=40;
                UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _iViewW, iViewTbFooterH)];
                
                UILabel *lblTaskTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((_iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, iViewTbFooterH)];
                lblTaskTbFooter.tag=KKanBanTaskTBFooterBeginTag+i;
                lblTaskTbFooter.text=@"滑动加载更多 \u25BE";
                lblTaskTbFooter.textAlignment=NSTextAlignmentCenter;
                lblTaskTbFooter.font=[UIFont systemFontOfSize:13];
                lblTaskTbFooter.textColor=[UIColor lightGrayColor];
                [viewTbFooter addSubview:lblTaskTbFooter];
                
                NSInteger taskTbFooterAcIndicatorSize=30;
                UIActivityIndicatorView *taskTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((_iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, (iViewTbFooterH-taskTbFooterAcIndicatorSize)/2,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
                [taskTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                taskTbFooterAcIndicator.hidden=YES;
                taskTbFooterAcIndicator.tag=KKanBanTaskTBFooterAcIndicatorBeginTag+i;
                [viewTbFooter addSubview:taskTbFooterAcIndicator];
                
                tbTaskView.scrollEnabled=YES;
                tbTaskView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
                tbTaskView.tableFooterView=viewTbFooter;
            }else{
                tbTaskView.dataSource=nil;
                tbTaskView.delegate=nil;
                tbTaskView.tableFooterView=nil;
                tbTaskView.separatorStyle=UITableViewCellSeparatorStyleNone;
                tbTaskView.scrollEnabled=NO;
            }
            
        }
        _scrolTask.contentSize=CGSizeMake(_iViewW*3, _iScrolTaskH);
        if (iCurScrolKanBanOriginX>_iViewW) {
            _scrolKanBan.contentSize=CGSizeMake(iCurScrolKanBanOriginX, 0);
        }
    }else{
        _lblKanBanLine.hidden=YES;
        _iCurIndexKanBan=-1;
    }
}

#pragma mark 增加任务
- (void)addNewTask{
    
    UIViewControllerEditCreateTaskInKanBan *createTaskInKanBanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerEditCreateTaskInKanBan"];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    createTaskInKanBanView.sGetLookBoard=@"";
    createTaskInKanBanView.sGetLookBoardID=@"00000000-0000-0000-0000-000000000000";
    createTaskInKanBanView.bFormMyPlanTaskView=YES;
    [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:createTaskInKanBanView animated:YES];
}


#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TbCellTaskInfo*myCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskInfo"];
    [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSArray *arrayTaskInfo=[_dictInitData objectForKey:[_arrayKey objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag]];
    ClassTask *cClassObjectData=[arrayTaskInfo objectAtIndex:indexPath.row];
    
    //任务名称
    myCell.lblTaskName.text=cClassObjectData.sTaskName;
    
    //完成进度
    myCell.lblTaskProgress.text=[NSString stringWithFormat:@"%@%%",cClassObjectData.sProgress];
    //完成日期
    myCell.lblTaskName.textColor=defaultColor;
    NSString *sTaskEndDate=cClassObjectData.sDtEnd;
    if (![sTaskEndDate isEqualToString:@"尽快"]) {
        //判断任务是否已过期(超过一天)
        NSTimeInterval timeBetween;
        NSArray *arrayEndDate=[[[sTaskEndDate componentsSeparatedByString:@"T"] firstObject] componentsSeparatedByString:@"-"];
        sTaskEndDate=[NSString stringWithFormat:@"%@-%@-%@",[arrayEndDate objectAtIndex:0],[arrayEndDate objectAtIndex:1] ,[arrayEndDate objectAtIndex:2]];
        NSDate *dTaskEndDate=[PublicFunc dateFromString:sTaskEndDate dateFormatterType:DateFromStringTypeYMD];
        timeBetween=[dTaskEndDate timeIntervalSinceNow];
        
        sTaskEndDate=[NSString stringWithFormat:@"%@-%@",[arrayEndDate objectAtIndex:1] ,[arrayEndDate objectAtIndex:2]];
        timeBetween=-timeBetween;
        if (timeBetween>60*60*24) {
            myCell.lblTaskName.textColor=[UIColor redColor];
        }
    }
    myCell.lblTaskTimeEnd.text=sTaskEndDate;
    
    //完成人员
    NSString *sExecuteUserName=cClassObjectData.sExecuteUserName;
    
    if ([sExecuteUserName isEqualToString:@""]) {
        //没有执行人
        myCell.viewDetail.hidden=YES;
    }else{
        myCell.viewDetail.hidden=NO;
        
        //去掉,
        sExecuteUserName=[sExecuteUserName substringToIndex:sExecuteUserName.length-1];
        NSInteger iDataNum;
        NSArray *arrayUser=[sExecuteUserName componentsSeparatedByString:@","];
        iDataNum=arrayUser.count;
        
        NSInteger iViewUsers=CGRectGetWidth(myCell.viewUsers.frame);
        NSInteger iGap=5;
        NSInteger iLabelSize=25;
        NSInteger iCurOriginX=0;
        
        //清除原来旧的view
        for (UIView *subView in [myCell.viewUsers subviews]) {
            [subView removeFromSuperview];
        }
        
        NSInteger iScrolMemberH=CGRectGetHeight(myCell.viewUsers.frame);
        UIScrollView *scrolMember=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,iViewUsers,iScrolMemberH)];
        scrolMember.bounces=NO;
        scrolMember.scrollEnabled=YES;
        scrolMember.showsHorizontalScrollIndicator=NO;
        scrolMember.showsVerticalScrollIndicator=NO;
       
        [myCell.viewUsers addSubview:scrolMember];
        
        for (NSString *sUserName in arrayUser) {
            UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX, (iScrolMemberH-iLabelSize)/2,iLabelSize, iLabelSize)];
            lblName.text=[sUserName substringFromIndex:sUserName.length-1];
            lblName.textAlignment=NSTextAlignmentCenter;
            lblName.textColor=[UIColor whiteColor];
            lblName.font=[UIFont systemFontOfSize:18];
            lblName.backgroundColor=randomColor;
            [scrolMember addSubview:lblName];
            iCurOriginX=iCurOriginX+iLabelSize+iGap;
        }
        
        if (iCurOriginX>iViewUsers) {
             scrolMember.contentSize=CGSizeMake(iCurOriginX, 0);
        }
    }
    return myCell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrayTaskInfo=[_dictInitData objectForKey:[_arrayKey objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag]];
    
    return arrayTaskInfo.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //编缉任务 先获取编辑任务的信息
    NSArray *arrayTaskInfo=[_dictInitData objectForKey:[_arrayKey objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag]];
    ClassTask *cClassObjectData=[arrayTaskInfo objectAtIndex:indexPath.row];
    
    [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:cClassObjectData.sTaskID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        
        if (bReturn) {
            UIViewControllerEditCreateTaskInKanBan *editTaskInKanBanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerEditCreateTaskInKanBan"];
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            
            ClassLog *sGetClassData=[returnArray firstObject];
            editTaskInKanBanView.sGetLookBoard=sGetClassData.sLookBoardName;
            editTaskInKanBanView.bEditTask=YES;
            editTaskInKanBanView.bFormMyPlanTaskView=YES;
            editTaskInKanBanView.sGetTaskID=cClassObjectData.sTaskID;
            editTaskInKanBanView.sGetLookBoardID=sGetClassData.sLookBoardID;
            editTaskInKanBanView.cClassTaskData=sGetClassData;
            
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:editTaskInKanBanView animated:YES];
        }
    }];
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayTaskInfo=[_dictInitData objectForKey:[_arrayKey objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag]];
    
    ClassTask *cClassObjectData=[arrayTaskInfo objectAtIndex:indexPath.row];
    
    NSString *sExecuteUserName=cClassObjectData.sExecuteUserName;
    
    static  TbCellTaskInfo *myCell = nil;
    if (!myCell)
        myCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskInfo"];
    
    
    if ([sExecuteUserName isEqualToString:@""]) {
        //没有执行人
        myCell.viewDetail.hidden=YES;
        myCell.backgroundColor=[UIColor blackColor];
        
        return KNoExecuteUserRowHeight;
    }else{
        return iRowHeight;
    }
}

#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //是tableview中的scrol上下滚动
    if ([scrollView isMemberOfClass:[UITableView class]]) {
        //要划到底部才加载数据
        CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
        CGFloat contentY=scrollView.contentOffset.y;
        CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
        
        if (distanceFromBottom<=scrolHeight) {
            
            BOOL bHasMoreData=[[_arrayHasMoreData objectAtIndex:_iCurIndexKanBan] boolValue];
            if (!bHasMoreData) {
                return;
            }

            UILabel *lblTbFooter=((UILabel*)[self.view viewWithTag:KKanBanTaskTBFooterBeginTag+_iCurIndexKanBan]);
            UIActivityIndicatorView *aITbFooter= ((UIActivityIndicatorView*)[self.view viewWithTag:KKanBanTaskTBFooterAcIndicatorBeginTag+_iCurIndexKanBan]);
            
            UITableView *tbView=((UITableView*)[self.view viewWithTag:KKanBanTaskTBBeginTag+_iCurIndexKanBan]);
            
            //类型
            ClassTaskSelfPlanType iTaskSelfPlanType=0;
            NSString *sKey=[_arrayKey objectAtIndex:_iCurIndexKanBan];
            
            if ([sKey isEqualToString:@"TaskIng"]) {
                iTaskSelfPlanType=ClassTaskSelfPlanTypeIng;
            }else if ([sKey isEqualToString:@"TaskNo"]){
                iTaskSelfPlanType=ClassTaskSelfPlanTypeNO;
            }else if ([sKey isEqualToString:@"TaskOk"]){
                iTaskSelfPlanType=ClassTaskSelfPlanTypeOk;
            }

            lblTbFooter.text =@"正在加载中...";
            aITbFooter.hidden=NO;
            [aITbFooter startAnimating];
            
            [ClassTask getSelfPlanTaskNoHUDCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] Page:[[_arrayCurIndexKanBan objectAtIndex:_iCurIndexKanBan]integerValue ] Rows:KPerDataNum TaskSelfPlanType:iTaskSelfPlanType returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                lblTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        lblTbFooter.text=@"已全部加载完毕";
                        [_arrayHasMoreData replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithBool:NO]];
                        
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if ([[_arrayCurIndexKanBan objectAtIndex:_iCurIndexKanBan] integerValue]==1) {
                            //先清除进入页面时初始化的数据
                            [_dictInitData  setObject:[returnArray mutableCopy] forKey:sKey];
                            
                            if (returnArray.count==KPerDataNum) {
                                [_arrayCurIndexKanBan replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithInteger:2]];
                            }else{
                                [_arrayHasMoreData replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithBool:NO]];
                                lblTbFooter.text=@"已全部加载完毕";
                            }
                        }else{
                            if (returnArray.count==KPerDataNum) {
                                NSInteger iIndex=[[_arrayCurIndexKanBan objectAtIndex:_iCurIndexKanBan]integerValue ];
                                iIndex=iIndex+1;
                                [_arrayCurIndexKanBan replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithInteger:iIndex]];
                                
                            }else{
                                [_arrayHasMoreData replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithBool:NO]];
                                lblTbFooter.text=@"已全部加载完毕";
                            }
                            //插入数据
                            //--原来数据
                            NSMutableArray *arrayNewData=[[NSMutableArray alloc] init];
                            arrayNewData=[_dictInitData objectForKey:sKey];
                            //--新增的数据
                            for (ClassTask *cClassTaskData in returnArray) {
                                [arrayNewData addObject:cClassTaskData];
                            }
                            [_dictInitData setObject:arrayNewData forKey:sKey];
                            [tbView reloadData];
                        }
                    }
                }
                aITbFooter.hidden=YES;
                [aITbFooter stopAnimating];
            }];
        }
    }else{
        
        if (scrollView.tag==KScrolTaskTag) {
            //本身scrol滚动
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.frame;
            _iCurIndexKanBan=offset.x / bounds.size.width;
            
            for (int i=0; i<=_arrayFinishTypeItem.count-1; i++) {
                ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+i ]).backgroundColor=[UIColor clearColor];
            }
            //选中
            ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+_iCurIndexKanBan ]).backgroundColor=[UIColor darkGrayColor];
            
            if (_iCurIndexKanBan*_iViewBtnW>=_iViewW) {
                NSInteger iCount=_iViewW/_iViewBtnW;
                _scrolKanBan.contentOffset=CGPointMake((_iCurIndexKanBan-iCount)*_iViewBtnW, 0);
            }else{
                _scrolKanBan.contentOffset=CGPointMake(0, 0);
            }
        }
    }
}

#pragma mark 选中某一看板
- (void)didBtnSelectKanBan:(id)sender{
    
    NSInteger iTag=((UIButton*)sender).tag;
    iTag=iTag-KKanBanButtonBeginTag;
    
    _iCurIndexKanBan=iTag;
    
    for (int i=0; i<=_arrayFinishTypeItem.count-1; i++) {
        ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+i]).backgroundColor=[UIColor clearColor];
    }
    //选中
    ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+iTag ]).backgroundColor=[UIColor darkGrayColor];
    
    //scrolLog定位
    _scrolTask.contentOffset=CGPointMake(iTag*_iViewW, 0);
    
}

#pragma mark 操作(增,删,改)看板后更新UI和数据
- (void)initViewAndDataAfterOperateLookBoard{
    
    [self loadingData];
}

@end
