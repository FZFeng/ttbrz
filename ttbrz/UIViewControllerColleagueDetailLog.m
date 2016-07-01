//
//  UIViewControllerColleagueDetailLog.m
//  ttbrz
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerColleagueDetailLog.h"

#define KPerDataNum        5

#define KAccessoryImage    201
#define KAccessoryFile     202

@interface UIViewControllerColleagueDetailLog (){

    IBOutlet UIView *titleDateView;
    IBOutlet UIButton *_titleDateButton;
    IBOutlet UIButton *_btnSelectOtherMember;
    FZRefreshTableView *_logTableView;
    
    NSString *_sCurDate;

    
    // 上,下拉时显示的数据
    NSMutableArray *_arryMoreData;
    UIButton *_titleButton;
    float _fTaskRowCellH;
    float _fLogRowCellH;
    NSInteger iViewW;
    BOOL _bHasLoad;
    
    UIView *_viewShowLogInfo;
    UIView *_viewShowImage;
    
    UILabel *_lblTitle;
    
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_sCurDownloadFilePath;
}

@end

@implementation UIViewControllerColleagueDetailLog

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    iViewW=CGRectGetWidth(self.view.frame);
    
    _lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    _lblTitle.text=[NSString stringWithFormat:@"%@工作日志",self.sGetSelectedMemberName];
    _lblTitle.textAlignment=NSTextAlignmentCenter;
    _lblTitle.textColor=[UIColor whiteColor];
    _lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=_lblTitle;
    
    [_btnSelectOtherMember setTitle:@"其它人员 \u25BE" forState:UIControlStateNormal];
    
    [self getTodayDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    if (_bHasLoad==NO) {
        _bHasLoad=YES;
        NSInteger iTabBarHeight=64;
        _logTableView = [[FZRefreshTableView  alloc] initWithFrame:CGRectMake(0, iTabBarHeight+CGRectGetHeight(titleDateView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(titleDateView.frame)-iTabBarHeight) pullingDelegate:self UITableViewStyle:UITableViewStylePlain];
        _logTableView.delegate=self;
        _logTableView.dataSource=self;
        _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_logTableView];
        
        //注册cell
        UINib *nibLogCell=[UINib nibWithNibName:@"TbCellLog" bundle:nil];
        [_logTableView registerNib:nibLogCell forCellReuseIdentifier:@"TbCellLog"];
        
        TbCellLog*logCell=[_logTableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
        _fLogRowCellH=CGRectGetHeight(logCell.frame);

    }
    
}

#pragma mark 获取今天日期
- (NSString*)getTodayDate{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy年M月"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    [_titleDateButton setTitle:[dateString stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _sCurDate=[dateFormatter stringFromDate:nowDate];
    return [dateFormatter stringFromDate:nowDate];
}

#pragma mark 选择日期
- (IBAction)didTitleDate:(id)sender {
    FZDatePickerView *datePickerView=[[FZDatePickerView alloc] initWithReferView:self.view];
    datePickerView.delegate=self;
    [datePickerView show];
}

#pragma mark 获取日志数据
- (void)initLogData{
    
    //清空两数据
    [_arryMoreData removeAllObjects];
    [self.arrayGetLogData removeAllObjects];

    [ClassLog getLogDataWithDate:_sCurDate dayNum:KPerDataNum iType:-1 userID:self.sGetSelectedMemberID companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            self.arrayGetLogData=[returnArray mutableCopy];
            [_logTableView reloadData];
            [_logTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }];
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    [_titleDateButton setTitle:[psReturnDate stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    _sCurDate=displayDate;
    [self initLogData];

}

# pragma mark 其它人员
- (IBAction)didBtnSelectOtherMember:(id)sender {
    
    if (!self.arrayMemberData || self.arrayMemberData.count==1) {
        [PublicFunc ShowNoticeHUD:@"该部门下没有其它人员" view:self.view];
        return;
    }
    
    ViewControllerMember *memberView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerMember"];
    memberView.arrayMemberData=self.arrayMemberData;
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:memberView animated:YES];
}

# pragma mark 获取选中同事(编号,姓名)
- (void)selectedMemberID:(NSString*)sMemberID sMemberName:(NSString*)sMemberName{
    self.sGetSelectedMemberID=sMemberID;
    _lblTitle.text=[NSString stringWithFormat:@"%@工作日志",sMemberName];
    [self initLogData];

}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayGetLogData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassLog *cLogObject=[self.arrayGetLogData objectAtIndex:indexPath.row];
    TbCellLog*logCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellLog"];
    logCell.bColleagueLog=YES;
    logCell.cLogObject=cLogObject;
    [logCell initData];
    logCell.delegate=self;
    [logCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return logCell;

}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellRowHeight=0;
    NSInteger detailControlHeight=30;
    NSInteger lineHeight=2;
    NSInteger logTbCellDetailViewWidth;
    
    ClassLog *cLogObject=[self.arrayGetLogData objectAtIndex:indexPath.row];
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
        if (cellRowHeight<=CGRectGetHeight(logCell.logTbCellDetailView.frame)) {
            cellRowHeight=_fLogRowCellH;
        }else{
            cellRowHeight=cellRowHeight+(_fLogRowCellH-CGRectGetHeight(logCell.logTbCellDetailView.frame));
        }
    }else{
        cellRowHeight=_fLogRowCellH;
    }
    return cellRowHeight;
}

#pragma mark FZRefreshTableViewDelegate回调
// 加载数据中
- (void) addDataing
{
    //从第 1 行开始 因为获取的数据中包含此行数据
    for (int x = 1; x < [_arryMoreData count]; x++)
    {
        [self.arrayGetLogData addObject:[_arryMoreData objectAtIndex:x]];
    }
}

- (void) insertDataing
{
    //先删除最后一行 因为获取的数据中包含此行数据
    [self.arrayGetLogData removeObjectAtIndex:0];
    for (int x = 0; x < [_arryMoreData count]; x++)
    {
        [self.arrayGetLogData insertObject:[_arryMoreData objectAtIndex:x] atIndex:0];
    }
}

-(void)pullingDownRefreshing:(refreshingReBlock)pBlock{
    //获取最近一次的最前一条记录的更新日期
    
    ClassLog *cLogObject=[self.arrayGetLogData firstObject];
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
    ClassLog *cLogObject=[self.arrayGetLogData lastObject];
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
    [_logTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_logTableView tableViewDidEndDragging:scrollView];
}

#pragma mark TbCellLogDelegate 回调
- (void)didTbCellButtonDelegate:(id)sender curLogData:(ClassLog *)curLogData  returnType:(TbCellLogDelegateType)returnType{
    
    if (returnType==TbCellLogDelegateTypeFileEdit){
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
                NSString *sUrl=[NSString stringWithFormat:@"http://officeweb365.com/o/?i=5510&furl=http://file.ttbrz.cn%@",btnObj.accessibilityLabel];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
                
            }
            
            
        }];
        UIAlertAction *downFileAction = [UIAlertAction actionWithTitle:@"下载文件" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //后台下载文件
            UIButton *btnObj=sender;
            [self downFileWithFilePath:btnObj.accessibilityLabel];
            
        }];
        
        [alertSelect addAction:cancelAction];
        [alertSelect addAction:reViewAction];
        [alertSelect addAction:downFileAction];
        
        [self presentViewController:alertSelect animated:YES completion:nil];
        
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

@end
