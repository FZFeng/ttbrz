//
//  UIViewControllerLogAssess.m
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerLogAssess.h"
#define  KPerDataNum 5

#define KAccessoryImage  201
#define KAccessoryFile   202

@interface UIViewControllerLogAssess ()<FZDatePickerViewDelegate,NSURLSessionDownloadDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,TbCellAssessLogDelegate>{

    IBOutlet UIButton *_btnSelected;
    IBOutlet UILabel *_lblLogNum;
    IBOutlet UIButton *_btnLogDate;
    IBOutlet UIButton *_btnAllAssess;
    IBOutlet UIView *_viewTitle;
    
    IBOutlet UITableView *_tbNeedAssessLogView;
    IBOutlet NSLayoutConstraint *_tbLayoutBottom;
    
    NSMutableArray *_arrayNeedAssessLog;
    
    NSString *_sCurDate;
    NSInteger _iCurLogDataIndex;//当前数据的页数  默认从1开始
    UILabel *_tbFooterLabel;
    float _fAssessLogRowCellH;
    BOOL _bHasMoreData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_tbFooterAcIndicator;//加载等待
    LogEvaluationType curLogEvaluationType;
    NSString *sNeedSaveLogID;//需要被考评的logID
    
    UIView *_viewShowLogInfo;
    UIView *_viewShowImage;
    
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_sCurDownloadFilePath;
    NSInteger _iViewW;
}

@end

@implementation UIViewControllerLogAssess

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_LogAssess];
    
    _iViewW=CGRectGetWidth(self.view.frame);
    
    //圆角
    _btnAllAssess.layer.cornerRadius =5.0;
    _btnLogDate.layer.cornerRadius =5.0;
    
    [_btnLogDate setTitle:@"所有日期\u25BE" forState:UIControlStateNormal];
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellAssessLog" bundle:nil];
    [_tbNeedAssessLogView registerNib:nibCell forCellReuseIdentifier:@"TbCellAssessLog"];
    
    TbCellAssessLog*assessLogCell=[_tbNeedAssessLogView dequeueReusableCellWithIdentifier:@"TbCellAssessLog"];
    _fAssessLogRowCellH=CGRectGetHeight(assessLogCell.frame);

    _sCurDate=@"";
    
    _arrayNeedAssessLog=[[NSMutableArray alloc] init];
    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];
}

#pragma mark 更新需要审核的消息数量
- (void)updateConfirmNum{

    //是否有需要审核的消息 有，就提示红点
    [ClassSearchAndMessage GetConfirmLogNumWithID:[SystemPlist GetUserID] returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                //记录消息数
                NSInteger iNum=[[[returnArray firstObject] objectForKey:@"ConfirmLogNum"]integerValue];
                
                if (iNum>0) {
                    [[NSUserDefaults standardUserDefaults] setObject:[[returnArray firstObject] objectForKey:@"ConfirmLogNum"] forKey:@"ConfirmLogNum"];
                    super.lblWaittingCheckNotice_Base.hidden=NO;
                }else{
                    super.lblWaittingCheckNotice_Base.hidden=YES;
                    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ConfirmLogNum"];
                }
            }
        }
    }];
}

#pragma mark 加载数据
- (void)loadingData{
    //默认没选中
    _btnSelected.accessibilityLabel=@"no";
    [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
    
    _bHasMoreData=YES;
    _iCurLogDataIndex=1;
    [_arrayNeedAssessLog removeAllObjects];
    
    //默认加载所有数据 用于显示需要审核的日志数，但_arrayNeedAssessLog 只取前五条数据
    [ClassLog getNeedAssessLogDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strDate:_sCurDate pageIndex:_iCurLogDataIndex rows:KPerDataNum*100 fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            
            if (returnArray.count>0) {
                //得到任务数据
                NSInteger iDataNum=returnArray.count;
                if (iDataNum>KPerDataNum) {
                    iDataNum=KPerDataNum;
                }
                
                for (int i=0; i<=iDataNum-1; i++) {
                    [_arrayNeedAssessLog addObject:[returnArray objectAtIndex:i]];
                }
            }else{
                _arrayNeedAssessLog=[[NSMutableArray alloc] init];
            }

            //任务数据不足5条数据时 为数据的第一页
            if (_arrayNeedAssessLog.count<KPerDataNum) {
                _iCurLogDataIndex=1;
            }else{
                _iCurLogDataIndex=2;
            }
            
            _tbNeedAssessLogView.delegate=self;
            _tbNeedAssessLogView.dataSource=self;
            
            [self refreshTaskTable];
            
            [_tbNeedAssessLogView reloadData];
            
            _lblLogNum.text=[NSString stringWithFormat:@"%lu",(unsigned long)returnArray.count];
        }
    }];
    
}

#pragma mark 操作后刷新tableview
-(void)refreshTaskTable{
    
    NSInteger iViewW=CGRectGetWidth(self.view.frame);
    
    if (!_arrayNeedAssessLog || _arrayNeedAssessLog.count==0) {
        UILabel *notTaskLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iViewW, 35)];
        notTaskLabel.text=@"当前没有需要审阅的日志";
        notTaskLabel.numberOfLines=0;
        notTaskLabel.textAlignment=NSTextAlignmentCenter;
        notTaskLabel.font=[UIFont systemFontOfSize:14];
        notTaskLabel.textColor=[UIColor lightGrayColor];
        
        _tbNeedAssessLogView.tableFooterView=notTaskLabel;
        _tbNeedAssessLogView.dataSource=nil;
        _tbNeedAssessLogView.scrollEnabled=NO;
        
    }else{
        
        NSInteger taskTbFooterViewH=30;
        UIView *taskTbFooterView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), taskTbFooterViewH)];
        NSInteger taskTbFooterLabelW=100;
        
        _tbFooterLabel=[[UILabel alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, taskTbFooterViewH)];
        _tbFooterLabel.text=@"滑动加载更多 \u25BE";
        _tbFooterLabel.textAlignment=NSTextAlignmentCenter;
        _tbFooterLabel.font=[UIFont systemFontOfSize:13];
        _tbFooterLabel.textColor=[UIColor lightGrayColor];
        [taskTbFooterView addSubview:_tbFooterLabel];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _tbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_tbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _tbFooterAcIndicator.hidden=YES;
        [taskTbFooterView addSubview:_tbFooterAcIndicator];
        
        _tbNeedAssessLogView.tableFooterView=taskTbFooterView;
        _tbNeedAssessLogView.dataSource=self;
        _tbNeedAssessLogView.scrollEnabled=YES;
        
        //回到顶部
        //[_tbNeedAssessLogView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    [_tbNeedAssessLogView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark 选中全部日志
- (IBAction)didBtnSelected:(id)sender {
    
    if (!_arrayNeedAssessLog || _arrayNeedAssessLog.count==0) {
        return;
    }
    
    if ([_btnSelected.accessibilityLabel isEqualToString:@"no"] ) {
        curLogEvaluationType=LogEvaluationTypeAll;
        _btnSelected.accessibilityLabel=@"yes";
        [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_AllSelected.png"] forState:UIControlStateNormal];
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            ClassLog *cCurObject=[_arrayNeedAssessLog objectAtIndex:i];
            cCurObject.bSelected=YES;
        }

    }else{
        curLogEvaluationType=LogEvaluationTypeNone;
        _btnSelected.accessibilityLabel=@"no";
        [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
        
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            ClassLog *cCurObject=[_arrayNeedAssessLog objectAtIndex:i];
            cCurObject.bSelected=NO;
        }
    }
    
    [_tbNeedAssessLogView reloadData];
}

#pragma mark 批量考评
- (IBAction)didBtnAllAssess:(id)sender {
    
    if (!_arrayNeedAssessLog || _arrayNeedAssessLog.count==0) {
        [PublicFunc ShowSimpleHUD:@"请选择需要考评的日志" view:self.view];
        return;
    }
    //判断是否有被选中的日志
    BOOL bHasLogSelected=NO;
    for (ClassLog *cLogObject in _arrayNeedAssessLog) {
        if (cLogObject.bSelected) {
            bHasLogSelected=YES;
            break;
        }
    }
    
    if (!bHasLogSelected) {
        [PublicFunc ShowSimpleHUD:@"请选择需要考评的日志" view:self.view];
        return;
    }
    
    //0 全选时 logid 空
    //1 先全选  部分取消 logid 不需要考评的日志(logid 间用逗号隔开)
    //2 未全选  部分勾选 logid 需要考评的日志(logid 间用逗号隔开)
    sNeedSaveLogID=@"";
    if (curLogEvaluationType==LogEvaluationTypeAll) {
        sNeedSaveLogID=@"";
    }else if (curLogEvaluationType==LogEvaluationTypeAllButSomeCancel){
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:i];
            if (!cLogObject.bSelected) {
                if ([sNeedSaveLogID isEqualToString:@""]) {
                    sNeedSaveLogID=cLogObject.sLogID;
                }else{
                    sNeedSaveLogID=[NSString stringWithFormat:@"%@,%@,",sNeedSaveLogID,cLogObject.sLogID];
                }
            }
        }
    }else if (curLogEvaluationType==LogEvaluationTypeUnAllButSomeCheck){
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:i];
            if (cLogObject.bSelected) {
                if ([sNeedSaveLogID isEqualToString:@""]) {
                    sNeedSaveLogID=cLogObject.sLogID;
                }else{
                    sNeedSaveLogID=[NSString stringWithFormat:@"%@,%@,",sNeedSaveLogID,cLogObject.sLogID];
                }
            }
        }
    }
    [self didEvaluationLog];
}

#pragma mark 个人日志考评
- (void)didSingleLogAssess:(id)sender{
    
    UIButton *btnObj=sender;
    NSInteger iCurRowIndex=btnObj.tag;
    ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:iCurRowIndex];
    sNeedSaveLogID=[NSString stringWithFormat:@"%@,",cLogObject.sLogID];
    curLogEvaluationType=LogEvaluationTypeSingle;//个人
    
    [self didEvaluationLog];
   
}

#pragma mark 去考评
- (void)didEvaluationLog{
    
    [ClassLog getEvaluationDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn,NSDictionary *returnDictionary) {
        if (bReturn) {
            //构成数据 每一行，有两个 NSDictionary title和value 基中 value 就是具体的数据项
            NSMutableArray *arrayResultData=[[NSMutableArray alloc] init];
            
            //上班时间，和动态考评项目
            ClassLog *cCurClassLog =[returnDictionary objectForKey:@"value"];
            NSString *sTitle;
            NSString *sValue;
            NSDictionary *curDictValue;
            
            //-----上班时间
            NSMutableDictionary *dictDayNum=[[NSMutableDictionary alloc] init];
            [dictDayNum setObject:@"上班时间" forKey:@"title"];
            
            NSMutableArray *arrayDayNumValue=[[NSMutableArray alloc] init];
            //0.5天
            sTitle=[NSString stringWithFormat:@"0.5天(%0.0f分)",0.5*[cCurClassLog.sDayNum integerValue]];
            sValue=[NSString stringWithFormat:@"%f",0.5*[cCurClassLog.sDayNum integerValue]];
            curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
            [arrayDayNumValue addObject:curDictValue];
            //1天
            sTitle=[NSString stringWithFormat:@"1天(%ld分)",1*[cCurClassLog.sDayNum integerValue]];
            sValue=[NSString stringWithFormat:@"%ld",1*[cCurClassLog.sDayNum integerValue]];
            curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
            [arrayDayNumValue addObject:curDictValue];
            //1.5天
            sTitle=[NSString stringWithFormat:@"1.5天(%0.0f分)",1.5*[cCurClassLog.sDayNum integerValue]];
            sValue=[NSString stringWithFormat:@"%f",1.5*[cCurClassLog.sDayNum integerValue]];
            curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
            [arrayDayNumValue addObject:curDictValue];
            
            [dictDayNum setObject:arrayDayNumValue forKey:@"value"];
            [arrayResultData addObject:dictDayNum];
            
            //-----动态项
            for (NSDictionary *curDict in cCurClassLog.arrayEvaluationItem) {
                NSMutableDictionary *dictEvaluation=[[NSMutableDictionary alloc] init];
                
                [dictEvaluation setObject:[curDict objectForKey:@"ItemName"] forKey:@"title"];
                
                NSMutableArray *arrayEvaluationValue=[[NSMutableArray alloc] init];
                
                //好评
                sTitle=[NSString stringWithFormat:@"好评(%@%%)",[curDict objectForKey:@"PraiseRate"] ];
                sValue=[curDict objectForKey:@"PraiseRate"];
                curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
                [arrayEvaluationValue addObject:curDictValue];
                [dictEvaluation setObject:arrayEvaluationValue forKey:@"value"];
                //中评
                sTitle=[NSString stringWithFormat:@"中评(%@%%)",[curDict objectForKey:@"MiddleRate"] ];
                sValue=[curDict objectForKey:@"MiddleRate"];
                curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
                [arrayEvaluationValue addObject:curDictValue];
                [dictEvaluation setObject:arrayEvaluationValue forKey:@"value"];
                
                //差评
                sTitle=[NSString stringWithFormat:@"差评(%@%%)",[curDict objectForKey:@"BadRate"] ];
                sValue=[curDict objectForKey:@"BadRate"];
                curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
                [arrayEvaluationValue addObject:curDictValue];
                [dictEvaluation setObject:arrayEvaluationValue forKey:@"value"];
                
                [arrayResultData addObject:dictEvaluation];
            }
            
            
            //-----奖励加分
            NSInteger iMaxAward=[[returnDictionary objectForKey:@"MaxAward"] integerValue];
            NSMutableDictionary *dictMaxAward=[[NSMutableDictionary alloc] init];
            [dictMaxAward setObject:@"奖励加分" forKey:@"title"];
            
            NSMutableArray *arrayMaxAwardValue=[[NSMutableArray alloc] init];
            for (int i=0; i<=iMaxAward-1; i++) {
                sTitle=[NSString stringWithFormat:@"%d分",i];
                sValue=[NSString stringWithFormat:@"%d",i];
                curDictValue=[[NSDictionary alloc] initWithObjectsAndKeys:sTitle,@"title",sValue,@"value" ,nil];
                [arrayMaxAwardValue addObject:curDictValue];
            }
            [dictMaxAward setObject:arrayMaxAwardValue forKey:@"value"];
            [arrayResultData addObject:dictMaxAward];
            
            ViewControllerLogEvaluation *LogEvaluationView=[self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerLogEvaluation"];
            LogEvaluationView.arrayData=[arrayResultData copy];
            LogEvaluationView.arrayCommentTemplate=cCurClassLog.arrayCommentTemplate;
            
            LogEvaluationView.sGetLogID=sNeedSaveLogID;
            LogEvaluationView.getLogEvaluationType=curLogEvaluationType;
            LogEvaluationView.sGetSelectDate=_sCurDate;
            
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:LogEvaluationView animated:YES];
        }
    }];
}

#pragma mark 选中当前日志
- (void)didSelectCertainAssessLog:(id)sender{
    UIButton *btnObj=sender;
    NSInteger iCurRowIndex=btnObj.tag;
    
    ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:iCurRowIndex];
    
    if (!cLogObject.bSelected ) {
        cLogObject.bSelected=YES;
        
        //判断其它cell以确定 LogEvaluationType
        BOOL bSelectAll=YES;
         [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_otherSelected.png"] forState:UIControlStateNormal];
        
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            //当前的cell不检测
            if (i==iCurRowIndex) {
                continue;
            }
            //检测其实cell
            ClassLog *cCurObject=[_arrayNeedAssessLog objectAtIndex:i];
            if (cCurObject.bSelected==NO) {
                bSelectAll=NO;
                break;
            }
        }
       //确定_btnSelected的图标 和 LogEvaluationType
        if (bSelectAll) {
            curLogEvaluationType=LogEvaluationTypeAll;//全部选中
             [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_AllSelected.png"] forState:UIControlStateNormal];
        }else{
            if (curLogEvaluationType==LogEvaluationTypeAllButSomeCancel){
                [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_allSelectedbut.png"] forState:UIControlStateNormal];
            }else{
                curLogEvaluationType=LogEvaluationTypeUnAllButSomeCheck;//未全选部分选中
            }
        }
    }else{
        cLogObject.bSelected=NO;
        BOOL bUnSelect=YES;
        
        for (int i=0; i<=_arrayNeedAssessLog.count-1; i++) {
            //当前的cell不检测
            if (i==iCurRowIndex) {
                continue;
            }
            //检测其实cell
            ClassLog *cCurObject=[_arrayNeedAssessLog objectAtIndex:i];
            if (cCurObject.bSelected==YES) {
                bUnSelect=NO;
                break;
            }
        }
        //没有被选中的项
        if (bUnSelect) {
            curLogEvaluationType=LogEvaluationTypeNone;
            [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
        }else{
            if (curLogEvaluationType==LogEvaluationTypeAll) {
                curLogEvaluationType=LogEvaluationTypeAllButSomeCancel;//先全选,部分取消
                [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_allSelectedbut.png"] forState:UIControlStateNormal];
            }
        }
    }
    [_tbNeedAssessLogView reloadData];
}

#pragma mark 选择日期/全部日期
- (IBAction)didBtnLogDate:(id)sender {
    
    UIButton *btnObj=sender;
    
    CGPoint point = CGPointMake(btnObj.frame.origin.x + btnObj.frame.size.width/2, _viewTitle.frame.origin.y + btnObj.frame.size.height);
    NSArray *titles = @[@"所有日期 \u25BE", @"选择日期 \u25BE"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:nil];
    pop.selectRowAtIndex = ^(NSInteger index){
        if (index==0) {
            //所有日期
            [_btnLogDate setTitle:@"所有日期\u25BE" forState:UIControlStateNormal];
            _sCurDate=@"";
            [self loadingData];
        }else{
            //指定日期
            FZDatePickerView *datePickerView=[[FZDatePickerView alloc] initWithReferView:self.view];
            datePickerView.delegate=self;
            [datePickerView show];
        }
    };
    [pop show];
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    NSArray *arrayDate=[displayDate componentsSeparatedByString:@"-"];
    NSString *sDateTitle=[NSString stringWithFormat:@"%@-%@",[arrayDate objectAtIndex:1],[arrayDate objectAtIndex:2]];
    [_btnLogDate setTitle:[sDateTitle stringByAppendingString:@"  \u25BE"] forState:UIControlStateNormal];
    _sCurDate=displayDate;
    [self loadingData];
}


#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayNeedAssessLog.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:indexPath.row];
    TbCellAssessLog *assessLogCell;
    
    if (!assessLogCell) {
        assessLogCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellAssessLog"];
    }
    assessLogCell.delegate=self;
    assessLogCell.cLogObject=cLogObject;
    assessLogCell.bSelected=NO;
    assessLogCell.btnSelected.tag=indexPath.row;
    [assessLogCell.btnSelected addTarget:self action:@selector(didSelectCertainAssessLog:) forControlEvents:UIControlEventTouchUpInside];
    //个人考评
    [assessLogCell.btnAssess addTarget:self action:@selector(didSingleLogAssess:) forControlEvents:UIControlEventTouchUpInside];
    assessLogCell.btnAssess.tag=indexPath.row;
    [assessLogCell initData];
    //teamLogCell.delegate=self;
    [assessLogCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return assessLogCell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellRowHeight=0;
    NSInteger detailControlHeight=30;
    NSInteger lineHeight=2;
    NSInteger logTbCellDetailViewWidth;
    
    ClassLog *cLogObject=[_arrayNeedAssessLog objectAtIndex:indexPath.row];
    //只创建一个cell用作测量高度
    static TbCellAssessLog *assessLogCell = nil;
    if (!assessLogCell)
        assessLogCell = [_tbNeedAssessLogView dequeueReusableCellWithIdentifier:@"TbCellAssessLog"];
    logTbCellDetailViewWidth=CGRectGetWidth(assessLogCell.viewTeamLogDetail.frame);
    
    //日志内容
    if (cLogObject.sLogContent) {
        //内容高度
        NSString *sLogContent=[cLogObject.sLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
        cellRowHeight=cellRowHeight+[PublicFunc heightForString:sLogContent font:[UIFont systemFontOfSize:15] andWidth:logTbCellDetailViewWidth];
    }
    //上传文件内容
    if (cLogObject.arrayAccessory) {
        NSMutableArray *arrayAccessory=[[cLogObject.arrayAccessory copy] objectForKey:@"Result"];
        if (arrayAccessory.count>0){
            //标题高度
            cellRowHeight=cellRowHeight+detailControlHeight;
            //分隔线
            cellRowHeight=cellRowHeight+lineHeight;
            //内容
            cellRowHeight=cellRowHeight+arrayAccessory.count*detailControlHeight;
        }
    }
    
    if (cellRowHeight<=CGRectGetHeight(assessLogCell.viewTeamLogDetail.frame)) {
        cellRowHeight=_fAssessLogRowCellH;
    }else{
        cellRowHeight=cellRowHeight+(_fAssessLogRowCellH-CGRectGetHeight(assessLogCell.viewTeamLogDetail.frame));
    }
    
    return cellRowHeight;
}

#pragma mark - Scroll 加载更多数据
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (!_bHasMoreData) {
        return;
    }
    
    //要划到底部才加载数据
    CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
    CGFloat contentY=scrollView.contentOffset.y;
    CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
    
    if (distanceFromBottom<=scrolHeight) {
        //获取任务数据
        _tbFooterLabel.text=@"正在加载中...";
        _tbFooterAcIndicator.hidden=NO;
        [_tbFooterAcIndicator startAnimating];
        
        [ClassLog getNeedAssessLogDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strDate:_sCurDate pageIndex:_iCurLogDataIndex rows:KPerDataNum fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            _tbFooterLabel.text=@"滑动加载更多 \u25BE";
            if (bReturn) {
                if (!returnArray || returnArray.count==0) {
                    _tbFooterLabel.text=@"已全部加载完毕";
                    _bHasMoreData=NO;
                }else{
                    //任务数据不足5条数据时 为数据的第一页
                    if (_iCurLogDataIndex==1 ) {
                        //先清除进入页面时初始化的数据
                        _btnSelected.accessibilityLabel=@"no";
                        [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
                        
                        [_arrayNeedAssessLog removeAllObjects];
                        _arrayNeedAssessLog=[returnArray mutableCopy];
                        if (returnArray.count==KPerDataNum) {
                            _iCurLogDataIndex=2;
                        }else{
                            _bHasMoreData=NO;
                            _tbFooterLabel.text=@"已全部加载完毕";
                        }
                    }else{
                        if (returnArray.count==KPerDataNum) {
                            _iCurLogDataIndex++;
                        }else{
                            _bHasMoreData=NO;
                            _tbFooterLabel.text=@"已全部加载完毕";
                        }
                        //插入数据
                        for (NSDictionary *dictData in returnArray) {
                            [_arrayNeedAssessLog addObject:dictData];
                        }
                        [_tbNeedAssessLogView reloadData];
                    }
                }
            }
            _tbFooterAcIndicator.hidden=YES;
            [_tbFooterAcIndicator stopAnimating];
             _lblLogNum.text=[NSString stringWithFormat:@"%lu",(unsigned long)_arrayNeedAssessLog.count];
        }];
    }
}

#pragma mark TbCellTeamLogDelegate
- (void)didTbCellAssessLogButtonDelegate:(id)sender curLogData:(ClassLog*)curLogData{
    UIButton *btnObj=sender;
    
    UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *reViewAction = [UIAlertAction actionWithTitle:@"在线预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //浏览相片
        
        if (btnObj.tag==KAccessoryImage) {
            [ClassLog imagePreviewWithStrUrl:btnObj.accessibilityLabel fatherObject:self returnBlock:^(BOOL bReturn, NSDictionary *returnDictionary) {
                if (bReturn) {
                    
                    NSString *sFile=[returnDictionary objectForKey:@"Content"];
                    NSData *imageData=[[NSData alloc] initWithBase64EncodedString:sFile options:kNilOptions];
                    
                    //弹出图片
                    _viewShowImage=[[UIView alloc] initWithFrame:self.view.frame];
                    _viewShowImage.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                    [self.view addSubview:_viewShowImage];
                    
                    //点击空白关闭
                    UIButton *bgButton=[[UIButton alloc] initWithFrame:self.view.frame];
                    [bgButton addTarget:self action:@selector(hideViewShowImage) forControlEvents:UIControlEventTouchUpInside];
                    [_viewShowImage addSubview:bgButton];
                    
                    
                    NSInteger iViewShowImageH=CGRectGetHeight(_viewShowImage.frame);
                    NSInteger iViewShowImageW=CGRectGetWidth(_viewShowImage.frame);
                    NSInteger iViewDetailH=250;
                    NSInteger iLeftOrRightGap=10;
                    
                    UIView *viewDetail=[[UIView alloc]  initWithFrame:CGRectMake(iLeftOrRightGap, (iViewShowImageH-iViewDetailH)/2, iViewShowImageW-iLeftOrRightGap*2, iViewDetailH)];
                    [_viewShowImage addSubview:viewDetail];
                    
                    //title
                    NSInteger iLblTitleH=35;
                    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewDetail.frame), iLblTitleH)];
                    lblTitle.textColor=[UIColor whiteColor];
                    lblTitle.textAlignment=NSTextAlignmentCenter;
                    lblTitle.text=@"图片预览";
                    lblTitle.font=[UIFont systemFontOfSize:15];
                    lblTitle.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
                    [viewDetail addSubview:lblTitle];
                    
                    //backButton
                    NSInteger iBtnBackW=35;
                    UIButton *btnBack=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iBtnBackW, iBtnBackW)];
                    [btnBack setBackgroundImage:[UIImage imageNamed:@"modelViewBack.png"] forState:UIControlStateNormal];
                    [btnBack addTarget:self action:@selector(hideViewShowImage) forControlEvents:UIControlEventTouchUpInside];
                    [viewDetail addSubview:btnBack];
                    
                    //image
                    UIImageView *imageDishView=[[UIImageView alloc] initWithFrame:CGRectMake(0,iLblTitleH, CGRectGetWidth(viewDetail.frame), CGRectGetHeight(viewDetail.frame)-iLblTitleH)];
                    //imageDishView.contentMode = UIViewContentModeScaleAspectFit;
                    [viewDetail addSubview:imageDishView];
                    
                    imageDishView.image=[UIImage imageWithData:imageData];
                }
            }];
        }else{
            //文件在线预览
            //1、调用地址：http://officeweb365.com/o/?i=5510&furl=http://testfile.ttbrz.cn/+文件路径
            NSString *sUrl=[NSString stringWithFormat:@"http://officeweb365.com/o/?i=5510&furl=http://testfile.ttbrz.cn%@",btnObj.accessibilityLabel];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
            
        }
        
        
    }];
    UIAlertAction *downFileAction = [UIAlertAction actionWithTitle:@"下载文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //后台下载文件
        [self downFileWithFilePath:btnObj.accessibilityLabel];
        
    }];
    
    [alertSelect addAction:cancelAction];
    [alertSelect addAction:reViewAction];
    [alertSelect addAction:downFileAction];
    
    [self presentViewController:alertSelect animated:YES completion:nil];
    
    
}

#pragma mark 下载文件
- (void)downFileWithFilePath:(NSString*)filePath{
    //判断文件是否下载到本地
    NSArray *arrayDownloadFiles  = [[NSArray  alloc]initWithContentsOfFile: [SystemPlist returnDownloadFilePath]];
    
    for (NSDictionary *dictData in arrayDownloadFiles) {
        if ([[dictData objectForKey:@"fileFilePath"] isEqualToString:filePath]) {
            [PublicFunc ShowSimpleHUD:@"此文件已下载" view:self.view];
            return;
        }
    }
    
    _sCurDownloadFilePath=filePath;
    NSString *urlStr=[NSString stringWithFormat: @"%@%@",KServerUrl_file,filePath];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //后台会话
    _downloadTask=[[self backgroundSession] downloadTaskWithRequest:request];
    
    [_downloadTask resume];
    
}
// - 下载任务代理
// 下载中(会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //    [NSThread sleepForTimeInterval:0.5];
    //    NSLog(@"%.2f",(double)totalBytesWritten/totalBytesExpectedToWrite);
}

// 下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSError *error;
    
    //保存文件
    NSString *sExtension=[_sCurDownloadFilePath pathExtension];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *sFileTitle=[NSString stringWithFormat:@"%@.%@",currentDateStr,sExtension];
    NSURL *saveUrl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",[SystemPlist returnDownloadFileFolderPath],sFileTitle]];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&error];
    
    if (error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [PublicFunc ShowErrorHUD:@"文件下载失败"  view:self.view];
        }];
        
    }else{
        //记录plist数据
        NSMutableArray *arrayInfo  = [[NSMutableArray  alloc]initWithContentsOfFile: [SystemPlist returnDownloadFilePath]];
        NSDictionary *dictInfo=@{@"fileFilePath":_sCurDownloadFilePath,@"fileExtension":sExtension,@"fileTitle":sFileTitle};
        [arrayInfo addObject:dictInfo];
        [arrayInfo writeToFile:[SystemPlist returnDownloadFilePath] atomically:YES];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [PublicFunc ShowSuccessHUD:@"文件下载成功" view:self.view];
        }];
    }
}

// 任务完成，不管是否下载成功
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        NSLog(@"DidCompleteWithError:Error is %@",error.localizedDescription);
    }
}

-(NSURLSession *)backgroundSession{
    static NSURLSession *session;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.cmjstudio.URLSession"];
        sessionConfig.timeoutIntervalForRequest=5.0f;//请求超时时间
        sessionConfig.discretionary=YES;//系统自动选择最佳网络下载
        sessionConfig.HTTPMaximumConnectionsPerHost=5;//限制每次最多一个连接
        //创建会话
        session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];//指定配置和代理
    });
    return session;
}


#pragma mark 关闭浏览图片
- (void)hideViewShowImage{
    [_viewShowImage removeFromSuperview];
}
@end
