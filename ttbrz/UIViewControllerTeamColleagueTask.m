//
//  UIViewControllerTeamColleagueTask.m
//  ttbrz
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTeamColleagueTask.h"
#define KTbHeaderHeight 40
#define KPerDataNum        5
#define  KImageCorrorTag  100

@interface UIViewControllerTeamColleagueTask ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{

    IBOutlet UITableView *_tbColleagueView;

    NSMutableArray *_arrayTaskInfo;
    NSMutableArray *_arryExpand;
    //float _fUserDetailRowHeight;
    
    NSInteger _iCurDataIndex;//当前任务数据的页数
    
    UILabel *_lblFileTbFooter;
    BOOL _bHasMoreFileData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_fileTbFooterAcIndicator;//加载等待
}

@end

@implementation UIViewControllerTeamColleagueTask

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTaskColleagueInfo" bundle:nil];
    [_tbColleagueView registerNib:nibCell forCellReuseIdentifier:@"TbCellTaskColleagueInfo"];
    
    TbCellTaskColleagueInfo *taskColleagueInfoCell=[_tbColleagueView dequeueReusableCellWithIdentifier:@"TbCellTaskColleagueInfo"];
    _tbColleagueView.rowHeight=CGRectGetHeight(taskColleagueInfoCell.frame);
    
    _arrayTaskInfo=[[NSMutableArray alloc] init];
    _arryExpand=[[NSMutableArray alloc] init];
    
    _iCurDataIndex=1;
    _bHasMoreFileData=YES;
    
    NSInteger taskTbFooterLabelW=150;
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

    if (self.arrayGetInitData.count>0) {
        for (int i=0; i<=self.arrayGetInitData.count-1; i++) {
            ClassTask *cClassTaskData=[self.arrayGetInitData objectAtIndex:i];
            [_arrayTaskInfo addObject:cClassTaskData.arrayNoCompletedTaskList];
            
            NSDictionary *curDict=[[NSDictionary alloc] initWithObjectsAndKeys:@"no",@"expanded", nil];
            [_arryExpand addObject:curDict];
        }
        
        _tbColleagueView.dataSource=self;
        _tbColleagueView.delegate=self;
        _tbColleagueView.scrollEnabled=YES;
        
        _lblFileTbFooter.text=@"滑动加载更多 \u25BE";

    }else{
    
        _tbColleagueView.dataSource=nil;
        _tbColleagueView.delegate=nil;
        _tbColleagueView.scrollEnabled=NO;
        
        _lblFileTbFooter.text=@"暂无数据";
    }
    
    _tbColleagueView.tableFooterView=viewTbFooter;
    [_tbColleagueView reloadData];
    
    if (self.arrayGetInitData.count==KPerDataNum) {
        _iCurDataIndex=2;
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   return  KTbHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    UIView *viewHeader=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), KTbHeaderHeight)];
    viewHeader.backgroundColor=[UIColor whiteColor];
    NSInteger iImageCorrorSize=15;
    NSInteger iLblMemberNameHeaderSize=30;
    NSInteger iLineH=1;
    NSInteger iGap=15;
    NSInteger iLblMemberNameDepartmentW=CGRectGetWidth(viewHeader.frame)-iLblMemberNameHeaderSize-iGap;
    NSInteger iViewDetailH=30;
    ClassTask *cClassData=[self.arrayGetInitData objectAtIndex:section];
    
    //明细view
    UIView *viewDetail=[[UIView alloc]initWithFrame:CGRectMake(iGap, 0, CGRectGetWidth(self.view.frame)-iGap*2, KTbHeaderHeight)];
    //viewDetail.backgroundColor=[UIColor redColor];
    [viewHeader addSubview:viewDetail];
    
    //人员头像label.image
    
    if ([cClassData.sVchrPhoto isEqualToString:@""]) {
        //人员头像label
        UILabel *lblMemberNameHeader=[[UILabel alloc] initWithFrame:CGRectMake(0,(KTbHeaderHeight-iLblMemberNameHeaderSize)/2,iLblMemberNameHeaderSize, iLblMemberNameHeaderSize)];
        lblMemberNameHeader.backgroundColor=defaultColor;
        lblMemberNameHeader.textAlignment=NSTextAlignmentCenter;
        lblMemberNameHeader.text=[cClassData.sUserName substringFromIndex:cClassData.sUserName.length-1];
        lblMemberNameHeader.textColor=[UIColor whiteColor];
        lblMemberNameHeader.font=[UIFont systemFontOfSize:18];
        [viewDetail addSubview:lblMemberNameHeader];

    }else{
        //image
        UIImageView *imageViewObject=[[UIImageView alloc] initWithFrame:CGRectMake(0,(KTbHeaderHeight-iLblMemberNameHeaderSize)/2,iLblMemberNameHeaderSize, iLblMemberNameHeaderSize)];
        NSData *photoData = [[NSData alloc] initWithBase64EncodedString:cClassData.sVchrPhoto options:0];
        imageViewObject.image=[UIImage imageWithData:photoData];
        //imageViewObject.contentMode=UIViewContentModeScaleAspectFit;
        [viewDetail addSubview:imageViewObject];
    }
    
    
    //btnHeader title 同事名称+所在部门
    UIButton* btnHeader = [[UIButton alloc] initWithFrame:CGRectMake(iLblMemberNameHeaderSize, 0, iLblMemberNameDepartmentW, iViewDetailH)];
    [btnHeader addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnHeader.tag = section;
    btnHeader.accessibilityLabel=@"nocheck";
    btnHeader.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnHeader.backgroundColor = [UIColor clearColor];
    [btnHeader setTitle:[NSString stringWithFormat:@"%@(%@)",cClassData.sUserName,cClassData.sDeptName] forState:UIControlStateNormal];
    [btnHeader setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnHeader.titleLabel.font=[UIFont systemFontOfSize:15];
    
    [viewDetail addSubview: btnHeader];
    //横线
    UIView *viewLine=[[UIView alloc] initWithFrame:CGRectMake(iLblMemberNameHeaderSize, iViewDetailH, iLblMemberNameDepartmentW, iLineH)];
    viewLine.backgroundColor=[UIColor groupTableViewBackgroundColor];
    [viewDetail addSubview:viewLine];
    
    
    //箭关
    UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(iLblMemberNameDepartmentW,(iViewDetailH-iImageCorrorSize)/2, iImageCorrorSize, iImageCorrorSize)];
    imageCorror.tag=KImageCorrorTag+section;
    [viewDetail addSubview:imageCorror];
    
    if ([[[_arryExpand objectAtIndex:section] objectForKey:@"expanded"] isEqualToString:@"yes"] ) {
        //展开
        imageCorror.image=[UIImage imageNamed:@"colleagueLog_down_corror.png"];
    }else{
        //缩回
        imageCorror.image=[UIImage imageNamed:@"colleagueLog_right_corror.png"];
    }
    
    return viewHeader;
}


//按钮被点击时触发
-(void)expandButtonClicked:(id)sender{
    
    UIButton* btnObj= (UIButton*)sender;
    NSInteger iSection=btnObj.tag;
    NSMutableDictionary* dictData=[_arryExpand objectAtIndex:iSection];
    //若本节model中的“expanded”属性不为空，则取出来
    if([[dictData objectForKey:@"expanded"] isEqualToString:@"no"]){
        [_arryExpand replaceObjectAtIndex:iSection withObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"yes",@"expanded", nil]];
    }else{
        [_arryExpand replaceObjectAtIndex:iSection withObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"no",@"expanded", nil]];
    }
    
    //刷新tableview
    [_tbColleagueView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   __block ClassTask *cClassTaskData=[[_arrayTaskInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [ClassLog getDetailPlanTaskWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strTaskID:cClassTaskData.sTaskID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            UIViewControllerPlanTask *planTaskView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerPlanTask"];
            planTaskView.cGetDetailPlanTaskData=[returnArray firstObject];
            cClassTaskData=[self.arrayGetInitData objectAtIndex:indexPath.section];
            planTaskView.sGetUserID=cClassTaskData.sUserID;
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:planTaskView animated:YES];
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *curArray=[_arrayTaskInfo objectAtIndex:indexPath.section];
   ClassTask *cClassTaskData=[curArray objectAtIndex:indexPath.row];
    
    TbCellTaskColleagueInfo *colleagueLogCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskColleagueInfo"];
    
    //判断任务是否已过期(超过一天) 任务标题改颜色
    NSString *sTaskEndDate=cClassTaskData.sDtEnd;
    NSTimeInterval timeBetween;
    if (cClassTaskData.bIsOntime) {
        NSArray *arrayEndDate=[[[sTaskEndDate componentsSeparatedByString:@"T"] firstObject] componentsSeparatedByString:@"-"];
        sTaskEndDate=[NSString stringWithFormat:@"%@-%@-%@",[arrayEndDate objectAtIndex:0],[arrayEndDate objectAtIndex:1] ,[arrayEndDate objectAtIndex:2]];
        NSDate *dTaskEndDate=[PublicFunc dateFromString:sTaskEndDate dateFormatterType:DateFromStringTypeYMD];
        timeBetween=[dTaskEndDate timeIntervalSinceNow];
        
        sTaskEndDate=[NSString stringWithFormat:@"%@-%@",[arrayEndDate objectAtIndex:1] ,[arrayEndDate objectAtIndex:2]];
    }
    timeBetween=-timeBetween;
    if (timeBetween>60*60*24) {
        colleagueLogCell.lblTaskName.textColor=[UIColor redColor];
    }else{
        colleagueLogCell.lblTaskName.textColor=[UIColor darkGrayColor];
    }
    colleagueLogCell.lblTaskDate.text=sTaskEndDate;
    colleagueLogCell.lblTaskName.text=cClassTaskData.sTaskTitle;
    colleagueLogCell.lblTaskProgress.text=cClassTaskData.sProgress;
    
    [colleagueLogCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return colleagueLogCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.arrayGetInitData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    //对指定节进行“展开”判断
    if ([[[_arryExpand objectAtIndex:section] objectForKey:@"expanded"] isEqualToString:@"no"] ) {
        //缩回
        return 0;
    }else{
        //展开
        NSArray *arrayRow=[_arrayTaskInfo objectAtIndex:section];
        return arrayRow.count;
    }
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
        
        [ClassTask getDeptTaskPlanListNoHUDWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] pageindex:_iCurDataIndex pagesize:KPerDataNum deptid:self.sGetDepartmentID returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        _lblFileTbFooter.text=@"已全部加载完毕";
                        _bHasMoreFileData=NO;
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if (_iCurDataIndex==1 ) {
                            //先清除进入页面时初始化的数据
                            [self.arrayGetInitData removeAllObjects];
                            
                            self.arrayGetInitData=[returnArray mutableCopy];
                            if (returnArray.count==KPerDataNum) {
                                _iCurDataIndex=2;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                        }else{
                            if (returnArray.count==KPerDataNum) {
                                _iCurDataIndex++;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                            //插入数据
                            for (NSDictionary *dictData in returnArray) {
                                [self.arrayGetInitData addObject:dictData];
                            }
                            [_tbColleagueView reloadData];
                        }
                    }
                }
               
            }else{
                _bHasMoreFileData=YES;
                _lblFileTbFooter.text=@"获取数据失败,请重试";
            }
            _fileTbFooterAcIndicator.hidden=YES;
            [_fileTbFooterAcIndicator stopAnimating];

        }];
        
    }
}


@end
