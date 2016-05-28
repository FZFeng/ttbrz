//
//  UIViewControllerTeamTask.m
//  ttbrz
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTeamTask.h"

@interface UIViewControllerTeamTask ()<UITableViewDataSource,UITableViewDelegate>{
    
    float _fRowDataH,_itbViewH;
    BOOL _bDidLayoutSubviews;

    IBOutlet UITableView *_tbDepartment;
    IBOutlet NSLayoutConstraint *_tbLayoutBottom;
    
    NSArray *_arryDepartment;
}

@end

@implementation UIViewControllerTeamTask

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_TeamTask];
    
    //默认先不显示分割线
    _tbDepartment.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTeamTaskDepartment" bundle:nil];
    [_tbDepartment registerNib:nibCell forCellReuseIdentifier:@"TbCellTeamTaskDepartment"];
    
    TbCellTeamTaskDepartment*cell=[_tbDepartment dequeueReusableCellWithIdentifier:@"TbCellTeamTaskDepartment"];
    _tbDepartment.rowHeight=CGRectGetHeight(cell.frame);
    _fRowDataH=CGRectGetHeight(cell.frame);
    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];

}

#pragma mark 加载数据
- (void)loadingData{
    
    [ClassLog getDepartmentDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] strType:@"2" fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            _tbDepartment.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            _arryDepartment=returnArray;
            
            _tbDepartment.delegate=self;
            _tbDepartment.dataSource=self;
            [_tbDepartment reloadData];
        }
        
        _itbViewH=CGRectGetHeight(_tbDepartment.frame);
        [self setTbBottomConstant];

    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (_arryDepartment.count>0) {
        int iCurTbHeight=_arryDepartment.count*_fRowDataH;
        if (iCurTbHeight>_itbViewH) {
            _tbLayoutBottom.constant=0.0;
            _tbDepartment.scrollEnabled=YES;
        }else{
            _tbLayoutBottom.constant=_itbViewH-iCurTbHeight;
            _tbDepartment.scrollEnabled=NO;
        }
    }
}

-(void)viewDidLayoutSubviews{
    //根据arryActionJoinor来计算tbview的高度
    if (!_bDidLayoutSubviews) {
        _bDidLayoutSubviews=YES;
       
    }
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TbCellTeamTaskDepartment*myCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTeamTaskDepartment"];
    //[celMyAction setSelectionStyle:UITableViewCellSelectionStyleNone];
    ClassLog *cClassLogObject =[_arryDepartment objectAtIndex:indexPath.row];
    myCell.lblDepartmentName.text=cClassLogObject.sDeptName;
    
    return myCell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arryDepartment.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClassTask *cClassTaskData=[_arryDepartment objectAtIndex:indexPath.row];
    [ClassTask getDeptTaskPlanListWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] pageindex:1 pagesize:5 deptid:cClassTaskData.sDeptID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            UIViewControllerTeamColleagueTask *teamColleagueTaskView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerTeamColleagueTask"];
            teamColleagueTaskView.arrayGetInitData=[returnArray mutableCopy];
            teamColleagueTaskView.sGetDepartmentID=cClassTaskData.sDeptID;
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:teamColleagueTaskView animated:YES];
        }
    }];
    
}


@end
