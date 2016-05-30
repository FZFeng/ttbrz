//
//  UIViewControllerMyLog1.m
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMyLog.h"

#define KTaskTableViewTag  101
#define KLogTableViewTag   102
#define KTaskRowHeigth     30

#define KAccessoryImage    201
#define KAccessoryFile     202

#define KPerDataNum        5

@interface UIViewControllerMyLog (){
    NSArray *_menuItemArray;
    NSMutableArray *_logDataArray;
    NSMutableArray *_taskDataArray;
    
    //上,下拉时显示的数据
    NSMutableArray *_arryMoreData;
    DownMenuView *_downMenu;
    UIButton *_titleButton;
    float _fTaskRowCellH;
    float _fLogRowCellH;
    NSInteger iViewW;
    BOOL _bHasLoad;
    NSInteger _iCurTaskLogDataIndex;
    UIView *_viewShowImage;
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_sCurDownloadFilePath;
    
    NSTimer *_waitTimer;
    int _iTimer;
    
    //任务
    NSInteger _iCurLogDataIndex;//当前任务数据的页数
    UILabel *_taskTbFooterLabel;
    BOOL _bHasMoreTaskData;
    UIActivityIndicatorView *_taskTbFooterAcIndicator;//加载等待
    
    //日志
    IBOutlet UIButton *_titleDateButton;
    IBOutlet UIButton *_titleTodayButton;
    
    //任务数据列表
    IBOutlet UITableView *_taskTableView;
    //日志数据列表
    IBOutlet FZRefreshTableView *_logTableView;
    IBOutlet UIView *_titleDateBottomLineView;
    
    IBOutlet UIView *_taskAndLoglineView;
    
    IBOutlet UIView *_titleDateView;
}
@end

@implementation UIViewControllerMyLog

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_MyLog];
    
    [self setSomeControlHidden:YES];
    
    iViewW=CGRectGetWidth(self.view.frame);
    
    //注册cell
    UINib *nibReceiveTaskCell=[UINib nibWithNibName:@"TbCellLogReceiveTask" bundle:nil];
    [_taskTableView registerNib:nibReceiveTaskCell forCellReuseIdentifier:@"TbCellLogReceiveTask"];
    
    TbCellLogReceiveTask*receiveTaskCell=[_taskTableView dequeueReusableCellWithIdentifier:@"TbCellLogReceiveTask"];
    _fTaskRowCellH=CGRectGetHeight(receiveTaskCell.frame);
    
    //注册cell
    UINib *nibLogCell=[UINib nibWithNibName:@"TbCellLog" bundle:nil];
    [_logTableView registerNib:nibLogCell forCellReuseIdentifier:@"TbCellLog"];
    
    TbCellLog*logCell=[_logTableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
    _fLogRowCellH=CGRectGetHeight(logCell.frame);
    
    _bHasMoreTaskData=YES;
    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];
    
}

#pragma mark 从消息界面退回后更新消息数量
- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *messageNumAfterUpdateDefaults=[[NSUserDefaults alloc] init];
    NSString *sMessageNum=[messageNumAfterUpdateDefaults objectForKey:@"messageNumAfterUpdate"];
    
    if (![sMessageNum isEqualToString:@""] && sMessageNum) {
        self.tabBarController.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%@",sMessageNum];
    }
}

-(void)viewDidLayoutSubviews{
    if (_bHasLoad==NO) {
        _bHasLoad=YES;
        _logTableView = [_logTableView  initWithFrame:_logTableView.bounds pullingDelegate:self UITableViewStyle:UITableViewStylePlain];
        _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _logTableView.bNotShowMessageInUpRefreshing=YES;
    }

}
#pragma mark 某些控件隐藏/显示
- (void)setSomeControlHidden:(BOOL)bHidden{
    _titleDateBottomLineView.hidden=bHidden;
    _taskAndLoglineView.hidden=bHidden;
    _titleTodayButton.hidden=bHidden;
    _titleDateView.hidden=bHidden;
}

#pragma mark 等待加载数据
- (void)loadingData{
    //返回的returnArray中 0:任务信息 1:日志信息 2:部门信息 3:我的信息
    [ClassLog initInfoWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn,NSDictionary *returnDictionary) {
        if (bReturn) {
            
            [self setSomeControlHidden:NO];
            
            //当前日期 加上倒三角形
            [self getTodayDate];
            
            if (returnDictionary) {
                
                //循环获取消息
                [self startMessageInfo];
                
                //得到任务数据
                NSArray *curArrayData=[returnDictionary objectForKey:@"TaskInfo"];
                if (curArrayData.count>0) {
                    _taskDataArray=[curArrayData mutableCopy];
                }else{
                    _taskDataArray=[[NSMutableArray alloc] init];
                }
                
                //得到日志数据
                curArrayData=[returnDictionary objectForKey:@"LogInfo"];
                if (curArrayData.count>0) {
                    _logDataArray=[curArrayData mutableCopy];
                }else{
                    _logDataArray=[[NSMutableArray alloc] init];
                }
                
                //得到第一个部门 用于查看团队日志
                curArrayData=[returnDictionary objectForKey:@"DeptInfo"];
                ClassLog *cLogObject=[curArrayData firstObject];
                [[NSUserDefaults standardUserDefaults] setObject:cLogObject.sDeptID forKey:@"firstDepartmentId"];
                [[NSUserDefaults standardUserDefaults] setObject:cLogObject.sDeptName forKey:@"firstDepartmentName"];
            }else{
                _taskDataArray=[[NSMutableArray alloc] init];
                _logDataArray=[[NSMutableArray alloc] init];
            }

            //任务数据不足5条数据时 为数据的第一页
            if (_taskDataArray.count<KPerDataNum) {
                _iCurLogDataIndex=1;
            }else{
                _iCurLogDataIndex=2;
            }
            
            _taskTableView.tag=KTaskTableViewTag;
            _taskTableView.delegate=self;
            
            _logTableView.tag=KLogTableViewTag;
            _logTableView.delegate=self;
            _logTableView.dataSource=self;
            
            [self refreshTaskTable];
            [_logTableView reloadData];
            
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 循环获取消息(3分钟检测一次)
- (void)startMessageInfo{
    
    _iTimer=0;
    _waitTimer=[NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(getMessageInfo) userInfo:nil repeats:YES];
    [_waitTimer fire];
}

-(void)getMessageInfo{
    //----消息
    [ClassSearchAndMessage getMessageInfoWithID:[SystemPlist GetUserID] strType:@"1" page:1 rows:KPerDataNum returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            ClassSearchAndMessage *cObjectData=[returnArray firstObject];
            if (cObjectData.arrayMessageInfo.count>0) {
                self.tabBarController.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)cObjectData.iMessageCount];
                self.tabBarController.navigationItem.rightBarButtonItem.badgeBGColor =[UIColor redColor];
            }else{
                self.tabBarController.navigationItem.rightBarButtonItem.badgeValue=nil;
            }
        }else{
            [_waitTimer invalidate];
        }
        //记录消息数
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"messageNumAfterUpdate"];
    }];
    //----是否有需要审核的消息 有，就提示红点
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
        }else{
            [_waitTimer invalidate];
        }
    }];
    //----版本更新提示
    [ClassSearchAndMessage checkVersion:^(BOOL bReturn, NSString *sVersion) {
        if (bReturn) {
            //NSLog(@"%@",sVersion);
        }
    }];
}

#pragma mark 操作后刷新tableview
-(void)refreshTaskTable{
    if (!_taskDataArray || _taskDataArray.count==0) {
        UILabel *notTaskLabel=[[UILabel alloc] initWithFrame:_taskTableView.frame];
        notTaskLabel.text=@"当前没有你需要执行的任务 \n 请在任务看板中创建任务";
        notTaskLabel.numberOfLines=0;
        notTaskLabel.textAlignment=NSTextAlignmentCenter;
        notTaskLabel.font=[UIFont systemFontOfSize:14];
        notTaskLabel.textColor=[UIColor lightGrayColor];
        
        _taskTableView.tableFooterView=notTaskLabel;
        _taskTableView.dataSource=nil;
        _taskTableView.scrollEnabled=NO;
    }else{
        
        NSInteger taskTbFooterViewH=30;
        UIView *taskTbFooterView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), taskTbFooterViewH)];
        NSInteger taskTbFooterLabelW=100;
        
       _taskTbFooterLabel=[[UILabel alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, taskTbFooterViewH)];
        _taskTbFooterLabel.text=@"滑动加载更多 \u25BE";
        _taskTbFooterLabel.textAlignment=NSTextAlignmentCenter;
        _taskTbFooterLabel.font=[UIFont systemFontOfSize:13];
        _taskTbFooterLabel.textColor=[UIColor lightGrayColor];
        [taskTbFooterView addSubview:_taskTbFooterLabel];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _taskTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_taskTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _taskTbFooterAcIndicator.hidden=YES;
        [taskTbFooterView addSubview:_taskTbFooterAcIndicator];
        
        _taskTableView.tableFooterView=taskTbFooterView;
        _taskTableView.dataSource=self;
        _taskTableView.scrollEnabled=YES;
    }
    [_taskTableView reloadData];
}


#pragma mark 获取今天日期
- (NSString*)getTodayDate{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy年M月"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    [_titleDateButton setTitle:[dateString stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:nowDate];
}

#pragma mark 选择日期
- (IBAction)didTitleDate:(id)sender {
    FZDatePickerView *datePickerView=[[FZDatePickerView alloc] initWithReferView:self.view];
    datePickerView.delegate=self;
    [datePickerView show];
    
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    [_titleDateButton setTitle:[psReturnDate stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    [self initLogDataWithDate:displayDate];
}

#pragma mark 选择今天日期
- (IBAction)didTitleToday:(id)sender {
    [self initTodayLogData];
}


- (void)initTodayLogData{
    [self initLogDataWithDate:[self getTodayDate]];
}

#pragma mark 获取指定日期的日志数据
- (void)initLogDataWithDate:(NSString*)sDate{
//清空两数据
    [_arryMoreData removeAllObjects];
    [_logDataArray removeAllObjects];
    
    [ClassLog getLogDataWithDate:sDate dayNum:KPerDataNum iType:-1 userID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            _logDataArray=[returnArray mutableCopy];
            [_logTableView reloadData];
            [_logTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }];
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==KLogTableViewTag){
        return [_logDataArray count];
    }else{
        return [_taskDataArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==KLogTableViewTag) {
        ClassLog *cLogObject=[_logDataArray objectAtIndex:indexPath.row];
        
        TbCellLog*logCell;
        
        if (!logCell) {
            logCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
        }
        //TbCellLog*logCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
        logCell.cLogObject=cLogObject;
        logCell.btnEdit.tag=indexPath.row;
        [logCell.btnEdit addTarget:self action:@selector(didBtnEdit:) forControlEvents:UIControlEventTouchUpInside];
        [logCell initData];
        logCell.delegate=self;
        [logCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return logCell;
    }else{
        //任务数据列表
        TbCellLogReceiveTask*taskCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellLogReceiveTask"];
        //taskCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        ClassLog *cLogObject=[_taskDataArray objectAtIndex:indexPath.row];
        
        //判断任务是否已过期(超过一天)
        NSString *sTaskEndDate=cLogObject.sEndDate;
        NSTimeInterval timeBetween;
        if (cLogObject.isOntime) {
            NSDate *dTaskEndDate=[PublicFunc dateFromString:sTaskEndDate dateFormatterType:DateFromStringTypeYMD];
            timeBetween=[dTaskEndDate timeIntervalSinceNow];
        }
        timeBetween=-timeBetween;
        if (timeBetween>60*60*24) {
            taskCell.tbCellTaskTitleLabel.textColor=[UIColor redColor];
        }else{
            taskCell.tbCellTaskTitleLabel.textColor=[UIColor darkGrayColor];
        }

        taskCell.tbCellTaskTitleLabel.text=cLogObject.sPlanName;
        taskCell.tbCellTaskFinsihDateLabel.text=sTaskEndDate;
        taskCell.tbCellTaskPersentLabel.text=[NSString stringWithFormat:@"进度:%@",cLogObject.sProgress];
        return taskCell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==KTaskTableViewTag) {
        
        _iCurTaskLogDataIndex=indexPath.row;
        //ClassLog *cLogObject=[_taskDataArray objectAtIndex:indexPath.row];
        //任务ID 查看任务时使用
        //cLogObject.sPlanID
        //任务进度ID 更新任务进度时使用
        //cLogObject.sPlanItemId
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *checkTaskProgressAlert = [UIAlertAction actionWithTitle:@"查看任务" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self checkTaskProgress];
            }];
            UIAlertAction *markTaskProgressAlert = [UIAlertAction actionWithTitle:@"填报进度" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self markTaskProgress];
            }];
            
            [alertSelect addAction:cancelAction];
            [alertSelect addAction:checkTaskProgressAlert];
            [alertSelect addAction:markTaskProgressAlert];
            
            [self presentViewController:alertSelect animated:YES completion:nil];
        });
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==KLogTableViewTag) {
        NSInteger cellRowHeight=0;
        NSInteger detailControlHeight=30;
        NSInteger lineHeight=2;
        NSInteger logTbCellDetailViewWidth;
        
        ClassLog *cLogObject=[_logDataArray objectAtIndex:indexPath.row];
        //只创建一个cell用作测量高度
        static TbCellLog *logCell = nil;
        if (!logCell)
            logCell = [_logTableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
        logTbCellDetailViewWidth=CGRectGetWidth(logCell.logTbCellDetailView.frame);
        
        if (cLogObject.isLogExist || [cLogObject.sLogState integerValue]==LogStateTypeFinished) {
            //日志内容
            if (cLogObject.sLogContent) {
               //标题高度
                cellRowHeight=cellRowHeight+detailControlHeight;
                //分隔线
                cellRowHeight=cellRowHeight+lineHeight;
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
            //点评内容
            if (cLogObject.sEvaluationItemInfo && cLogObject.sEvaluationItemInfo.length>0) {
                //标题高度
                cellRowHeight=cellRowHeight+detailControlHeight;
                //分隔线
                cellRowHeight=cellRowHeight+lineHeight;
                //内容
                NSString *sEvaluationItemInfo=[cLogObject.sEvaluationItemInfo stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
                cellRowHeight=cellRowHeight+[PublicFunc heightForString:sEvaluationItemInfo font:[UIFont systemFontOfSize:15] andWidth:logTbCellDetailViewWidth];
            }
            if (cellRowHeight<=CGRectGetHeight(logCell.logTbCellDetailView.frame)) {
                cellRowHeight=_fLogRowCellH;
            }else{
                cellRowHeight=cellRowHeight+(_fLogRowCellH-CGRectGetHeight(logCell.logTbCellDetailView.frame));
            }
        }else{
            cellRowHeight=_fLogRowCellH;
        }
        return cellRowHeight;
    }else{
        return _fTaskRowCellH;
    }
}

#pragma mark FZRefreshTableViewDelegate回调
// 加载数据中
- (void) addDataing
{
    //从第 1 行开始 因为获取的数据中包含此行数据
    for (int x = 1; x < [_arryMoreData count]; x++)
    {
        [_logDataArray addObject:[_arryMoreData objectAtIndex:x]];
    }
}

- (void) insertDataing
{
    //先删除最后一行 因为获取的数据中包含此行数据
    [_logDataArray removeObjectAtIndex:0];
    for (int x = 0; x < [_arryMoreData count]; x++)
    {
        [_logDataArray insertObject:[_arryMoreData objectAtIndex:x] atIndex:0];
    }
}

-(void)pullingDownRefreshing:(refreshingReBlock)pBlock{
    //获取最近一次的最前一条记录的更新日期
    
    ClassLog *cLogObject=[_logDataArray firstObject];
    NSString *sUpdateDate=cLogObject.sLogDate;
    
    [ClassLog getLogDataWithBeginTime:sUpdateDate dayNum:KPerDataNum iType:1 userID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] returnBlock:^(BOOL bReturn,NSArray *returnArray,NSString *errMsg) {
        if (bReturn) {
            _arryMoreData=[returnArray mutableCopy];
            if (_arryMoreData.count>0) {
                
                if (_arryMoreData.count==1) {
                    pBlock(FinishedLoadingNoDataUpdate,0,nil);
                }else{
                    pBlock(FinishedLoadingMessageHasUpdateNum,_arryMoreData.count,nil);
                    //插入新数据
                    [self insertDataing];
                }
            }else{
                pBlock(FinishedLoadingNoDataUpdate,0,nil);
            }
        }else{
            //错误
            pBlock(FinishedLoadingMessageError,0,errMsg);
        }
    }];
    
}

-(void)pullingUpLoading:(refreshingReBlock)pBlock{
    //获取最近一次的最前一条记录的更新日期
    ClassLog *cLogObject=[_logDataArray lastObject];
    NSString *sUpdateDate=cLogObject.sLogDate;
    
    [ClassLog getLogDataWithBeginTime:sUpdateDate dayNum:KPerDataNum iType:-1 userID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] returnBlock:^(BOOL bReturn,NSArray *returnArray,NSString *errMsg) {
        if (bReturn) {
            _arryMoreData=[returnArray mutableCopy];
            if (_arryMoreData.count>0) {
                pBlock(FinishedLoadingMessageHasUpdateNum,_arryMoreData.count,nil);
                //插入新数据
                [self addDataing];
            }else{
                pBlock(FinishedLoadingNoDataUpdate,0,nil);
            }
        }else{
            //错误
            pBlock(FinishedLoadingMessageError,0,errMsg);
        }
    }];
}

#pragma mark - Scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    UITableView* fromTableView = (UITableView*)scrollView;
    if (fromTableView.tag==KLogTableViewTag){
        [_logTableView tableViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    UITableView* fromTableView = (UITableView*)scrollView;
    if (fromTableView.tag==KLogTableViewTag){
        [_logTableView tableViewDidEndDragging:scrollView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //判断是哪一个tableView 进行的划动
    UITableView* fromTableView = (UITableView*)scrollView;
    if (fromTableView.tag==KTaskTableViewTag) {
        
        //要划到底部才加载数据
        CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
        CGFloat contentY=scrollView.contentOffset.y;
        CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
        
        if (distanceFromBottom<=scrolHeight) {
            
            if (!_bHasMoreTaskData) {
                return;
            }
        
            //获取任务数据
            _taskTbFooterLabel.text=@"正在加载中...";
            _taskTbFooterAcIndicator.hidden=NO;
            [_taskTbFooterAcIndicator startAnimating];
            
            [ClassLog getPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] pageIndex:_iCurLogDataIndex rows:KPerDataNum returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                _taskTbFooterLabel.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        _taskTbFooterLabel.text=@"已全部加载完毕";
                        _bHasMoreTaskData=NO;
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if (_iCurLogDataIndex==1 ) {
                            //先清除进入页面时初始化的数据
                            [_taskDataArray removeAllObjects];
                            _taskDataArray=[returnArray mutableCopy];
                            if (returnArray.count==KPerDataNum) {
                                _iCurLogDataIndex=2;
                            }else{
                                _bHasMoreTaskData=NO;
                                _taskTbFooterLabel.text=@"已全部加载完毕";
                            }
                        }else{
                            if (returnArray.count==KPerDataNum) {
                                _iCurLogDataIndex++;
                            }else{
                                _bHasMoreTaskData=NO;
                                _taskTbFooterLabel.text=@"已全部加载完毕";
                            }
                            //插入数据
                            for (NSDictionary *dictData in returnArray) {
                                [_taskDataArray addObject:dictData];
                            }
                            [_taskTableView reloadData];
                        }
                    }
                }
                _taskTbFooterAcIndicator.hidden=YES;
                [_taskTbFooterAcIndicator stopAnimating];
            }];
            
        }
    }
}

#pragma mark TbCellLogDelegate 回调
- (void)didTbCellButtonDelegate:(id)sender curLogData:(ClassLog *)curLogData  returnType:(TbCellLogDelegateType)returnType{
    
    if (returnType==TbCellLogDelegateTypeLogEdit) {
        //编辑日志
        [ClassLog getDefaultConfirmUserWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            UIViewControllerAddNewLog *editLogView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerAddNewLog"];
            ClassLog *cLogObject=[returnArray firstObject];
            editLogView.bAddNewLog=NO;
            editLogView.sGetConfirmUserID=cLogObject.sCompanyUserID;
            editLogView.sGetConfirmUser=cLogObject.sCompangUserName;
            editLogView.sGetLogID=curLogData.sLogID;
            editLogView.sGetLogDate=curLogData.sLogDate;
            editLogView.sGetLogContent=curLogData.sLogContent;
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:editLogView animated:YES];
        }];
    }else if (returnType==TbCellLogDelegateTypeFileEdit){
        //文件编辑
        
        UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *reViewAction = [UIAlertAction actionWithTitle:@"在线预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //浏览相片
            UIButton *btnObj=sender;
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
             UIButton *btnObj=sender;
            [self downFileWithFilePath:btnObj.accessibilityLabel];
            
           
        }];
        
        UIAlertAction *deleteFileAction = [UIAlertAction actionWithTitle:@"删除文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIButton *btnObj=sender;
            NSString *sFilePath=btnObj.accessibilityLabel;
            NSString *sFileID=btnObj.accessibilityIdentifier;
            [ClassLog deleteLogFileWithFilePath:sFilePath fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                if (bReturn) {
                    [ClassLog deleteLogFilePathWithFileID:sFileID returnBlock:^(BOOL bReturn, NSArray *returnArray, NSString *errMsg) {
                        
                        if (bReturn) {
                            [PublicFunc ShowSuccessHUD:@"删除成功" view:self.view];
                            //更新数据
                            [self performSelector:@selector(initTodayLogData) withObject:nil afterDelay:1.5];
                        }else{
                            [PublicFunc ShowErrorHUD:errMsg view:self.view];
                        }
                    }];
                }
            }];
        }];
        
        [alertSelect addAction:cancelAction];
        [alertSelect addAction:reViewAction];
        [alertSelect addAction:downFileAction];
        [alertSelect addAction:deleteFileAction];
        
        [self presentViewController:alertSelect animated:YES completion:nil];
    
    }else if  (returnType==TbCellLogDelegateTypeUpFileEdit){
        //上传文件
        UIViewControllerUploadFile *uploadFileView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerUploadFile"];
        uploadFileView.sGetLogDate=curLogData.sLogDate;
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
        [self.navigationController pushViewController:uploadFileView animated:YES];
    }
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

#pragma mark - 查看任务
- (void)checkTaskProgress{
    ClassLog *cCurTaskLogData=[_taskDataArray objectAtIndex:_iCurTaskLogDataIndex];
    
    [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:cCurTaskLogData.sPlanID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            UIViewControllerPlanTask *planTaskView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerPlanTask"];
            planTaskView.cGetDetailPlanTaskData=[returnArray firstObject];
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:planTaskView animated:YES];
        }
    }];
}


#pragma mark - 填报进度
- (void)markTaskProgress{
    TaskProgressView *taskProgress=[[TaskProgressView alloc] initWithReferView:self.view];
    taskProgress.delegate=self;
    [taskProgress show];
}

//回调
- (void)taskProgressView:(UIView *)taskProgressView didProgressItem:(NSString *)progressItem{
    ClassLog *cCurTaskLogData=[_taskDataArray objectAtIndex:_iCurTaskLogDataIndex];
    //任务ID 查看任务时使用
    //cLogObject.sPlanID
    //任务进度ID 更新任务进度时使用
    //cLogObject.sPlanItemId
    NSInteger iProgress=[[progressItem substringToIndex:progressItem.length-1] integerValue];
    
    [ClassLog updateTaskProgressWithItemID:cCurTaskLogData.sPlanItemId iProgress:iProgress fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [PublicFunc ShowSuccessHUD:@"更新成功" view:self.view];
            //刷新进度
            cCurTaskLogData.sProgress=progressItem;
            [_taskDataArray replaceObjectAtIndex:_iCurTaskLogDataIndex withObject:cCurTaskLogData];
            [_taskTableView reloadData];
        }
    }];
}

#pragma mark 写日志,上传文件,提交日志
- (void)didBtnEdit:(id)sender {
    
    UIButton *btnObj=sender;
    ClassLog *sCurLogData=[_logDataArray objectAtIndex:btnObj.tag];
    
    UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addNewLogAction = [UIAlertAction actionWithTitle:@"写日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [ClassLog getDefaultConfirmUserWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            UIViewControllerAddNewLog *addNewLogView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerAddNewLog"];
            ClassLog *cLogObject=[returnArray firstObject];
            addNewLogView.bAddNewLog=YES;
            addNewLogView.sGetConfirmUser=cLogObject.sCompangUserName;
            addNewLogView.sGetConfirmUserID=cLogObject.sCompanyUserID;
            addNewLogView.sGetLogDate=sCurLogData.sLogDate;
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:addNewLogView animated:YES];
        }];
    }];
    UIAlertAction *upLoadFileAction = [UIAlertAction actionWithTitle:@"上传文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIViewControllerUploadFile *uploadFileView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerUploadFile"];
        uploadFileView.sGetLogDate=sCurLogData.sLogDate;
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
        [self.navigationController pushViewController:uploadFileView animated:YES];
    }];
    
    [alertSelect addAction:cancelAction];
    [alertSelect addAction:addNewLogAction];
    [alertSelect addAction:upLoadFileAction];
    
    if ([sCurLogData.sLogState integerValue]==LogStateTypeDoing) {
        //填报中
        _iCurLogDataIndex=btnObj.tag;
        UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"提交日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要提交日志吗,提交后日志不能再修改?(如不提交,系统将于夜间12点自动提交日志.)" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [alert show];
        }];
        [alertSelect addAction:submitAction];
    }
    
    [self presentViewController:alertSelect animated:YES completion:nil];
}
#pragma mark UIAlert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {
        ClassLog *sCurLogData=[_logDataArray objectAtIndex:_iCurLogDataIndex];
        [ClassLog commitLogWithTaskID:sCurLogData.sLogID companyID:[SystemPlist GetCompanyID] userName:[SystemPlist GetLoadUser] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"提交成功" view:self.view];
                //更新数据
                [self performSelector:@selector(initTodayLogData) withObject:nil afterDelay:1.5];
            }
        }];
    }
}
@end
