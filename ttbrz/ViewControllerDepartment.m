//
//  ViewControllerDepartment.m
//  ttbrz
//
//  Created by apple on 16/3/9.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ViewControllerDepartment.h"

@interface ViewControllerDepartment ()<UITableViewDataSource,UITableViewDelegate>{


    float _fRowDataH,_itbViewH;
    BOOL _bDidLayoutSubviews;
    
    IBOutlet UITableView *_tbDepartment;
    IBOutlet NSLayoutConstraint *_tbLayoutBottom;
}

@end

@implementation ViewControllerDepartment

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"选择部门";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellDepartment" bundle:nil];
    [_tbDepartment registerNib:nibCell forCellReuseIdentifier:@"UICellDepartment"];
    
    TbCellDepartment*cell=[_tbDepartment dequeueReusableCellWithIdentifier:@"UICellDepartment"];
    _tbDepartment.rowHeight=CGRectGetHeight(cell.frame);
    _fRowDataH=CGRectGetHeight(cell.frame);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (self.arryDepartment.count>0) {
        int iCurTbHeight=self.arryDepartment.count*_fRowDataH;
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
        _itbViewH=CGRectGetHeight(_tbDepartment.frame);
        [self setTbBottomConstant];
    }
}


#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TbCellDepartment*myCell=[tableView dequeueReusableCellWithIdentifier:@"UICellDepartment"];
    //[celMyAction setSelectionStyle:UITableViewCellSelectionStyleNone];
    ClassLog *cClassLogObject =[self.arryDepartment objectAtIndex:indexPath.row];
    myCell.lblDepartmentName.text=cClassLogObject.sDeptName;
    
    return myCell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arryDepartment.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.sFromUIViewId isEqualToString:@"UIViewControllerTeamIntegral"]) {
        //团队积分
        UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
        UIViewControllerTeamIntegral *teamIntegralView=[rootTabBarView.viewControllers objectAtIndex:2];
        ClassLog *cClassLogObject =[self.arryDepartment objectAtIndex:indexPath.row];
        
        NSString *sDepartmentID=@"";
        //当部门类型为非公司级时才输入对应的值 公司级为空字符串
        if ([cClassLogObject.sDepartmentType isEqualToString:@"1"]) {
            sDepartmentID=cClassLogObject.sDeptID;
        }
        
        [teamIntegralView selectedDepartmentID:sDepartmentID sDepartmentName:cClassLogObject.sDeptName];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }else{
        
        UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
        UIViewControllerTeamLog *teamLogView=[rootTabBarView.viewControllers firstObject];
        ClassLog *cClassLogObject =[self.arryDepartment objectAtIndex:indexPath.row];
        
        NSString *sDepartmentID=@"";
        //当部门类型为非公司级时才输入对应的值 公司级为空字符串
        if ([cClassLogObject.sDepartmentType isEqualToString:@"1"]) {
            sDepartmentID=cClassLogObject.sDeptID;
        }
        
        [teamLogView selectedDepartmentID:sDepartmentID sDepartmentName:cClassLogObject.sDeptName];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

@end
