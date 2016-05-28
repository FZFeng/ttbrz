//
//  UIViewControllerTeamIntegral.m
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTeamIntegral.h"
#define KPerDataNum        5

@interface UIViewControllerTeamIntegral ()<FZDatePickerViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{


    IBOutlet UIButton *_titleDateButton;
    IBOutlet UITableView *_tbView;
    IBOutlet UIButton *_titleDepartmentButton;

    IBOutlet UIView *_titleDateView;
    NSString *_sCurDepartmentID;
    NSString *_sCurDate;
    
    UILabel *_lblFileTbFooter;
    NSInteger _iCurFileDataIndex;//当前数据的页数
    BOOL _bHasMoreFileData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_fileTbFooterAcIndicator;//加载等待
    
    NSMutableArray *_arrayData;
}

@end

@implementation UIViewControllerTeamIntegral

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super initNavigationWithTabBarIndex:KTabBarIndexIntegral menuItemTitle:KTitleIntegral_TeamIntegral];
    _titleDateView.hidden=YES;
    _titleDepartmentButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTeamIntegral" bundle:nil];
    [_tbView registerNib:nibCell forCellReuseIdentifier:@"TbCellTeamIntegral"];
    
    TbCellTeamIntegral *cCell=[_tbView dequeueReusableCellWithIdentifier:@"TbCellTeamIntegral"];
    _tbView.rowHeight=CGRectGetHeight(cCell.frame);
    
    _bHasMoreFileData=YES;
    
    //去掉左边的空白
    if ([_tbView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tbView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([_tbView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tbView setSeparatorInset:UIEdgeInsetsZero];
    }
    
     _tbView.separatorStyle=UITableViewCellSeparatorStyleNone;//不显示分割线
    
    //等待加载数据
    [self performSelector:@selector(initData) withObject:self afterDelay:0.1];

}
- (void)initData{
    //今天日期
    _sCurDate=[self getTodayDate];
    
    _sCurDepartmentID=[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDepartmentId"];
    if (_sCurDepartmentID) {
        [_titleDepartmentButton setTitle:[NSString stringWithFormat:@"%@ \u25BE",[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDepartmentName"]] forState:UIControlStateNormal];
    }else{
        [_titleDepartmentButton setTitle:@"选部门 \u25BE" forState:UIControlStateNormal];
    }
    [self loadingDataWithDate:_sCurDate departID:_sCurDepartmentID];
}

- (void)loadingDataWithDate:(NSString*)sDate departID:(NSString*)departID{

    [ClassIntegral getGroupScoreDataWithDeptID:departID PageIndex:_iCurFileDataIndex PageSize:KPerDataNum Begin:sDate CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            _bHasMoreFileData=YES;
            _titleDateView.hidden=NO;
            _tbView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;//不显示分割线
            
            NSInteger taskTbFooterLabelW=100;
            NSInteger iViewTbFooterH=30;
            NSInteger iViewW=CGRectGetWidth(self.view.frame);
            UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iViewW, iViewTbFooterH)];
            
            _lblFileTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, iViewTbFooterH)];
            _lblFileTbFooter.textAlignment=NSTextAlignmentCenter;
            _lblFileTbFooter.font=[UIFont systemFontOfSize:13];
            _lblFileTbFooter.textColor=[UIColor lightGrayColor];
            [viewTbFooter addSubview:_lblFileTbFooter];
            
            NSInteger taskTbFooterAcIndicatorSize=30;
            _fileTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
            [_fileTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            _fileTbFooterAcIndicator.hidden=YES;
            [viewTbFooter addSubview:_fileTbFooterAcIndicator];
            
            
            if (returnArray.count>0) {
                _arrayData=[returnArray mutableCopy];
                _tbView.scrollEnabled=YES;
                _tbView.dataSource=self;
                _tbView.delegate=self;
                
                _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                
            }else{
                _tbView.scrollEnabled=NO;
                _tbView.dataSource=nil;
                _tbView.delegate=nil;
                
                _lblFileTbFooter.text=@"暂无数据";
            }
            
            _tbView.tableFooterView=viewTbFooter;
            [_tbView reloadData];
            
            if (returnArray.count==KPerDataNum) {
                _iCurFileDataIndex=2;
            }else{
                _iCurFileDataIndex=1;
            }
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
        
        [ClassIntegral getGroupScoreDataNoHUDWithDeptID:_sCurDepartmentID PageIndex:_iCurFileDataIndex PageSize:KPerDataNum Begin:_sCurDate CompanyID:[SystemPlist GetCompanyID] returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        _lblFileTbFooter.text=@"已全部加载完毕";
                        _bHasMoreFileData=NO;
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if (_iCurFileDataIndex==1 ) {
                            //先清除进入页面时初始化的数据
                            [_arrayData removeAllObjects];
                            
                            _arrayData=[returnArray mutableCopy];
                            if (returnArray.count==KPerDataNum) {
                                _iCurFileDataIndex=2;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                        }else{
                            if (returnArray.count==KPerDataNum) {
                                _iCurFileDataIndex++;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                            //插入数据
                            for (NSDictionary *dictData in returnArray) {
                                [_arrayData addObject:dictData];
                            }
                            [_tbView reloadData];
                        }
                    }
                }
                _fileTbFooterAcIndicator.hidden=YES;
                [_fileTbFooterAcIndicator stopAnimating];
            }
        }];
    
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    datePickerView.bOnlyDisplayYearAndMonth=YES;
    datePickerView.delegate=self;
    [datePickerView show];
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    [_titleDateButton setTitle:[psReturnDate stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    _bHasMoreFileData=YES;
    _iCurFileDataIndex=1;
    _sCurDate=psReturnDate;
    [_arrayData removeAllObjects];
    [self loadingDataWithDate:_sCurDate departID:_sCurDepartmentID];

}

#pragma mark 选择部门
- (IBAction)didSelectDepartment:(id)sender {
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
    
    [ClassLog getDepartmentDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strType:@"2" fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            ViewControllerDepartment *departmentView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewDepartment"];
            departmentView.arryDepartment=returnArray;
            departmentView.sFromUIViewId=@"UIViewControllerTeamIntegral";
            [self.navigationController pushViewController:departmentView animated:YES];
        }
    }];
}

//获取选中部门编号
- (void)selectedDepartmentID:(NSString*)sDepartmentID sDepartmentName:(NSString*)sDepartmentName{
    
    [_titleDepartmentButton setTitle:[NSString stringWithFormat:@"%@ \u25BE",sDepartmentName] forState:UIControlStateNormal];
    //刷新数据
    _bHasMoreFileData=YES;
    _iCurFileDataIndex=1;
    _sCurDepartmentID=sDepartmentID;
    [_arrayData removeAllObjects];
    [self loadingDataWithDate:_sCurDate departID:_sCurDepartmentID];
}


#pragma mark UITableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassIntegral *cClassData=[_arrayData objectAtIndex:indexPath.row];
    TbCellTeamIntegral *cCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTeamIntegral"];
    //日期
    cCell.lblDepartment.text=cClassData.sDeptName;
    cCell.lblUserName.text=cClassData.sUserName;
    cCell.lblScore.text=[NSString stringWithFormat:@"%1.1f分",[cClassData.smaxScore floatValue]];
    cCell.lblLevel.text=[NSString stringWithFormat:@"%ld",(long)[cClassData.sCTop integerValue]];
    
    [cCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrayData count];
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
