//
//  UIViewControllerKanbanInfo.m
//  ttbrz
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerKanbanInfo.h"
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


@interface UIViewControllerKanbanInfo ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>{

    IBOutlet UIView *_viewBtnAdd;
    NSInteger _iCurIndexKanBan;
    NSInteger _iScrolKanBanH,_iScrolTaskH,_iViewBtnH,_iViewBtnW,_iViewW,_iViewH,_iTop;
    NSMutableArray *_arrayHasMoreData;
    NSMutableArray *_arrayCurIndexKanBan;
    
    UIScrollView *_scrolKanBan;
    UIScrollView *_scrolTask;
    
    UIView *_viewOperateKanBan;
    UITextField *_txtKanBanName;
    
    NSInteger _iCurScrolKanBanOriginX;
    NSInteger _iCurOperateKanBanType;

    UILabel *_lblKanBanLine;
    NSInteger iRowHeight;
}

@end

@implementation UIViewControllerKanbanInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrayHasMoreData=[[NSMutableArray alloc] init];
    _arrayCurIndexKanBan=[[NSMutableArray alloc] init];
    _iCurOperateKanBanType=-1;
    _iCurIndexKanBan=0;//默认第一个看板
    
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=self.sGetTitle;
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //编辑
    UIButton *btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,35,30)];
    btnEdit.titleLabel.font=[UIFont systemFontOfSize:15];
    [btnEdit setBackgroundImage:[UIImage imageNamed:@"task_editkanban.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(didBtnEdit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
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
    

    [self initView];
}

#pragma mark 获取数据
- (void) loadingData{
    [ClassTask GetLookBoardAndTaskDataWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strLookBoardTypeID:self.sGetLookBoardTypeID Page:1 Rows:KPerDataNum fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [self.arrayInitData removeAllObjects];
             self.arrayInitData=[returnArray mutableCopy];
            
            for (UIView *subView in _scrolKanBan.subviews) {
                [subView removeFromSuperview];
            }
            for (UIView *subView in _scrolTask.subviews) {
                [subView removeFromSuperview];
            }
            
            _scrolKanBan.contentOffset=CGPointMake(0, 0);
            _scrolTask.contentOffset=CGPointMake(0, 0);
            
            [self initView];
            
            if (_iCurOperateKanBanType==ClassTaskOperateKanBanTypeAdd) {
                //选中新增的
                if (_iCurScrolKanBanOriginX>_iViewW) {
                    _scrolKanBan.contentOffset=CGPointMake(_iCurScrolKanBanOriginX-_iViewW, 0);
                }
                UIButton *btnObj=[self.view viewWithTag:KKanBanButtonBeginTag+self.arrayInitData.count-1 ];
                [self didBtnSelectKanBan:btnObj];
                
            }else if (_iCurOperateKanBanType==-1){
                //增,删,改后保持当前看板
                UIButton *btnObj=[self.view viewWithTag:KKanBanButtonBeginTag+_iCurIndexKanBan ];
                [self didBtnSelectKanBan:btnObj];
            }
            
            //关闭当前view;
            [self hideOpearteKanBanView];
        }
    }];
}

#pragma mark 初始化页百内容
- (void)initView{
    
    NSInteger iLblLineH=2;
    _iViewBtnW=65;
    
    [_arrayHasMoreData removeAllObjects];
    [_arrayCurIndexKanBan removeAllObjects];
     _iCurScrolKanBanOriginX=0;
    
    //生成scrolKanBan内容
    if (self.arrayInitData.count>0) {
        
        _lblKanBanLine.hidden=NO;
        
        for (ClassTask *cClassTaskData in self.arrayInitData) {
            [_arrayHasMoreData addObject:[NSNumber numberWithBool:YES]];
            
            //每个作任务集不超过KPerDataNum规定的数据的 默认第一行 等于KPerDataNum 的 默认第二行
            if (cClassTaskData.arrayTaskInfo.count==KPerDataNum) {
                [_arrayCurIndexKanBan addObject:[NSNumber numberWithInteger:2]];
            }else{
                [_arrayCurIndexKanBan addObject:[NSNumber numberWithInteger:1]];
            }
        }
        
        for (int i=0; i<=self.arrayInitData.count-1; i++) {
            ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:i];
            
            //view
            UIView *viewKanBan=[[UIView alloc] initWithFrame:CGRectMake(_iCurScrolKanBanOriginX, 0, _iViewBtnW, _iScrolKanBanH)];
            [_scrolKanBan addSubview:viewKanBan];
            
            //button
            UIButton *btnKanBan=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,_iViewBtnW,_iScrolKanBanH-iLblLineH)];
            btnKanBan.titleLabel.font=[UIFont systemFontOfSize:15];
            btnKanBan.backgroundColor=[UIColor clearColor];
            btnKanBan.tag=KKanBanButtonBeginTag+i;
            [btnKanBan setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btnKanBan setTitle:cClassTaskData.sLookBoardName forState:UIControlStateNormal];
            [btnKanBan addTarget:self action:@selector(didBtnSelectKanBan:) forControlEvents:UIControlEventTouchUpInside];
            [viewKanBan addSubview:btnKanBan];
            
            //selectedlineLable
            UILabel *lblSelectedLine=[[UILabel alloc] initWithFrame:CGRectMake(0,_iScrolKanBanH-iLblLineH,_iViewBtnW, iLblLineH)];
            lblSelectedLine.textAlignment=NSTextAlignmentCenter;
            lblSelectedLine.tag=KKanBanLabelBeginTag+i;
            if (i==0) {
                lblSelectedLine.backgroundColor=[UIColor darkGrayColor];
            }else{
                lblSelectedLine.backgroundColor=[UIColor clearColor];
            }
            [viewKanBan addSubview:lblSelectedLine];
            _iCurScrolKanBanOriginX=_iCurScrolKanBanOriginX+_iViewBtnW;
            
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
            if (cClassTaskData.arrayTaskInfo.count>0) {
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
        _scrolTask.contentSize=CGSizeMake(_iViewW*self.arrayInitData.count, _iScrolTaskH);
        if (_iCurScrolKanBanOriginX>_iViewW) {
            _scrolKanBan.contentSize=CGSizeMake(_iCurScrolKanBanOriginX, 0);
        }
    }else{
        _lblKanBanLine.hidden=YES;
        _iCurIndexKanBan=-1;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TbCellTaskInfo*myCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskInfo"];
    [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag];
    NSArray *arrayData=cClassTaskData.arrayTaskInfo;
    NSDictionary *dictData=[arrayData objectAtIndex:indexPath.row];
   
    //任务名称
    myCell.lblTaskName.text=[dictData objectForKey:@"TaskName"];
    
    //完成进度
    myCell.lblTaskProgress.text=[NSString stringWithFormat:@"%@%%",[dictData objectForKey:@"Progress"]];
    //完成日期
    
    myCell.lblTaskName.textColor=defaultColor;
    NSString *sTaskEndDate=[dictData objectForKey:@"TimeEnd"];
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
    NSString *sExecuteUserName=[dictData objectForKey:@"ExecuteUserName"];
    
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
        NSInteger iScrolW=60;
        NSInteger iLabelSize=25;
        NSInteger iCurOriginX=0;
        NSInteger iViewUsersH=CGRectGetHeight(myCell.viewUsers.frame);
        
        //清除原来旧的view
        for (UIView *subView in [myCell.viewUsers subviews]) {
            [subView removeFromSuperview];
        }

        UIScrollView *scrolMember=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,iViewUsers, iViewUsersH)];
        scrolMember.bounces=NO;
        scrolMember.scrollEnabled=YES;
        scrolMember.showsHorizontalScrollIndicator=NO;
        scrolMember.showsVerticalScrollIndicator=NO;
        scrolMember.contentSize=CGSizeMake(iScrolW*iDataNum+iGap*(iDataNum-1), 0);
        [myCell.viewUsers addSubview:scrolMember];
        
        for (NSString *sUserName in arrayUser) {
            UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX,(iViewUsersH-iLabelSize)/2,iLabelSize, iLabelSize)];
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
    
    //长按事件
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds  设置响应时间
    lpgr.delegate = self;
    lpgr.accessibilityLabel=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [myCell addGestureRecognizer:lpgr]; //启用长按事件
    
    return myCell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag];
    return cClassTaskData.arrayTaskInfo.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //编缉任务 先获取编辑任务的信息
    ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag];
    NSArray *arrayData=cClassTaskData.arrayTaskInfo;
    NSDictionary *dictData=[arrayData objectAtIndex:indexPath.row];
    
    //判断是否有任务编辑权限(没权限进入查看任务页面)
    BOOL bTaskCompetence=[[dictData objectForKey:@"TaskCompetence"] boolValue];
    
    if (bTaskCompetence) {
        [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:[dictData objectForKey:@"TaskID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            
            if (bReturn) {
                UIViewControllerEditCreateTaskInKanBan *editTaskInKanBanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerEditCreateTaskInKanBan"];
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                
                ClassLog *sGetClassData=[returnArray firstObject];
                
                NSString *sSelectKanBan=[NSString stringWithFormat:@"%@>%@",self.sGetTitle,sGetClassData.sLookBoardName];
                
                editTaskInKanBanView.sGetLookBoard=sSelectKanBan;
                editTaskInKanBanView.bEditTask=YES;
                editTaskInKanBanView.sGetTaskID=[dictData objectForKey:@"TaskID"];
                editTaskInKanBanView.sGetLookBoardID=sGetClassData.sLookBoardID;
                editTaskInKanBanView.cClassTaskData=sGetClassData;
                
                [self.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:editTaskInKanBanView animated:YES];
            }
        }];
    }else{
        //查看
        [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:[dictData objectForKey:@"TaskID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                UIViewControllerPlanTask *planTaskView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerPlanTask"];
                planTaskView.cGetDetailPlanTaskData=[returnArray firstObject];
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                [self.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:planTaskView animated:YES];
            }
        }];
    }
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
    
    ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:tableView.tag-KKanBanTaskTBBeginTag];
    NSArray *arrayData=cClassTaskData.arrayTaskInfo;
    NSDictionary *dictData=[arrayData objectAtIndex:indexPath.row];
    
    NSString *sExecuteUserName=[dictData objectForKey:@"ExecuteUserName"];
    
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

#pragma mark 长按事件(任务归档,删除)
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //长按响应函数
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
        
    {
        UILongPressGestureRecognizer *cObj=gestureRecognizer;
        NSInteger iTag=[cObj.accessibilityLabel integerValue];
        
        ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
        NSArray *arrayData=cClassTaskData.arrayTaskInfo;
        NSDictionary *dictData=[arrayData objectAtIndex:iTag];

        
        UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"归档任务" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [ClassTask archiveTaskWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strTaskID:[dictData objectForKey:@"TaskID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                if (bReturn) {
                    [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                    //更新数据
                    [cClassTaskData.arrayTaskInfo removeObjectAtIndex:iTag];
                    UITableView *tbView=((UITableView*)[self.view viewWithTag:KKanBanTaskTBBeginTag+_iCurIndexKanBan]);
                    [tbView reloadData];
                }
            }];
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除任务" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要删除吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alert.tag=KAlertDeleteTask;
            alert.accessibilityLabel=cObj.accessibilityLabel;
            [alert show];
            
        }];
        
        [alertSelect addAction:cancelAction];
        [alertSelect addAction:saveAction];
        [alertSelect addAction:deleteAction];
        
        [self presentViewController:alertSelect animated:YES completion:nil];
        
    }
}


#pragma mark 选中某一看板
- (void)didBtnSelectKanBan:(id)sender{
    
    NSInteger iTag=((UIButton*)sender).tag;
    iTag=iTag-KKanBanButtonBeginTag;
    
    _iCurIndexKanBan=iTag;
    
    for (int i=0; i<=self.arrayInitData.count-1; i++) {
        ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+i]).backgroundColor=[UIColor clearColor];
    }
    //选中
    ((UILabel*)[self.view viewWithTag:KKanBanLabelBeginTag+iTag ]).backgroundColor=[UIColor darkGrayColor];
    
    //scrolLog定位
    _scrolTask.contentOffset=CGPointMake(iTag*_iViewW, 0);

}

#pragma mark 编辑
- (void)didBtnEdit:(id)sender{
    
    UIButton *btnObj=sender;
    CGPoint point = CGPointMake(btnObj.frame.origin.x + btnObj.frame.size.width/2,  btnObj.frame.origin.y+btnObj.frame.size.height+15);
    NSArray *titles = @[@"新建看板", @"编辑看板",@"归档看板",@"删除看板"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:nil];
    pop.selectRowAtIndex = ^(NSInteger index){
        _iCurOperateKanBanType=index;
        if (index!=ClassTaskOperateKanBanTypeAdd) {
            //除了新建外 检查操作权限
            if (_iCurIndexKanBan==-1) {
                NSString *sNote=@"";
                
                if (index==1) {
                    sNote=@"没有可编缉的看板";
                }else if (index==2){
                    sNote=@"没有可归档的看板";
                }else if (index==3){
                    sNote=@"没有可删除的看板";
                }
                [PublicFunc ShowSimpleHUD:sNote view:self.view];
                return;
            }
            ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
            BOOL bOperate=cClassTaskData.bIsCompetence;
            if (!bOperate) {
                [PublicFunc ShowSimpleHUD:@"您没有操作权限" view:self.view];
                return;
            }
        }
        
        if (index==ClassTaskOperateKanBanTypeAdd || index==ClassTaskOperateKanBanTypeEdit) {
            //新建,编辑
            [self showOpearteKanBanView:index];
        }else if (index==ClassTaskOperateKanBanTypeSave){
            //归档
            ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
            [self operateKanBanWithType:index strLookBoardID:cClassTaskData.sLookBoardID];
        }else if (index==ClassTaskOperateKanBanTypeDelete){
            //删除
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要删除吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alert.tag=KAlertDeleteBookBoard;
            [alert show];
        }
    };
    [pop show];
}

#pragma mark 新增看板/编辑看板
- (void)showOpearteKanBanView:(ClassTaskOperateKanBanType)operateKanBanType{
    
    [self hideOpearteKanBanView];
    
    _viewOperateKanBan=[[UIView alloc] initWithFrame:self.view.frame];
    _viewOperateKanBan.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
    [self.view addSubview:_viewOperateKanBan];
    
    //点击空白关闭
    UIButton *bgButton=[[UIButton alloc] initWithFrame:self.view.frame];
    [bgButton addTarget:self action:@selector(hideOpearteKanBanView) forControlEvents:UIControlEventTouchUpInside];
    [_viewOperateKanBan addSubview:bgButton];
    
    NSInteger iViewShowLogInfoH=CGRectGetHeight(_viewOperateKanBan.frame);
    NSInteger iViewShowLogInfoW=CGRectGetWidth(_viewOperateKanBan.frame);
    NSInteger iViewDetailH=150;
    NSInteger iLeftOrRightGap=10;
    
    UIView *viewDetail=[[UIView alloc]  initWithFrame:CGRectMake(iLeftOrRightGap, (iViewShowLogInfoH-iViewDetailH)/2, iViewShowLogInfoW-iLeftOrRightGap*2, iViewDetailH)];
    viewDetail.backgroundColor=[UIColor whiteColor];
    [_viewOperateKanBan addSubview:viewDetail];
    
    //title
    NSInteger iLblTitleH=35;
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewDetail.frame), iLblTitleH)];
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    if (operateKanBanType==ClassTaskOperateKanBanTypeAdd) {
        lblTitle.text=@"新建看板";
    }else{
        lblTitle.text=@"编辑看板";
    }
    lblTitle.font=[UIFont systemFontOfSize:15];
    lblTitle.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
    [viewDetail addSubview:lblTitle];
    
    //backButton
    NSInteger iBtnBackW=35;
    UIButton *btnBack=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iBtnBackW, iBtnBackW)];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"modelViewBack.png"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(hideOpearteKanBanView) forControlEvents:UIControlEventTouchUpInside];
    [viewDetail addSubview:btnBack];
    
    //btn save
    NSInteger iBtnSaveOperateW=50;
    UIButton *btnSaveOperate=[[UIButton alloc] initWithFrame:CGRectMake( CGRectGetWidth(viewDetail.frame)-iBtnSaveOperateW, 0,iBtnSaveOperateW,iLblTitleH)];
    btnSaveOperate.titleLabel.font=[UIFont systemFontOfSize:15];
    btnSaveOperate.backgroundColor=[UIColor clearColor];
    btnSaveOperate.tag=operateKanBanType;
    [btnSaveOperate setTitle:@"保存" forState:UIControlStateNormal];
    [btnSaveOperate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSaveOperate addTarget:self action:@selector(didBtnSaveOperate:) forControlEvents:UIControlEventTouchUpInside];
    [viewDetail addSubview:btnSaveOperate];
    
    NSInteger iLblKanBan=65;
    NSInteger iGap=15;
    UILabel *lblKanBan=[[UILabel alloc] initWithFrame:CGRectMake(iGap,iLblTitleH+iGap,iLblKanBan, iLblTitleH)];
    lblKanBan.textColor=[UIColor darkGrayColor];
    lblKanBan.textAlignment=NSTextAlignmentCenter;
    lblKanBan.text=@"看板名称:";
    lblKanBan.font=[UIFont systemFontOfSize:15];
    [viewDetail addSubview:lblKanBan];
    
    //txt
    _txtKanBanName=[[UITextField alloc] initWithFrame:CGRectMake(iLblKanBan+iGap*2, iLblTitleH+iGap, CGRectGetWidth(viewDetail.frame)-iLblKanBan-iGap*3, iLblTitleH)];
    _txtKanBanName.layer.borderWidth=1.0;
    _txtKanBanName.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _txtKanBanName.clearButtonMode=UITextFieldViewModeWhileEditing;
    _txtKanBanName.delegate=self;
    if (operateKanBanType==ClassTaskOperateKanBanTypeEdit) {
        ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
        _txtKanBanName.text=cClassTaskData.sLookBoardName;
    }
    [viewDetail addSubview:_txtKanBanName];
    
}

- (void)hideOpearteKanBanView{
    [_viewOperateKanBan removeFromSuperview];
}

- (void)didBtnSaveOperate:(id)sender{
    
    [self disKeyboard];
    
    if (_txtKanBanName.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请输入看板名称" view:self.view];
        return;
    }
    
    NSInteger iTag=((UIButton*)sender).tag;
    NSString *sKanBanID=@"";
    
    if (iTag==ClassTaskOperateKanBanTypeEdit) {
        ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
        sKanBanID=cClassTaskData.sLookBoardID;
    }
    
    [self operateKanBanWithType:iTag strLookBoardID:sKanBanID];
}

#pragma mark 操作看板
- (void)operateKanBanWithType:(ClassTaskOperateKanBanType)operateKanBanType strLookBoardID:(NSString*)strLookBoardID{
    
    [ClassTask operateKanBanWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strLookBoardTypeID:self.sGetLookBoardTypeID strLookBoardID:strLookBoardID strLookBoardName:_txtKanBanName.text OperateKanBanType:operateKanBanType fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
            if (operateKanBanType==ClassTaskOperateKanBanTypeAdd) {
                //更新数据
                [self performSelector:@selector(loadingData) withObject:nil afterDelay:1.5];
            }else if (operateKanBanType==ClassTaskOperateKanBanTypeEdit){
                
                ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
                cClassTaskData.sLookBoardName=_txtKanBanName.text;
                [self.arrayInitData replaceObjectAtIndex:_iCurIndexKanBan withObject:cClassTaskData];
                
                 UIButton *btnObj=[self.view viewWithTag:KKanBanButtonBeginTag+_iCurIndexKanBan];
                [btnObj setTitle:_txtKanBanName.text forState:UIControlStateNormal];
                
                //更新对应值
                [self performSelector:@selector(hideOpearteKanBanView) withObject:nil afterDelay:1.5];
            
            }else if (operateKanBanType==ClassTaskOperateKanBanTypeSave || operateKanBanType==ClassTaskOperateKanBanTypeDelete){
                //更新数据
                [self performSelector:@selector(loadingData) withObject:nil afterDelay:1.5];
            }
        }
    }];
}

#pragma mark 删除看板
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==KAlertDeleteTask) {
        if (buttonIndex==0) {
            UIAlertView *cObj=alertView;
            NSInteger iTag=[cObj.accessibilityLabel integerValue];
            ClassTask *cClassTaskData =[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
            NSArray *arrayData=cClassTaskData.arrayTaskInfo;
            NSDictionary *dictData=[arrayData objectAtIndex:iTag];
            
            [ClassTask deleteTaskLookBoardWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] TaskID:[dictData objectForKey:@"TaskID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                if (bReturn) {
                    [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                    //更新数据
                    [cClassTaskData.arrayTaskInfo removeObjectAtIndex:iTag];
                    UITableView *tbView=((UITableView*)[self.view viewWithTag:KKanBanTaskTBBeginTag+_iCurIndexKanBan]);
                    [tbView reloadData];
                }
            }];

        }

    }else if (alertView.tag==KAlertDeleteBookBoard){
        if (buttonIndex==0) {
            ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
            [self operateKanBanWithType:ClassTaskOperateKanBanTypeDelete strLookBoardID:cClassTaskData.sLookBoardID];
        }
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

            //获取任务数据
            ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
            UILabel *lblTbFooter=((UILabel*)[self.view viewWithTag:KKanBanTaskTBFooterBeginTag+_iCurIndexKanBan]);
            UIActivityIndicatorView *aITbFooter= ((UIActivityIndicatorView*)[self.view viewWithTag:KKanBanTaskTBFooterAcIndicatorBeginTag+_iCurIndexKanBan]);
            
            UITableView *tbView=((UITableView*)[self.view viewWithTag:KKanBanTaskTBBeginTag+_iCurIndexKanBan]);
            
            lblTbFooter.text =@"正在加载中...";
            aITbFooter.hidden=NO;
            [aITbFooter startAnimating];

            
            [ClassTask GetCertainLookBoardAndTaskDataWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID]  LookBoardID:cClassTaskData.sLookBoardID Page:[[_arrayCurIndexKanBan objectAtIndex:_iCurIndexKanBan]integerValue ] Rows:KPerDataNum returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                lblTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        lblTbFooter.text=@"已全部加载完毕";
                        [_arrayHasMoreData replaceObjectAtIndex:_iCurIndexKanBan withObject:[NSNumber numberWithBool:NO]];
                        
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if ([[_arrayCurIndexKanBan objectAtIndex:_iCurIndexKanBan] integerValue]==1) {
                            //先清除进入页面时初始化的数据
                            [cClassTaskData.arrayTaskInfo removeAllObjects];
                            cClassTaskData.arrayTaskInfo=[returnArray mutableCopy];
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
                            for (NSDictionary *dictData in returnArray) {
                                [cClassTaskData.arrayTaskInfo addObject:dictData];
                            }
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
            
            for (int i=0; i<=self.arrayInitData.count-1; i++) {
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

#pragma mark 新增任务
- (IBAction)didBtnAdd:(id)sender {
    if (_iCurIndexKanBan==-1) {
        [PublicFunc ShowSimpleHUD:@"请先创建看板后再创建任务" view:self.view];
        return;
    }
    
    UIViewControllerEditCreateTaskInKanBan *createTaskInKanBanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerEditCreateTaskInKanBan"];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    ClassTask *cClassTaskData=[self.arrayInitData objectAtIndex:_iCurIndexKanBan];
    NSString *sSelectKanBan=[NSString stringWithFormat:@"%@>%@",self.sGetTitle,cClassTaskData.sLookBoardName];
    createTaskInKanBanView.sGetLookBoard=sSelectKanBan;
    createTaskInKanBanView.sGetLookBoardID=cClassTaskData.sLookBoardID;
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:createTaskInKanBanView animated:YES];

}

#pragma mark 键盘事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtKanBanName resignFirstResponder];
    return YES;
}
-(void)disKeyboard{
    [_txtKanBanName resignFirstResponder];
}

#pragma mark 操作(增,删,改)看板后更新UI和数据
- (void)initViewAndDataAfterOperateLookBoard{
    _iCurOperateKanBanType=-1;
    [self loadingData];
    
}
@end
