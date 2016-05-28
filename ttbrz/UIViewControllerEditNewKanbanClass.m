//
//  UIViewControllerAddNewKanban.m
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerEditNewKanbanClass.h"

@interface UIViewControllerEditNewKanbanClass ()<UITextFieldDelegate>{
    IBOutlet UITextField *_txtName;
    IBOutlet UIView *_viewMember;
    IBOutlet UIView *_viewRoot;
    IBOutlet UITextField *_txtMember;
    IBOutlet UIButton *_btnRoot;
    NSMutableArray *_arraySelectedMember;
    NSString *_sAuthorityType;//查看权限
    NSString *_sAuthorityIds;
}

@end

@implementation UIViewControllerEditNewKanbanClass

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    if (self.bEditKanban) {
        lblTitle.text=@"编辑分类";
    }else{
        lblTitle.text=@"新建分类";
    }
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //消息
    UIButton *btnSave=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,35,30)];
    btnSave.titleLabel.font=[UIFont systemFontOfSize:15];
    btnSave.backgroundColor=[UIColor clearColor];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(btnSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    
    self.navigationItem.rightBarButtonItem=saveButtonItem;

    _arraySelectedMember=[[NSMutableArray alloc] init];
    _sAuthorityIds=@"";
    _sAuthorityType=@"0";
    [_btnRoot setTitle:@"全部人 \u25BE" forState:UIControlStateNormal];
    
    _viewMember.hidden=YES;
    
    _txtName.layer.borderColor=[[UIColor grayColor] CGColor];
    _txtName.layer.borderWidth=1.0;
    _txtName.clearButtonMode=UITextFieldViewModeWhileEditing;
    _txtName.delegate=self;
    
    _txtMember.userInteractionEnabled=NO;
    _txtMember.layer.borderColor=[[UIColor grayColor] CGColor];
    _txtMember.layer.borderWidth=1.0;
    
    if (self.bEditKanban) {
        _txtName.text=self.cClassTaskData.sLookBoardTypeName;
        
        NSString *sMemberNameInfo=@"";
        for (NSDictionary *dictData in _cClassTaskData.arrayAuthorityManagementInfo) {
            if ([sMemberNameInfo isEqualToString:@""]) {
                sMemberNameInfo=[dictData objectForKey:@"AuthorityUserName"];
                _sAuthorityIds=[dictData objectForKey:@"AuthorityUserID"];
            }else{
                sMemberNameInfo=[NSString stringWithFormat:@"%@,%@",sMemberNameInfo,[dictData objectForKey:@"AuthorityUserName"]];
                _sAuthorityIds=[NSString stringWithFormat:@"%@|%@",_sAuthorityIds,[dictData objectForKey:@"AuthorityUserID"]];
            }
            
            [_arraySelectedMember addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dictData objectForKey:@"AuthorityUserID"], @"UserID",[dictData objectForKey:@"AuthorityUserName"],@"UserName",nil]];
            
        }
        _txtMember.text=sMemberNameInfo;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 键盘事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtName resignFirstResponder];
    return YES;
}
-(void)disKeyboard{
    [_txtName resignFirstResponder];
}

#pragma mark 保存
- (void)btnSave{
    
    [self disKeyboard];
    
    if (_txtName.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请输入分类名称" view:self.view];
        return;
    }
    
    if ([_sAuthorityType isEqualToString:@"2"] && _txtMember.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请选择可见人员" view:self.view];
        return;
    }
    
    if (self.bEditKanban) {
        [ClassTask editKanbanClassificationWithName:_txtName.text ShowIndex:[self.cClassTaskData.sShowIndex integerValue] State:0 KanBanTypeId:self.cClassTaskData.sPK_LookBoardTypeID AuthorityType:_sAuthorityType AuthorityIds:_sAuthorityIds UserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
            }
        }];
    }else{
        [ClassTask NewKanbanClassificationWithName:_txtName.text ShowIndex:1 AuthorityType:_sAuthorityType AuthorityIds:_sAuthorityIds UserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
            }
        }];
    }
}

-(void)dismissView{
    UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerTask *taskView=[rootTabBarView.viewControllers objectAtIndex:1];
    [taskView loadingTaskData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark 权限
- (IBAction)didBtnRoot:(id)sender {
    
    [self disKeyboard];
    
    UIButton *btnObj=sender;
    
    CGPoint point = CGPointMake(btnObj.frame.origin.x + btnObj.frame.size.width/2+15,  _viewRoot.frame.origin.y+_viewRoot.frame.size.height);
    NSArray *titles = @[@"全部人", @"仅自己",@"部分人"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:nil];
    pop.selectRowAtIndex = ^(NSInteger index){
        _viewMember.hidden=YES;
        if (index==0) {
            //全部人
            _sAuthorityType=@"0";
             [_btnRoot setTitle:@"全部人 \u25BE" forState:UIControlStateNormal];
        }else if(index==1){
            //仅自己
            _sAuthorityType=@"1";
             [_btnRoot setTitle:@"仅自己 \u25BE" forState:UIControlStateNormal];
        }else{
            //部分人
            _sAuthorityType=@"2";
             [_btnRoot setTitle:@"部分人 \u25BE" forState:UIControlStateNormal];
            _viewMember.hidden=NO;
        }
    };
    [pop show];

}

#pragma mark 选择可见人员
- (IBAction)didBtnSelectMember:(id)sender {
    [ClassTask GetAllDeptTreeWithUserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                UIViewControllerTaskSelectMember *colleagueDetailLogView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerTaskSelectMember"];
                colleagueDetailLogView.bSelectVisibleMember=YES;
                colleagueDetailLogView.arrayData=returnArray;
                 colleagueDetailLogView.arraySelectedUser=[_arraySelectedMember mutableCopy];
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                [self.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:colleagueDetailLogView animated:YES];
            }
        }
    }];
}

- (void)displaySelectedMember:(NSArray*)arraySelectedMember{
    
    [_arraySelectedMember removeAllObjects];
    
    for (NSDictionary *dictData in arraySelectedMember) {
        [_arraySelectedMember addObject:dictData];
    }
    //显示人员
    NSString *sMembers=@"";
    
    for (NSDictionary *curDict in _arraySelectedMember) {
        if ([sMembers isEqualToString:@""]) {
            sMembers=[curDict objectForKey:@"UserName"];
            _sAuthorityIds=[curDict objectForKey:@"UserID"];
        }else{
            sMembers=[NSString stringWithFormat:@"%@,%@",sMembers,[curDict objectForKey:@"UserName"]];
            _sAuthorityIds=[NSString stringWithFormat:@"%@|%@",_sAuthorityIds,[curDict objectForKey:@"UserID"]];
        }
    }
    _txtMember.text=sMembers;
    
}


@end
