//
//  UIViewControllerTeamLog.m
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTeamLog.h"

#define KScrolWeekDateH 45
#define KPerDataNum        5
#define KScrollTagDate  101
#define KScrollTaglog  102

#define KAccessoryImage  201
#define KAccessoryFile   202

@interface UIViewControllerTeamLog (){

    IBOutlet UIButton *_titleDepartmentButton;
    IBOutlet UIButton *_titleDateButton;
    IBOutlet UIScrollView *_scrolWeekDate;
    IBOutlet UITableView *_tbTeamLogView;
    
    NSString *_sCurDepartmentID;
    NSString *_sCurDate;
    
    NSMutableArray *_arrayTeamLogData;
    NSInteger _iCurLogDataIndex;//当前数据的页数
    UILabel *_tbFooterLabel;
    float _fTeamLogRowCellH;
    BOOL _bHasMoreData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_tbFooterAcIndicator;//加载等待

    NSInteger _iViewW;

    float startContentOffsetX;
    float  willEndContentOffsetX;
    float  endContentOffsetX;
    
    UIView *_viewShowLogInfo;
    UIView *_viewShowImage;
    
    NSURLSessionDownloadTask *_downloadTask;
    NSString *_sCurDownloadFilePath;

}

@end

@implementation UIViewControllerTeamLog

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_TeamLog];
    
    _titleDepartmentButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    
    _sCurDepartmentID=[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDepartmentId"];
    if (_sCurDepartmentID) {
        [_titleDepartmentButton setTitle:[NSString stringWithFormat:@"%@ \u25BE",[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDepartmentName"]] forState:UIControlStateNormal];
    }else{
        [_titleDepartmentButton setTitle:@"选部门 \u25BE" forState:UIControlStateNormal];
    }
    
    
    _iViewW=CGRectGetWidth(self.view.frame);
    
    _scrolWeekDate.bounces=NO;
    _scrolWeekDate.delegate=self;
    _scrolWeekDate.scrollEnabled=YES;
    _scrolWeekDate.pagingEnabled=YES;
    _scrolWeekDate.showsHorizontalScrollIndicator=NO;
    _scrolWeekDate.showsVerticalScrollIndicator=NO;
    _scrolWeekDate.tag=KScrollTagDate;

   [self getTodayDate];
    
    //第一页数据
    _iCurLogDataIndex=1;
    
    //可以加载更多数据
    _bHasMoreData=YES;
    
    //一周日期
    [self initWeekDateWithDate:_sCurDate];
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTeamLog" bundle:nil];
    [_tbTeamLogView registerNib:nibCell forCellReuseIdentifier:@"TbCellTeamLog"];
    
    TbCellTeamLog*teamLogCell=[_tbTeamLogView dequeueReusableCellWithIdentifier:@"TbCellTeamLog"];
    _fTeamLogRowCellH=CGRectGetHeight(teamLogCell.frame);

    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载数据
- (void)loadingData{
    
    NSString *sUserID=[SystemPlist GetUserID];
    //公司级别的选数据 departmentid,userid都为空
    if ([_sCurDepartmentID isEqualToString:@""]) {
        sUserID=@"";
    }

    [ClassLog getTeamLogDataWithID:sUserID companyID:[SystemPlist GetCompanyID] pageIndex:_iCurLogDataIndex rows:KPerDataNum sDate:_sCurDate sDeptID:_sCurDepartmentID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                //得到任务数据
                _arrayTeamLogData=[returnArray mutableCopy];
            }else{
                _arrayTeamLogData=[[NSMutableArray alloc] init];
            }
            
            //任务数据不足5条数据时 为数据的第一页
            if (_arrayTeamLogData.count<KPerDataNum) {
                _iCurLogDataIndex=1;
            }else{
                _iCurLogDataIndex=2;
            }

            
            _tbTeamLogView.delegate=self;
            _tbTeamLogView.dataSource=self;
            
            [self refreshTaskTable];
            [_tbTeamLogView reloadData];

        }
    }];

}

#pragma mark 操作后刷新tableview
-(void)refreshTaskTable{
    
     NSInteger iViewW=CGRectGetWidth(self.view.frame);
    
    if (!_arrayTeamLogData || _arrayTeamLogData.count==0) {
        UILabel *notTaskLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iViewW, 35)];
        notTaskLabel.text=@"该部门今天没有日志";
        notTaskLabel.numberOfLines=0;
        notTaskLabel.textAlignment=NSTextAlignmentCenter;
        notTaskLabel.font=[UIFont systemFontOfSize:14];
        notTaskLabel.textColor=[UIColor lightGrayColor];
        
        _tbTeamLogView.tableFooterView=notTaskLabel;
        _tbTeamLogView.dataSource=nil;
        _tbTeamLogView.scrollEnabled=NO;
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
        
        _tbTeamLogView.tableFooterView=taskTbFooterView;
        _tbTeamLogView.dataSource=self;
        _tbTeamLogView.scrollEnabled=YES;
    }
    [_tbTeamLogView reloadData];
}

#pragma mark 初始化指定日期本周及前一周的日期
- (void)initWeekDateWithDate:(NSString*)sDate{
    
    NSArray *arryWeekDate;
   
    //新除旧数据
    for (UIView *subView in  _scrolWeekDate.subviews) {
        [subView removeFromSuperview];
    }
    //前一周
    NSDate *theDate=[self returnDiffDate:-7 theDay:[PublicFunc dateFromString:sDate dateFormatterType:DateFromStringTypeYMD]];
    arryWeekDate=[self aWeekDateWithDate:theDate];
    
    float iBtnWeekDateW;
    iBtnWeekDateW=_iViewW*1.0/arryWeekDate.count;
    
    for (int i=0; i<=arryWeekDate.count-1; i++) {
        NSString *sCurWeekDate=[[arryWeekDate objectAtIndex:i] firstObject];
        NSString *sCurWeekDateValue=[[arryWeekDate objectAtIndex:i] lastObject];
        UIButton *btnWeekDate=[[UIButton alloc] initWithFrame:CGRectMake(iBtnWeekDateW*i, 0, iBtnWeekDateW, KScrolWeekDateH)];
        [btnWeekDate setTitle:sCurWeekDate forState:UIControlStateNormal];
        [btnWeekDate addTarget:self action:@selector(didBtnWeekDate:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([sCurWeekDateValue isEqualToString:[PublicFunc stringFromDate:theDate dateFormatterType:DateFromStringTypeYMD]]) {
            [btnWeekDate setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btnWeekDate setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        btnWeekDate.accessibilityLabel=sCurWeekDateValue;
        btnWeekDate.titleLabel.font=[UIFont systemFontOfSize:12];
        [_scrolWeekDate addSubview:btnWeekDate];
    }
    
    //当前的一周
    arryWeekDate=[self aWeekDateWithDate:[PublicFunc dateFromString:sDate dateFormatterType:DateFromStringTypeYMD]];
    for (int i=0; i<=arryWeekDate.count-1; i++) {
        NSString *sCurWeekDate=[[arryWeekDate objectAtIndex:i] firstObject];
        NSString *sCurWeekDateValue=[[arryWeekDate objectAtIndex:i] lastObject];
        UIButton *btnWeekDate=[[UIButton alloc] initWithFrame:CGRectMake(iBtnWeekDateW*i+_iViewW, 0, iBtnWeekDateW, KScrolWeekDateH)];
        [btnWeekDate setTitle:sCurWeekDate forState:UIControlStateNormal];
        [btnWeekDate addTarget:self action:@selector(didBtnWeekDate:) forControlEvents:UIControlEventTouchUpInside];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if ([sCurWeekDateValue isEqualToString:sDate]) {
            [btnWeekDate setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [btnWeekDate setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        btnWeekDate.accessibilityLabel=sCurWeekDateValue;
        btnWeekDate.titleLabel.font=[UIFont systemFontOfSize:12];
        [_scrolWeekDate addSubview:btnWeekDate];
    }
    
    if ([sDate isEqualToString:[PublicFunc stringFromDate:[NSDate date] dateFormatterType:DateFromStringTypeYMD]]) {
         //如果是当天时间就生成当前一周和前一周日期 并显示当前一周
        _scrolWeekDate.contentOffset=CGPointMake(_iViewW, 0);
        _scrolWeekDate.contentSize=CGSizeMake(_iViewW*2, 0);
        
    }else{
         //如果不是当天时间 就生成 前一周 当前一周 后一周 并显示当前一周
        _scrolWeekDate.contentOffset=CGPointMake(_iViewW, 0);
        _scrolWeekDate.contentSize=CGSizeMake(_iViewW*3, 0);
        
         //上一周
        theDate=[self returnDiffDate:7 theDay:[PublicFunc dateFromString:sDate dateFormatterType:DateFromStringTypeYMD]];
        arryWeekDate=[self aWeekDateWithDate:theDate];
        
        for (int i=0; i<=arryWeekDate.count-1; i++) {
            NSString *sCurWeekDate=[[arryWeekDate objectAtIndex:i] firstObject];
            NSString *sCurWeekDateValue=[[arryWeekDate objectAtIndex:i] lastObject];
            UIButton *btnWeekDate=[[UIButton alloc] initWithFrame:CGRectMake(iBtnWeekDateW*i+_iViewW*2, 0, iBtnWeekDateW, KScrolWeekDateH)];
            [btnWeekDate setTitle:sCurWeekDate forState:UIControlStateNormal];
            [btnWeekDate addTarget:self action:@selector(didBtnWeekDate:) forControlEvents:UIControlEventTouchUpInside];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            if ([sCurWeekDateValue isEqualToString:[PublicFunc stringFromDate:theDate dateFormatterType:DateFromStringTypeYMD]]) {
                [btnWeekDate setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else{
                [btnWeekDate setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            btnWeekDate.accessibilityLabel=sCurWeekDateValue;
            btnWeekDate.titleLabel.font=[UIFont systemFontOfSize:12];
            [_scrolWeekDate addSubview:btnWeekDate];
        }
    }
}

//获取几天后的日期
- (NSDate*)returnDiffDate:(NSInteger)iDay theDay:(NSDate*)theDay{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    //设置时间
    [offsetComponents setDay:iDay];
    //设置最大值时间
    NSDate *returnDate = [gregorian dateByAddingComponents:offsetComponents toDate:theDay options:0];

    return returnDate;
}

#pragma mark 选中一周中的某一天
- (void)didBtnWeekDate:(id)sender{
    
     UIButton *btnObj=sender;
    _sCurDate=btnObj.accessibilityLabel;
    
    for (UIView *subView in _scrolWeekDate.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            if ([((UIButton*)subView).accessibilityLabel isEqualToString:_sCurDate]) {
                [((UIButton*)subView) setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else{
                [((UIButton*)subView) setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
    }
    
    _iCurLogDataIndex=1;
    _bHasMoreData=YES;
    [_arrayTeamLogData removeAllObjects];
    [self loadingData];
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

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    [_titleDateButton setTitle:[psReturnDate stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    _sCurDate=displayDate;
    [self initWeekDateWithDate:_sCurDate];
    //刷新数据
    _iCurLogDataIndex=1;
    _bHasMoreData=YES;
    [_arrayTeamLogData removeAllObjects];
    [self loadingData];
}

#pragma mark 返回指定日期一周的日期
- (NSArray*)aWeekDateWithDate:(NSDate*)date{
    
    NSMutableArray *dateMutableArrary=[[NSMutableArray alloc] init];
    NSMutableArray *dateStringMutableArrary=[[NSMutableArray alloc] init];
    NSMutableArray *resultMutableArrary=[[NSMutableArray alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    
    NSInteger daycount = [comp weekday];
    
    
    for (NSInteger i=1; i<=7; i++) {
        NSDate *currentDate;
        if (i<=daycount) {
            currentDate=[date dateByAddingTimeInterval:-(daycount-i)*60*60*24];
        }else{
            currentDate=[date dateByAddingTimeInterval:(i-daycount)*60*60*24];
        }
        [dateMutableArrary addObject:currentDate];
    }
    
    NSString *weekString=@"";
    for (NSInteger i=0;i<=dateMutableArrary.count-1;i++){
        
        NSCalendar *mycal = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar]
        ;
        unsigned units = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
        comp =[mycal components:units fromDate:[dateMutableArrary objectAtIndex:i]];
        NSInteger day = [comp day];
        
        
        switch (i) {
            case 0:{
                weekString=@"周日";
                break;
            }case 1:{
                weekString=@"周一";
                break;
            }case 2:{
                weekString=@"周二";
                break;
            }case 3:{
                weekString=@"周三";
                break;
            }case 4:{
                weekString=@"周四";
                break;
            }case 5:{
                weekString=@"周五";
                break;
            }case 6:{
                weekString=@"周六";
                break;
            }
        }
        
        weekString=[NSString stringWithFormat:@"%@ %ld",weekString,(long)day];
        [dateStringMutableArrary addObject:weekString];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd"];
        
        
        NSArray *currentDate=[[NSArray alloc] initWithObjects:weekString,[formater stringFromDate:[dateMutableArrary objectAtIndex:i]], nil];
        [resultMutableArrary addObject:currentDate];
    }
    
    return resultMutableArrary;
}

#pragma mark 选择部门
- (IBAction)didSelectDepartment:(id)sender {
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
    
    [ClassLog getDepartmentDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strType:@"2" fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            ViewControllerDepartment *departmentView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewDepartment"];
            departmentView.arryDepartment=returnArray;
            [self.navigationController pushViewController:departmentView animated:YES];
        }
    }];
}

//获取选中部门编号
- (void)selectedDepartmentID:(NSString*)sDepartmentID sDepartmentName:(NSString*)sDepartmentName{
    
    [_titleDepartmentButton setTitle:[NSString stringWithFormat:@"%@ \u25BE",sDepartmentName] forState:UIControlStateNormal];
    //刷新数据
    _bHasMoreData=YES;
    _iCurLogDataIndex=1;
    _sCurDepartmentID=sDepartmentID;
    [_arrayTeamLogData removeAllObjects];
    [self loadingData];
}

#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayTeamLogData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassLog *cLogObject=[_arrayTeamLogData objectAtIndex:indexPath.row];
    TbCellTeamLog *teamLogCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTeamLog"];
    teamLogCell.delegate=self;
    teamLogCell.cLogObject=cLogObject;
    [teamLogCell initData];
    //teamLogCell.delegate=self;
    [teamLogCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return teamLogCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellRowHeight=0;
    NSInteger detailControlHeight=30;
    NSInteger lineHeight=2;
    NSInteger logTbCellDetailViewWidth;
    
    ClassLog *cLogObject=[_arrayTeamLogData objectAtIndex:indexPath.row];
    //只创建一个cell用作测量高度
    static TbCellTeamLog *teamLogCell = nil;
    if (!teamLogCell)
        teamLogCell = [_tbTeamLogView dequeueReusableCellWithIdentifier:@"TbCellTeamLog"];
    logTbCellDetailViewWidth=CGRectGetWidth(teamLogCell.viewTeamLogDetail.frame);
    
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
    
    if (cellRowHeight<=CGRectGetHeight(teamLogCell.viewTeamLogDetail.frame)) {
        cellRowHeight=_fTeamLogRowCellH;
    }else{
        cellRowHeight=cellRowHeight+(_fTeamLogRowCellH-CGRectGetHeight(teamLogCell.viewTeamLogDetail.frame));
    }
    
    return cellRowHeight;
}

#pragma mark TbCellTeamLogDelegate
- (void)didTbCellButtonDelegate:(id)sender curLogData:(ClassLog *)curLogData{
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

//将要开始拖拽，手指已经放在view上并准备拖动的那一刻
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{    //拖动前的起始坐标
    
    startContentOffsetX = scrollView.contentOffset.x;
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{    //将要停止前的坐标
    
    willEndContentOffsetX = scrollView.contentOffset.x;
    
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.tag==KScrollTagDate) {
        endContentOffsetX = scrollView.contentOffset.x;
        if (endContentOffsetX < willEndContentOffsetX && willEndContentOffsetX < startContentOffsetX) {
            //向右划动
            NSDate *theDate=[self returnDiffDate:-7 theDay:[PublicFunc dateFromString:_sCurDate dateFormatterType:DateFromStringTypeYMD]];
            _sCurDate=[PublicFunc stringFromDate:theDate dateFormatterType:DateFromStringTypeYMD];
           
        } else if (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX) {
            //向左划动
            NSDate *theDate=[self returnDiffDate:7 theDay:[PublicFunc dateFromString:_sCurDate dateFormatterType:DateFromStringTypeYMD]];
            _sCurDate=[PublicFunc stringFromDate:theDate dateFormatterType:DateFromStringTypeYMD];
        }else{
            return;
        }
        
        //刷新数据
        [self initWeekDateWithDate:_sCurDate];
        
        NSDate *curDate = [PublicFunc dateFromString:_sCurDate dateFormatterType:DateFromStringTypeYMD];
        NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
        [pickerFormatter setDateFormat:@"yyyy年M月"];
        NSString *dateString = [pickerFormatter stringFromDate:curDate];

        [_titleDateButton setTitle:[dateString stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
        [self initWeekDateWithDate:_sCurDate];
        //刷新数据
        _iCurLogDataIndex=1;
        _bHasMoreData=YES;
        [_arrayTeamLogData removeAllObjects];
        [self loadingData];

        
    }else{
    
        if (!_bHasMoreData) {
            return;
        }
        //获取任务数据
        _tbFooterLabel.text=@"正在加载中...";
        _tbFooterAcIndicator.hidden=NO;
        [_tbFooterAcIndicator startAnimating];
        
        NSString *sUserID=[SystemPlist GetUserID];
        //公司级别的选数据 departmentid,userid都为空
        if ([_sCurDepartmentID isEqualToString:@""]) {
            sUserID=@"";
        }
        
        [ClassLog getTeamLogMoreDataWithID:sUserID companyID:[SystemPlist GetCompanyID] pageIndex:_iCurLogDataIndex rows:KPerDataNum sDate:_sCurDate sDeptID:_sCurDepartmentID  returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            _tbFooterLabel.text=@"滑动加载更多 \u25BE";
            if (bReturn) {
                if (!returnArray || returnArray.count==0) {
                    _tbFooterLabel.text=@"已全部加载完毕";
                }else{
                    //任务数据不足5条数据时 为数据的第一页
                    if (_iCurLogDataIndex==1 ) {
                        //先清除进入页面时初始化的数据
                        [_arrayTeamLogData removeAllObjects];
                        _arrayTeamLogData=[returnArray mutableCopy];
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
                            [_arrayTeamLogData addObject:dictData];
                        }
                        [_tbTeamLogView reloadData];
                    }
                }
            }
            _tbFooterAcIndicator.hidden=YES;
            [_tbFooterAcIndicator stopAnimating];
        }];
    }
    
    
}
@end
