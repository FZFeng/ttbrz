//
//  UIViewControllerMyIntegral.m
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMyIntegral.h"

@interface UIViewControllerMyIntegral ()<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UILabel *_lblScore;
    IBOutlet UIButton *_titleDateButton;
    IBOutlet UITableView *_tbView;
    
    IBOutlet UIView *_titleDateView;
    
    NSArray *_arrayData;
    NSInteger _iTotalScore;
}

@end

@implementation UIViewControllerMyIntegral

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [super initNavigationWithTabBarIndex:KTabBarIndexIntegral menuItemTitle:KTitleIntegral_MyIntegral];
    
    _titleDateView.hidden=YES;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellIntegral" bundle:nil];
    [_tbView registerNib:nibCell forCellReuseIdentifier:@"TbCellIntegral"];
    
    TbCellIntegral *cCell=[_tbView dequeueReusableCellWithIdentifier:@"TbCellIntegral"];
    _tbView.rowHeight=CGRectGetHeight(cCell.frame);

    //等待加载数据
    [self performSelector:@selector(initData) withObject:self afterDelay:0.1];
}

- (void)initData{
    //今天日期
    NSString *sToday=[self getTodayDate];
    [self loadingDataWithDate:sToday];
}

//加载数据
- (void)loadingDataWithDate:(NSString*)sDate{
    _iTotalScore=0;
    NSInteger iYear=[[[sDate componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue];
    NSInteger iMonth=[[[sDate componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
    
    [ClassIntegral getMyScoreDataWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] Year:iYear Month:iMonth fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                
                _titleDateView.hidden=NO;
                
                _tbView.delegate=self;
                _tbView.dataSource=self;
                _arrayData=returnArray;
                //计算总积
                for (ClassIntegral *cClassData in _arrayData) {
                    _iTotalScore=_iTotalScore+[cClassData.sLogScore integerValue];
                }
            }
            _lblScore.text=[NSString stringWithFormat:@"%ld分",(long)_iTotalScore];
            [_tbView reloadData];
        }
    }];

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
    datePickerView.delegate=self;
    [datePickerView show];
    
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    [_titleDateButton setTitle:[psReturnDate stringByAppendingString:@" \u25BE"] forState:UIControlStateNormal];
    [self loadingDataWithDate:displayDate];
}

#pragma mark UITableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassIntegral *cClassData=[_arrayData objectAtIndex:indexPath.row];
    
    TbCellIntegral *cCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellIntegral"];
    
    //日期
    NSArray *arrayLogDate=[cClassData.sLogDate componentsSeparatedByString:@"-"];
    cCell.lblDate.text=[NSString stringWithFormat:@"%@-%@",[arrayLogDate objectAtIndex:1],[arrayLogDate lastObject]];
    //周
    cCell.lblWeek.text=[PublicFunc returnWeekDateWithDate:cClassData.sLogDate];
    
    if (cClassData.isLogExist) {
        cCell.viewDetail.hidden=NO;
         cCell.lblNoLog.hidden=YES;
        
        cCell.lblScore.text=cClassData.sLogScore;
        cCell.lblConfirmer.text=cClassData.sConfirmUser;
    }else{
        cCell.viewDetail.hidden=YES;
        cCell.lblNoLog.hidden=NO;
    }
    
    
    [cCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrayData count];
}



@end
