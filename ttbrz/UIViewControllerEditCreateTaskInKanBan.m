//
//  UIViewControllerCreateTaskInKanBan.m
//  ttbrz
//
//  Created by apple on 16/4/12.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerEditCreateTaskInKanBan.h"

@interface UIViewControllerEditCreateTaskInKanBan ()<FZDatePickerViewDelegate,UITextFieldDelegate,UITextViewDelegate>{

    IBOutlet UIView *_viewName;
    IBOutlet UITextField *_txtTaskName;
    
    
    IBOutlet UIButton *_btnSelectDate;

    IBOutlet UIView *_viewExecuteUsers;
    IBOutlet NSLayoutConstraint *_layoutConstraintHeightExecuteUsers;
    
    IBOutlet UILabel *_lblFinishDate;
    IBOutlet UILabel *_lblFinishNowDate;
    IBOutlet UIButton *_btnTaskFinishDate;
    IBOutlet NSLayoutConstraint *_layoutConstraintViewFinishDateTop;
    

    IBOutlet UIView *_viewKanBanInfo;
    IBOutlet UIView *_viewKanBan;

    
    IBOutlet UITextView *_txtTaskContent;
    
    UILabel *_lblKanBan;
    UIButton *_btnSelectKanBan;
    
    BOOL _bTaskFinishedInDate;
    BOOL _bDidLayoutSubviews;
    NSMutableArray *_arraySelectedMember;
    NSInteger _iViewH;
    
    
}

@end

@implementation UIViewControllerEditCreateTaskInKanBan

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //注册键盘消失事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    self.accessibilityLabel=@"UIViewControllerEditCreateTaskInKanBan";
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"新建任务";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //保存
    UIButton *btnSave=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,45,35)];
    btnSave.titleLabel.font=[UIFont systemFontOfSize:16];
    btnSave.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(didBtnSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    self.navigationItem.rightBarButtonItem=saveButtonItem;

    _txtTaskName.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _txtTaskName.layer.borderWidth=1.0;
    _txtTaskName.clearButtonMode=UITextFieldViewModeWhileEditing;
    _txtTaskName.delegate=self;
    
    _txtTaskContent.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _txtTaskContent.layer.borderWidth=1.0;
    _txtTaskContent.delegate=self;
    
    _layoutConstraintHeightExecuteUsers.constant=0;
    _layoutConstraintViewFinishDateTop.constant=0;
    
    _bTaskFinishedInDate=NO;
    _btnSelectDate.userInteractionEnabled=NO;
    
    //今天日期
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    _lblFinishDate.text=dateString;
    
    _arraySelectedMember=[[NSMutableArray alloc] init];
    
    if (self.bEditTask) {
        lblTitle.text=@"编辑任务";
        
        //任务名称
        _txtTaskName.text=self.cClassTaskData.sTaskTitle;
        
        //截止日期
        if (![self.cClassTaskData.sEndDate isEqualToString:@"尽快"]) {
            _bTaskFinishedInDate=YES;
            [_btnTaskFinishDate setBackgroundImage:[UIImage imageNamed:@"taskFinish_no.png"] forState:UIControlStateNormal];
            [_btnSelectDate setBackgroundImage:[UIImage imageNamed:@"selectTaskDate.png"] forState:UIControlStateNormal];
            _lblFinishDate.textColor=[UIColor darkGrayColor];
            _lblFinishNowDate.textColor=[UIColor lightGrayColor];
            _btnSelectDate.userInteractionEnabled=YES;
        }
        //描述
        _txtTaskContent.text=self.cClassTaskData.sTaskContent;
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{

    if (!_bDidLayoutSubviews) {
        _bDidLayoutSubviews=YES;
        _iViewH=CGRectGetHeight(_viewName.frame);
        
        [self initLookBoardUI];
        
        //执行人信息
        if (self.bEditTask) {
            NSArray *arrayUserInfo=[self.cClassTaskData.sUserInfo componentsSeparatedByString:@"="];
            NSArray *arrayID=[[arrayUserInfo firstObject] componentsSeparatedByString:@"|"];
            NSArray *arrayName=[[arrayUserInfo objectAtIndex:1] componentsSeparatedByString:@","];
            NSArray *arrayPersent=[[arrayUserInfo lastObject] componentsSeparatedByString:@","];
            
            //没指定人员，不显示
            if (arrayID.count==1 && [[arrayID firstObject] isEqualToString:@""]) {
            }else{
                for (int i=0; i<=arrayID.count-1; i++) {
                    [_arraySelectedMember addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[arrayID objectAtIndex:i], @"UserID",[arrayName objectAtIndex:i],@"UserName",[arrayPersent objectAtIndex:i],@"Persent",nil]];
                }
            }
            [self displaySelectedMember:[_arraySelectedMember copy]];
        }
    }
}

#pragma mark 购建看板lable,button
- (void)initLookBoardUI{
    
    [_lblKanBan removeFromSuperview];
    [_btnSelectKanBan removeFromSuperview];
    
    NSInteger iDefaultLblKanBanW=200;//默认最大宽度
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGSize sizeToFit = [self.sGetLookBoard boundingRectWithSize:CGSizeMake(iDefaultLblKanBanW, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    _lblKanBan=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,sizeToFit.width,_iViewH)];
    _lblKanBan.font=[UIFont systemFontOfSize:15];
    _lblKanBan.textColor=[UIColor darkGrayColor];
    _lblKanBan.text=self.sGetLookBoard;
    [_viewKanBanInfo addSubview:_lblKanBan];
    
    //选择看板
    NSInteger iBtnSelectKanBanSize=25;
    _btnSelectKanBan=[[UIButton alloc] initWithFrame:CGRectMake(sizeToFit.width, (_iViewH-iBtnSelectKanBanSize)/2,iBtnSelectKanBanSize,iBtnSelectKanBanSize)];
    [_btnSelectKanBan setBackgroundImage:[UIImage imageNamed:@"selectKanBan.png"] forState:UIControlStateNormal];
    [_btnSelectKanBan addTarget:self action:@selector(didBtnSelectKanBan) forControlEvents:UIControlEventTouchUpInside];
    [_viewKanBanInfo addSubview:_btnSelectKanBan];

}

#pragma mark 选择执行人
- (IBAction)didBtnSelectExecuteUserID:(id)sender {
    [self disKeyboard];
    
    [ClassTask GetAllDeptTreeWithUserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                UIViewControllerTaskSelectMember *colleagueDetailLogView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerTaskSelectMember"];
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
   
    NSInteger iDataNum=arraySelectedMember.count;
    [_arraySelectedMember removeAllObjects];
    
    for (UIView *subView in _viewExecuteUsers.subviews) {
        [subView removeFromSuperview];
    }
    
    if (iDataNum>0) {
        _layoutConstraintHeightExecuteUsers.constant=_iViewH;
        
        for (NSDictionary *dictData in arraySelectedMember) {
            [_arraySelectedMember addObject:dictData];
        }
        
        NSInteger iViewExecuteUsersW=CGRectGetWidth(_viewExecuteUsers.frame);
        NSInteger iGap=5;
        NSInteger iScrolW=60;
        NSInteger iLabelSize=iScrolW/2;
        NSInteger iLblPresentW=40;
        NSInteger iCurOriginX=0;
        
        UIScrollView *scrolMember=[[UIScrollView alloc] initWithFrame:CGRectMake(0,iGap,iViewExecuteUsersW, _iViewH)];
        scrolMember.bounces=NO;
        scrolMember.scrollEnabled=YES;
        scrolMember.showsHorizontalScrollIndicator=NO;
        scrolMember.showsVerticalScrollIndicator=NO;
        [_viewExecuteUsers addSubview:scrolMember];
        NSInteger iIndex=0;
        for (NSDictionary *curDict in _arraySelectedMember) {
            //执行人
            NSString *sUserName=[curDict objectForKey:@"UserName"];
            UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX, 0,iLabelSize, iLabelSize)];
            lblName.text=[sUserName substringFromIndex:sUserName.length-1];
            lblName.textAlignment=NSTextAlignmentCenter;
            lblName.textColor=[UIColor whiteColor];
            lblName.font=[UIFont systemFontOfSize:18];
            lblName.backgroundColor=randomColor;
            [scrolMember addSubview:lblName];
            iCurOriginX=iCurOriginX+iLabelSize;
            
            //完成进度
            UILabel *lblPersent=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX, 0,iLblPresentW, iLabelSize)];
            lblPersent.text=@"0%";
            
            NSString *sPersent=[curDict objectForKey:@"Persent"];
            
            if (self.bEditTask && sPersent) {
                lblPersent.text=[NSString stringWithFormat:@"%@%%",sPersent];
            }
            lblPersent.textAlignment=NSTextAlignmentLeft;
            lblPersent.textColor=defaultColor;
            lblPersent.font=[UIFont systemFontOfSize:15];
            lblPersent.backgroundColor=[UIColor clearColor];
            [scrolMember addSubview:lblPersent];
            iCurOriginX=iCurOriginX+iLblPresentW+iGap;
            
            iIndex++;
        }
        if (iCurOriginX>iViewExecuteUsersW){
            scrolMember.contentSize=CGSizeMake(iCurOriginX, 0);
        }
    }else if (iDataNum==0){
        _layoutConstraintHeightExecuteUsers.constant=0;
    }
}


#pragma mark 选择日期
- (IBAction)didBtnSelectDate:(id)sender {
    
    [self disKeyboard];
    
    FZDatePickerView *datePickerView=[[FZDatePickerView alloc] initWithReferView:self.view];
    datePickerView.delegate=self;
    datePickerView.bFinishTaskDate=YES;
    [datePickerView show];
}

//选择日期 回调
-(void)FZDatePickerViewDelegateReturnDate:(NSString *)psReturnDate displayDate:(NSString *)displayDate{
    _lblFinishDate.text=displayDate;
}

#pragma mark 任务尽快完成/指定日期
- (IBAction)didBtnTaskFinishDate:(id)sender {
    
    [self disKeyboard];
    
    if (!_bTaskFinishedInDate) {
        _bTaskFinishedInDate=YES;
        [_btnTaskFinishDate setBackgroundImage:[UIImage imageNamed:@"taskFinish_no.png"] forState:UIControlStateNormal];
        [_btnSelectDate setBackgroundImage:[UIImage imageNamed:@"selectTaskDate.png"] forState:UIControlStateNormal];
        _lblFinishDate.textColor=[UIColor darkGrayColor];
        _lblFinishNowDate.textColor=[UIColor lightGrayColor];
        _btnSelectDate.userInteractionEnabled=YES;
    }else{
        _bTaskFinishedInDate=NO;
        [_btnTaskFinishDate setBackgroundImage:[UIImage imageNamed:@"taskFinish.png"] forState:UIControlStateNormal];
        [_btnSelectDate setBackgroundImage:[UIImage imageNamed:@"selectTaskDate_no.png"] forState:UIControlStateNormal];
        _lblFinishDate.textColor=[UIColor lightGrayColor];
        _lblFinishNowDate.textColor=[UIColor  darkGrayColor];
        _btnSelectDate.userInteractionEnabled=NO;
    }
}
#pragma mark 选择看板
- (void)didBtnSelectKanBan{
    
    [self disKeyboard];
    
    [ClassTask getLookBoardList:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                UIViewControllerTaskSelectKanBan *taskSelectKanBanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerTaskSelectKanBan"];
                taskSelectKanBanView.arrayData=returnArray;
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                [self.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:taskSelectKanBanView animated:YES];
            }
        }
    }];

}

#pragma mark 选择看板后调用
- (void)displaySelectedLookBoard:(NSString*)sLookBoardID sLookBoardName:(NSString*)sLookBoardName{
    self.sGetLookBoardID=sLookBoardID;
    self.sGetLookBoard=sLookBoardName;
    [self initLookBoardUI];
}

#pragma mark 注册键盘消失事件后的实现
- (void)keyboardWillHide{
    //动画效果
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

#pragma-mark Uitextfiled事件
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //动画效果
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    //上移90个单位，按实际情况设置
    float fMoveTop;
    if (_arraySelectedMember && _arraySelectedMember.count>0) {
        fMoveTop=-90.0;
    }else{
        fMoveTop=-50.0;
    }
    
    CGRect rect=CGRectMake(0.0f,fMoveTop,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /*
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }*/
    return YES;
}

#pragma mark 键盘事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtTaskName resignFirstResponder];
    [_txtTaskContent resignFirstResponder];
    return YES;
}
-(void)disKeyboard{
    [_txtTaskName resignFirstResponder];
    [_txtTaskContent resignFirstResponder];
}

#pragma mark 保存
- (void)didBtnSave{
    
    [self disKeyboard];
    
    if (_txtTaskName.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请输入任务名称" view:self.view];
        return;
    }
    
    NSString *sMemberIdList=@"";
    for (NSDictionary *curDict in _arraySelectedMember) {
        if ([sMemberIdList isEqualToString:@""]) {
            sMemberIdList=[curDict objectForKey:@"UserID"];
        }else{
            sMemberIdList=[NSString stringWithFormat:@"%@,%@",sMemberIdList,[curDict objectForKey:@"UserID"]];
        }
    }

    NSString *sFinishDate=@"";
    if (_bTaskFinishedInDate) {
        sFinishDate=_lblFinishDate.text;
    }
    
    if (self.bEditTask) {
        [ClassTask editTaskLookBoardWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strTaskID:self.sGetTaskID strTaskName:_txtTaskName.text strLookBoardID:self.sGetLookBoardID strFinishDate:sFinishDate strExecuteUserID:sMemberIdList strTaskContent:_txtTaskContent.text fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                //更新对应值
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
                
            }
        }];
    }else{
        [ClassTask createTaskLookBoardWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strTaskName:_txtTaskName.text strLookBoardID:self.sGetLookBoardID strFinishDate:sFinishDate strExecuteUserID:sMemberIdList strTaskContent:_txtTaskContent.text fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                
                //更新对应值
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
                
            }
        }];
    }
}

- (void)dismissView{
    if (self.bFormMyPlanTaskView) {
        UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
        UIViewControllerMyPlanTask *myPlanTaskView=[rootTabBarView.viewControllers objectAtIndex:1];
        [myPlanTaskView initViewAndDataAfterOperateLookBoard];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        UIViewControllerKanbanInfo *kanbanInfoView=[self.navigationController.viewControllers objectAtIndex:1];
        [kanbanInfoView initViewAndDataAfterOperateLookBoard];
        [self.navigationController popToViewController:kanbanInfoView animated:YES];
    }
}

@end
