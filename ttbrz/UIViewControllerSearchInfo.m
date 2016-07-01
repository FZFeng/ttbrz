//
//  UIViewControllerSearchInfo.m
//  ttbrz
//
//  Created by apple on 16/3/27.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerSearchInfo.h"

#define KPerDataNum        10
#define KTbView_Log        101
#define KTbView_File       102
#define KTbView_Task       103
#define KViewTbFooterH     30

#define KTbCellRowHeight  40

@interface UIViewControllerSearchInfo ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,NSURLSessionDownloadDelegate>{

    IBOutlet UITextField *_txtSearchKey;
    IBOutlet UIView *_viewSearchKey;
    IBOutlet UIView *_viewControl;
    IBOutlet UIScrollView *_scrolMain;
    IBOutlet UIView *_viewScrol;
    
    NSMutableArray *_arrayDataLog;
    NSMutableArray *_arrayDataFile;
    NSMutableArray *_arrayDataTask;
    
    NSInteger _iDataLogCount;
    NSInteger _iDataFileCount;
    NSInteger _iDataTaskCount;
 
    IBOutlet UIView *viewControl_LogLine;
    IBOutlet UIView *viewControl_FileLine;
    IBOutlet UIView *viewControl_TaskLine;
    
    IBOutlet UIButton *btnControl_Log;
    IBOutlet UIButton *btnControl_File;
    IBOutlet UIButton *btnControl_Task;
    
    UITableView *tbLogView;
    UITableView *tbFileView;
    UITableView *tbTaskView;
    
    
    UILabel *_lblLogTbFooter;
    UILabel *_lblFileTbFooter;
    UILabel *_lblTaskTbFooter;
    
    NSInteger _iCurLogDataIndex;//当前数据的页数
    NSInteger _iCurFileDataIndex;//当前数据的页数
    NSInteger _iCurTaskDataIndex;//当前数据的页数
    
    BOOL _bHasMoreLogData;//标记是否还能加载更多数据
    BOOL _bHasMoreFileData;//标记是否还能加载更多数据
    BOOL _bHasMoreTaskData;//标记是否还能加载更多数据
    
    
    UIActivityIndicatorView *_logTbFooterAcIndicator;//加载等待
    UIActivityIndicatorView *_fileTbFooterAcIndicator;//加载等待
    UIActivityIndicatorView *_taskTbFooterAcIndicator;//加载等待
    
    BOOL _bLoadLayoutSubviews;
    UIScrollView *scrolFunc;
    NSInteger _iCurY;
    NSInteger _iScrolMainW;
    NSInteger _iScrolMainH;
    
    UIView *_viewShowLogInfo;
    UIView *_viewShowImage;
    
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_sCurDownloadFilePath;
    
}

@end

@implementation UIViewControllerSearchInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"全局搜索";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    _txtSearchKey.placeholder=@"请输入关键字";
    _txtSearchKey.clearButtonMode=UITextFieldViewModeWhileEditing;
    _txtSearchKey.delegate=self;
    
    //圆角
    _viewSearchKey.layer.borderWidth=1.0;
    _viewSearchKey.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _viewSearchKey.layer.cornerRadius =5.0;
    
    _arrayDataLog=[[NSMutableArray alloc] init];
    _arrayDataFile=[[NSMutableArray alloc] init];
    _arrayDataTask=[[NSMutableArray alloc] init];
    
    _iDataLogCount=0;
    _iDataFileCount=0;
    _iDataTaskCount=0;
    
    
    _scrolMain.bounces=NO;
    _scrolMain.delegate=self;
    _scrolMain.scrollEnabled=YES;
    _scrolMain.pagingEnabled=YES;
    _scrolMain.showsHorizontalScrollIndicator=NO;
    _scrolMain.showsVerticalScrollIndicator=NO;
    
    _iCurLogDataIndex=1;
    _iCurFileDataIndex=1;
    _iCurTaskDataIndex=1;
    
    _bHasMoreLogData=YES;
    _bHasMoreFileData=YES;
    _bHasMoreTaskData=YES;
    
}

-(void)viewDidLayoutSubviews{
    if (!_bLoadLayoutSubviews) {
        _bLoadLayoutSubviews=YES;
        _iScrolMainW=_scrolMain.frame.size.width;
        _iScrolMainH=CGRectGetHeight(self.view.frame)-CGRectGetHeight(_viewControl.frame)-64-20-KViewTbFooterH;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 所有txtfield的键盘消失

//键盘消失事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtSearchKey resignFirstResponder];
    return YES;
}
-(void)disKeyboard{
    [_txtSearchKey resignFirstResponder];
}

- (IBAction)didBtnSearch:(id)sender {
    
    if (_txtSearchKey.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请输入关键字搜索" view:self.view];
    }else{
        [self disKeyboard];
        
        [ClassSearchAndMessage searchDataWithKey:_txtSearchKey.text iType:0 page:1 rows:KPerDataNum companyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                if (returnArray.count>0) {
                    ClassSearchAndMessage *cClassData=[returnArray firstObject];
                    
                    if ((NSNull*)cClassData.arraySearchData_TaskInfo!=[NSNull null]) {
                         _arrayDataTask=[cClassData.arraySearchData_TaskInfo mutableCopy];
                        if (_arrayDataTask.count==KPerDataNum) {
                            _iCurTaskDataIndex=2;
                        }
                        _iDataTaskCount=cClassData.iSearchData_TaskInfoCount;
                    }
                    
                    if ((NSNull*)cClassData.arraySearchData_LogInfo!=[NSNull null]) {
                       _arrayDataLog=[cClassData.arraySearchData_LogInfo mutableCopy];
                        if (_arrayDataLog.count==KPerDataNum) {
                            _iCurLogDataIndex=2;
                        }
                        _iDataLogCount=cClassData.iSearchData_LogInfoCount;
                    }
                    
                    if ((NSNull*)cClassData.arraySearchData_FileInfo!=[NSNull null]) {
                        _arrayDataFile=[cClassData.arraySearchData_FileInfo mutableCopy];
                        if (_arrayDataFile.count==KPerDataNum) {
                            _iCurFileDataIndex=2;
                        }
                        _iDataFileCount=cClassData.iSearchData_FileInfoCount;
                    }
                   
                    //构建UI信息
                    [self initView];
                    
                }
            }
        }];
    }
}

- (IBAction)didBtnControl_Log:(id)sender {
    
    viewControl_LogLine.hidden=NO;
    viewControl_FileLine.hidden=YES;
    viewControl_TaskLine.hidden=YES;
    
     _scrolMain.contentOffset=CGPointMake(0, 0);

}

- (IBAction)didBtnControl_File:(id)sender {
    viewControl_LogLine.hidden=YES;
    viewControl_FileLine.hidden=NO;
    viewControl_TaskLine.hidden=YES;
    
     _scrolMain.contentOffset=CGPointMake(_iScrolMainW, 0);
}

- (IBAction)didBtnControl_Task:(id)sender {
    
    viewControl_LogLine.hidden=YES;
    viewControl_FileLine.hidden=YES;
    viewControl_TaskLine.hidden=NO;
    
     _scrolMain.contentOffset=CGPointMake(_iScrolMainW*2, 0);
    
}

#pragma mark 加载更多数据
- (void)loadMoreDataWithTag:(NSInteger)iTag{
    //iTag 1:日志 2:任务 3:文件
    
    NSInteger iCurDataIndex;
    
    if (iTag==1) {
        _lblLogTbFooter.text=@"正在加载中...";
        _logTbFooterAcIndicator.hidden=NO;
        [_logTbFooterAcIndicator startAnimating];
        iCurDataIndex=_iCurLogDataIndex;
    }else if (iTag==2){
        _lblTaskTbFooter.text=@"正在加载中...";
        _taskTbFooterAcIndicator.hidden=NO;
        [_taskTbFooterAcIndicator startAnimating];
        iCurDataIndex=_iCurTaskDataIndex;
    }else{
        _lblFileTbFooter.text=@"正在加载中...";
        _fileTbFooterAcIndicator.hidden=NO;
        [_fileTbFooterAcIndicator startAnimating];
        iCurDataIndex=_iCurFileDataIndex;
    }
    
    [ClassSearchAndMessage searchDataNoHUDWithKey:_txtSearchKey.text iType:iTag page:iCurDataIndex rows:KPerDataNum companyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID]  returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                if (iTag==1) {
                    //日志
                    _lblLogTbFooter.text=@"滑动加载更多 \u25BE";
                    if (bReturn) {
                        ClassSearchAndMessage *cClassData=[returnArray firstObject];
                        NSArray *arrayLogData=cClassData.arraySearchData_LogInfo;
                        if (!arrayLogData || arrayLogData.count==0) {
                            _lblLogTbFooter.text=@"已全部加载完毕";
                            _bHasMoreLogData=NO;
                        }else{
                            //任务数据不足5条数据时 为数据的第一页
                           
                            if (_iCurLogDataIndex==1 ) {
                                //先清除进入页面时初始化的数据
                                [_arrayDataLog removeAllObjects];
                                _arrayDataLog=[arrayLogData mutableCopy];
                                if (_arrayDataLog.count==KPerDataNum) {
                                    _iCurLogDataIndex=2;
                                }else{
                                    _bHasMoreLogData=NO;
                                    _lblLogTbFooter.text=@"已全部加载完毕";
                                }
                            }else{
                                if (arrayLogData.count==KPerDataNum) {
                                    _iCurLogDataIndex++;
                                }else{
                                    _bHasMoreLogData=NO;
                                    _lblLogTbFooter.text=@"已全部加载完毕";
                                }
                                //插入数据
                                for (NSDictionary *dictData in arrayLogData) {
                                    [_arrayDataLog addObject:dictData];
                                }
                                [tbLogView reloadData];
                            }
                        }
                    }
                    _logTbFooterAcIndicator.hidden=YES;
                    [_logTbFooterAcIndicator stopAnimating];
                }else if (iTag==2){
                    //2:任务
                    _lblTaskTbFooter.text=@"滑动加载更多 \u25BE";
                    if (bReturn) {
                        ClassSearchAndMessage *cClassData=[returnArray firstObject];
                        NSArray *arrayTaskData=cClassData.arraySearchData_TaskInfo;
                        if (!arrayTaskData || arrayTaskData.count==0) {
                            _lblTaskTbFooter.text=@"已全部加载完毕";
                            _bHasMoreTaskData=NO;
                        }else{
                            //任务数据不足5条数据时 为数据的第一页
                            if (_iCurTaskDataIndex==1 ) {
                                //先清除进入页面时初始化的数据
                                [_arrayDataTask removeAllObjects];
                                _arrayDataTask=[arrayTaskData mutableCopy];
                                if (arrayTaskData.count==KPerDataNum) {
                                    _iCurTaskDataIndex=2;
                                }else{
                                    _bHasMoreTaskData=NO;
                                    _lblTaskTbFooter.text=@"已全部加载完毕";
                                }
                            }else{
                                if (arrayTaskData.count==KPerDataNum) {
                                    _iCurTaskDataIndex++;
                                }else{
                                    _bHasMoreTaskData=NO;
                                    _lblTaskTbFooter.text=@"已全部加载完毕";
                                }
                                //插入数据
                                for (NSDictionary *dictData in arrayTaskData) {
                                    [_arrayDataTask addObject:dictData];
                                }
                                [tbTaskView reloadData];
                            }
                        }
                    }
                    _taskTbFooterAcIndicator.hidden=YES;
                    [_taskTbFooterAcIndicator stopAnimating];
                }else{
                    //3:文件
                    _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                    if (bReturn) {
                        ClassSearchAndMessage *cClassData=[returnArray firstObject];
                        NSArray *arrayTaskData=cClassData.arraySearchData_FileInfo;
                        if (!arrayTaskData || arrayTaskData.count==0) {
                            _lblFileTbFooter.text=@"已全部加载完毕";
                            _bHasMoreFileData=NO;
                        }else{
                            //任务数据不足5条数据时 为数据的第一页
                            if (_iCurFileDataIndex==1 ) {
                                //先清除进入页面时初始化的数据
                                [_arrayDataFile removeAllObjects];
                                _arrayDataFile=[arrayTaskData mutableCopy];
                                if (arrayTaskData.count==KPerDataNum) {
                                    _iCurFileDataIndex=2;
                                }else{
                                    _bHasMoreFileData=NO;
                                    _lblFileTbFooter.text=@"已全部加载完毕";
                                }
                            }else{
                                if (arrayTaskData.count==KPerDataNum) {
                                    _iCurFileDataIndex++;
                                }else{
                                    _bHasMoreFileData=NO;
                                    _lblFileTbFooter.text=@"已全部加载完毕";
                                }
                                //插入数据
                                for (NSDictionary *dictData in arrayTaskData) {
                                    [_arrayDataFile addObject:dictData];
                                }
                                [tbFileView reloadData];
                            }
                        }
                    }
                    _fileTbFooterAcIndicator.hidden=YES;
                    [_fileTbFooterAcIndicator stopAnimating];
                }
            }
        }
    }];

}


#pragma mark 构建UI信息
- (void)initView{
    _viewControl.hidden=NO;
    _scrolMain.hidden=NO;
    _scrolMain.contentSize=CGSizeMake(_iScrolMainW*3, 0);
    
    //NSInteger iViewTbFooterH=30;
    
    [btnControl_Log setTitle:[NSString stringWithFormat:@"日志(%lu)",(unsigned long)_iDataLogCount] forState:UIControlStateNormal];
    tbLogView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0,_iScrolMainW ,_iScrolMainH)];
    tbLogView.tag=KTbView_Log;
    [_scrolMain addSubview:tbLogView];
    if (_arrayDataLog.count>0) {
        tbLogView.dataSource=self;
        tbLogView.delegate=self;
        tbLogView.rowHeight=KTbCellRowHeight;
        
        NSInteger taskTbFooterLabelW=100;
        UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _iScrolMainW, KViewTbFooterH)];
        
        _lblLogTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, KViewTbFooterH)];
        _lblLogTbFooter.text=@"滑动加载更多 \u25BE";
        _lblLogTbFooter.textAlignment=NSTextAlignmentCenter;
        _lblLogTbFooter.font=[UIFont systemFontOfSize:13];
        _lblLogTbFooter.textColor=[UIColor lightGrayColor];
        [viewTbFooter addSubview:_lblLogTbFooter];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _logTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_logTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _logTbFooterAcIndicator.hidden=YES;
        [viewTbFooter addSubview:_logTbFooterAcIndicator];
        
        tbLogView.tableFooterView=viewTbFooter;
    }else{
        tbLogView.dataSource=nil;
        tbLogView.delegate=nil;
    }
    
    [btnControl_File setTitle:[NSString stringWithFormat:@"文件(%lu)",(unsigned long)_iDataFileCount] forState:UIControlStateNormal];
    tbFileView=[[UITableView alloc] initWithFrame:CGRectMake(_iScrolMainW, 0, _iScrolMainW, _iScrolMainH)];
    tbFileView.tag=KTbView_File;
    [_scrolMain addSubview:tbFileView];
    if (_arrayDataFile.count>0) {
        tbFileView.dataSource=self;
        tbFileView.delegate=self;
        tbFileView.rowHeight=KTbCellRowHeight;
        
        NSInteger taskTbFooterLabelW=100;
        UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _iScrolMainW, KViewTbFooterH)];
        
        _lblFileTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, KViewTbFooterH)];
        _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
        _lblFileTbFooter.textAlignment=NSTextAlignmentCenter;
        _lblFileTbFooter.font=[UIFont systemFontOfSize:13];
        _lblFileTbFooter.textColor=[UIColor lightGrayColor];
        [viewTbFooter addSubview:_lblFileTbFooter];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _fileTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_fileTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _fileTbFooterAcIndicator.hidden=YES;
        [viewTbFooter addSubview:_fileTbFooterAcIndicator];
        
        tbFileView.tableFooterView=viewTbFooter;
    }else{
        tbFileView.dataSource=nil;
        tbFileView.delegate=nil;
    }
    
    [btnControl_Task setTitle:[NSString stringWithFormat:@"任务(%lu)",(unsigned long)_iDataTaskCount] forState:UIControlStateNormal];
    tbTaskView=[[UITableView alloc] initWithFrame:CGRectMake(_iScrolMainW*2, 0, _iScrolMainW, _iScrolMainH)];
    tbTaskView.tag=KTbView_Task;
    [_scrolMain addSubview:tbTaskView];
    if (_arrayDataTask.count>0) {
        tbTaskView.dataSource=self;
        tbTaskView.delegate=self;
        tbTaskView.rowHeight=KTbCellRowHeight;
        
        NSInteger taskTbFooterLabelW=100;
        UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _iScrolMainW, KViewTbFooterH)];
        
        _lblTaskTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, KViewTbFooterH)];
        _lblTaskTbFooter.text=@"滑动加载更多 \u25BE";
        _lblTaskTbFooter.textAlignment=NSTextAlignmentCenter;
        _lblTaskTbFooter.font=[UIFont systemFontOfSize:13];
        _lblTaskTbFooter.textColor=[UIColor lightGrayColor];
        [viewTbFooter addSubview:_lblTaskTbFooter];
        
        NSInteger taskTbFooterAcIndicatorSize=30;
        _taskTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((_iScrolMainW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
        [_taskTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _taskTbFooterAcIndicator.hidden=YES;
        [viewTbFooter addSubview:_taskTbFooterAcIndicator];
        
        tbTaskView.tableFooterView=viewTbFooter;

    }else{
        tbTaskView.dataSource=nil;
        tbTaskView.delegate=nil;
    }
}

#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int iTag;
    //是tableview中的scrol上下滚动
    if ([scrollView isMemberOfClass:[UITableView class]]) {
        
        //要划到底部才加载数据
        CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
        CGFloat contentY=scrollView.contentOffset.y;
        CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
        
        if (distanceFromBottom<=scrolHeight) {
        
            UITableView* fromTableView = (UITableView*)scrollView;
            if (fromTableView.tag==KTbView_Log) {
                if (!_bHasMoreLogData) {
                    return;
                }
                iTag=1;
            }else if (fromTableView.tag==KTbView_File){
                if(!_bHasMoreFileData){
                    return;
                }
                iTag=3;
            }else{
                iTag=2;
                if (!_bHasMoreTaskData){
                    return;
                }
            }
            //加载数据
            [self loadMoreDataWithTag:iTag];
        }
        
        
    }else{
     //本身scrol滚动
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        iTag=offset.x / bounds.size.width;
        
        if (iTag==0) {
            viewControl_LogLine.hidden=NO;
            viewControl_FileLine.hidden=YES;
            viewControl_TaskLine.hidden=YES;
        }else if (iTag==1){
            viewControl_LogLine.hidden=YES;
            viewControl_FileLine.hidden=NO;
            viewControl_TaskLine.hidden=YES;
        }else{
            viewControl_LogLine.hidden=YES;
            viewControl_FileLine.hidden=YES;
            viewControl_TaskLine.hidden=NO;
        }

    }

}


#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger iLeftGap=15;
    NSInteger iIconSize=20;
    
    if (tableView.tag==KTbView_Log) {
        
        NSDictionary *dictData=[_arrayDataLog objectAtIndex:indexPath.row];
        NSString *reuseIdentifier = @"logCell";
        
        UITableViewCell *logCell;
        if (logCell == nil) {
            logCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        //图标
        UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KTbCellRowHeight-iIconSize)/2, iIconSize, iIconSize)];
        imageFileIcon.image=[UIImage imageNamed:@"search_log.png"];
        [logCell.contentView addSubview:imageFileIcon];
        //标题
        UILabel *lblDownloadFileName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize, 0, CGRectGetWidth(tableView.frame)-iLeftGap*2-iIconSize, KTbCellRowHeight)];
        lblDownloadFileName.font=[UIFont systemFontOfSize:15];
        lblDownloadFileName.lineBreakMode =NSLineBreakByTruncatingMiddle;
        [logCell.contentView addSubview:lblDownloadFileName];
        
        //设置关键字红色
        NSString *sSearchKey=_txtSearchKey.text;
        NSString *sTitle=[dictData objectForKey:@"LogTitle"];
        NSMutableAttributedString *sMutTitle = [[NSMutableAttributedString alloc]initWithString:sTitle];
        for (int i=0; i<=sSearchKey.length-1; i++) {
            NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
            NSRange range;
            range = [sTitle rangeOfString:KeyChar];
            [sMutTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
        }
        lblDownloadFileName.attributedText=sMutTitle;
        
        return logCell;
        
    }else if (tableView.tag==KTbView_File){
        
        NSDictionary *dictData=[_arrayDataFile objectAtIndex:indexPath.row];
        NSString *reuseIdentifier = @"fileCell";
        
        UITableViewCell *fileCell;
        if (fileCell == nil) {
            fileCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
       
        //图标
        UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KTbCellRowHeight-iIconSize)/2, iIconSize, iIconSize)];
        imageFileIcon.image=[UIImage imageNamed:@"log_uploadFile_localFile.png"];
        [fileCell.contentView addSubview:imageFileIcon];
        //标题
        UILabel *lblDownloadFileName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize, 0, CGRectGetWidth(tableView.frame)-iLeftGap*2-iIconSize, KTbCellRowHeight)];
        lblDownloadFileName.font=[UIFont systemFontOfSize:15];
        lblDownloadFileName.lineBreakMode =NSLineBreakByTruncatingMiddle;
        [fileCell.contentView addSubview:lblDownloadFileName];
        
        //设置关键字红色
        NSString *sSearchKey=_txtSearchKey.text;
        NSString *sTitle=[dictData objectForKey:@"vchrTitle"];
        NSMutableAttributedString *sMutTitle = [[NSMutableAttributedString alloc]initWithString:sTitle];
        for (int i=0; i<=sSearchKey.length-1; i++) {
            NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
            NSRange range;
            range = [sTitle rangeOfString:KeyChar];
            [sMutTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
        }
        lblDownloadFileName.attributedText=sMutTitle;
        
        return fileCell;

    }else{
        
        NSDictionary *dictData=[_arrayDataTask objectAtIndex:indexPath.row];
        NSString *reuseIdentifier = @"taskCell";
        
        UITableViewCell *taskCell;
        if (taskCell == nil) {
            taskCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        //图标
        UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KTbCellRowHeight-iIconSize)/2, iIconSize, iIconSize)];
        imageFileIcon.image=[UIImage imageNamed:@"search_Task.png"];
        [taskCell.contentView addSubview:imageFileIcon];
        //标题
        UILabel *lblDownloadFileName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize, 0, CGRectGetWidth(tableView.frame)-iLeftGap*2-iIconSize, KTbCellRowHeight)];
        lblDownloadFileName.font=[UIFont systemFontOfSize:15];
        lblDownloadFileName.lineBreakMode =NSLineBreakByTruncatingMiddle;
        [taskCell.contentView addSubview:lblDownloadFileName];
        
        //设置关键字红色
        NSString *sSearchKey=_txtSearchKey.text;
        NSString *sTitle=[dictData objectForKey:@"TaskTitle"];
        NSMutableAttributedString *sMutTitle = [[NSMutableAttributedString alloc]initWithString:sTitle];
        for (int i=0; i<=sSearchKey.length-1; i++) {
            NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
            NSRange range;
            range = [sTitle rangeOfString:KeyChar];
            [sMutTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
        }
        lblDownloadFileName.attributedText=sMutTitle;
        
        return taskCell;
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView.tag==KTbView_Log) {
        return _arrayDataLog.count;
    }else if (tableView.tag==KTbView_File){
        return _arrayDataFile.count;
    }else{
        return _arrayDataTask.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self disKeyboard];
    
    if (tableView.tag==KTbView_Log) {
        //return _arrayDataLog.count;
        
        NSDictionary *dictData=[_arrayDataLog objectAtIndex:indexPath.row];
        
        _viewShowLogInfo=[[UIView alloc] initWithFrame:self.view.frame];
        _viewShowLogInfo.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        [self.view addSubview:_viewShowLogInfo];
        
        //点击空白关闭
        UIButton *bgButton=[[UIButton alloc] initWithFrame:self.view.frame];
        [bgButton addTarget:self action:@selector(hideViewShowLogInfo) forControlEvents:UIControlEventTouchUpInside];
        [_viewShowLogInfo addSubview:bgButton];
        
        NSInteger iViewShowLogInfoH=CGRectGetHeight(_viewShowLogInfo.frame);
        NSInteger iViewShowLogInfoW=CGRectGetWidth(_viewShowLogInfo.frame);
        NSInteger iViewDetailH=250;
        NSInteger iLeftOrRightGap=10;
        
        UIView *viewDetail=[[UIView alloc]  initWithFrame:CGRectMake(iLeftOrRightGap, (iViewShowLogInfoH-iViewDetailH)/2, iViewShowLogInfoW-iLeftOrRightGap*2, iViewDetailH)];
        [_viewShowLogInfo addSubview:viewDetail];

        //title
        NSInteger iLblTitleH=35;
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewDetail.frame), iLblTitleH)];
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.textAlignment=NSTextAlignmentCenter;
        lblTitle.text=[dictData objectForKey:@"LogTitle"];
        lblTitle.font=[UIFont systemFontOfSize:15];
        lblTitle.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
        [viewDetail addSubview:lblTitle];
        
        //backButton
        NSInteger iBtnBackW=35;
        UIButton *btnBack=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iBtnBackW, iBtnBackW)];
        [btnBack setBackgroundImage:[UIImage imageNamed:@"modelViewBack.png"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(hideViewShowLogInfo) forControlEvents:UIControlEventTouchUpInside];
        [viewDetail addSubview:btnBack];
        
        //text
        //设置红色显示
        NSString *sSearchKey=_txtSearchKey.text;
        NSString *sLogContent=[[dictData objectForKey:@"LogContent"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
        NSMutableAttributedString *sMutTitle = [[NSMutableAttributedString alloc]initWithString:sLogContent];
        for (int i=0; i<=sSearchKey.length-1; i++) {
            NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
            NSRange range;
            range = [sLogContent rangeOfString:KeyChar];
            [sMutTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
        }
        UITextView *txtComment=[[UITextView alloc] initWithFrame:CGRectMake(0,iLblTitleH, CGRectGetWidth(viewDetail.frame), CGRectGetHeight(viewDetail.frame)-iLblTitleH)];
        txtComment.textColor=[UIColor darkGrayColor];
        txtComment.attributedText=sMutTitle;
        txtComment.font=[UIFont systemFontOfSize:15];
        txtComment.editable=NO;
        txtComment.backgroundColor=[UIColor whiteColor];
        [viewDetail addSubview:txtComment];

    }else if (tableView.tag==KTbView_File){
        
         NSDictionary *dictData=[_arrayDataFile objectAtIndex:indexPath.row];
        NSString *sFileUrl=[dictData objectForKey:@"vchrURL"];
        
        UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *reViewAction = [UIAlertAction actionWithTitle:@"在线预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //浏览相片
            if ([[self getFileIconWithName:[dictData objectForKey:@"vchrTitle"]] isEqualToString:@"img.png"]) {
                [ClassLog imagePreviewWithStrUrl:sFileUrl fatherObject:self returnBlock:^(BOOL bReturn, NSDictionary *returnDictionary) {
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
                NSString *sUrl=[NSString stringWithFormat:@"http://officeweb365.com/o/?i=5510&furl=http://file.ttbrz.cn%@",sFileUrl];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
            
            }
            
        }];
        UIAlertAction *downFileAction = [UIAlertAction actionWithTitle:@"下载文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //后台下载文件
            [self downFileWithFilePath:sFileUrl];
            
        }];
        
        [alertSelect addAction:cancelAction];
        [alertSelect addAction:reViewAction];
        [alertSelect addAction:downFileAction];
        
        [self presentViewController:alertSelect animated:YES completion:nil];
       
    }else{
        NSDictionary *dictData=[_arrayDataTask objectAtIndex:indexPath.row];
        [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:[dictData objectForKey:@"TaskID"] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                UIViewControllerPlanTask *planTaskView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerPlanTask"];
                planTaskView.cGetDetailPlanTaskData=[returnArray firstObject];
                planTaskView.sGetSearchKey=_txtSearchKey.text;
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                [self.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:planTaskView animated:YES];
            }
        }];
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

//根据文件名称获取图片名
-(NSString*)getFileIconWithName:(NSString*)sName{
    
    NSString *sExtension=[sName pathExtension];
    
    if ([sExtension isEqualToString:@"jpg"] || [sExtension isEqualToString:@"jpeg"] || [sExtension isEqualToString:@"png"]) {
        return @"img.png";
    }else if ([sExtension isEqualToString:@"doc"] || [sExtension isEqualToString:@"docx"]){
        return @"docx.png";
    }else if ([sExtension isEqualToString:@"xls"] || [sExtension isEqualToString:@"xlsx"]){
        return @"xls.png";
    }else if ([sExtension isEqualToString:@"ppt"] || [sExtension isEqualToString:@"pptx"]){
        return @"ppt.png";
    }else if ([sExtension isEqualToString:@"zip"] || [sExtension isEqualToString:@"rar"]){
        return @"zip.png";
    }else{
        return @"txt.png";
    }
}

#pragma mark 关闭浏览图片
- (void)hideViewShowImage{
    [_viewShowImage removeFromSuperview];
}

#pragma mark 关闭浏览日志信息
- (void)hideViewShowLogInfo{
    [_viewShowLogInfo removeFromSuperview];
}

@end
