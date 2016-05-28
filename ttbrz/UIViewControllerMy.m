//
//  UIViewControllerMy.m
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMy.h"
#define KRowHeightPersion  60
#define KRowHeight  35

@interface UIViewControllerMy ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate>{
    IBOutlet UITableView *_tbView;
    
    UIImageView *_imageFileIcon;
    UILabel *_lblIcon;
    UIView *_viewSuggestion;
    UITextView *_txtSuggestion;
    UITextField *_txtSuggestionEmail;
}

@end

@implementation UIViewControllerMy

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tbView.scrollEnabled=NO;
    
    //去掉左边的空白
    if ([_tbView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tbView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([_tbView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tbView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 关闭意见View
- (void)hideSuggestionView{
    [_viewSuggestion removeFromSuperview];
}

#pragma mark UITableview Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        //个人信息
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
        
        UIViewController *aboutView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerMyInfo"];
        [self.navigationController pushViewController:aboutView animated:YES];
        
    }else if (indexPath.section==1) {
        if (indexPath.row==0) {
            //检查新版本
        }else if (indexPath.row==1){
            //意见反馈
            [self hideSuggestionView];
            
            _viewSuggestion=[[UIView alloc] initWithFrame:self.view.frame];
            _viewSuggestion.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
            [self.view addSubview:_viewSuggestion];
            
            //点击空白关闭
            /*
            UIButton *bgButton=[[UIButton alloc] initWithFrame:self.view.frame];
            [bgButton addTarget:self action:@selector(hideSuggestionView) forControlEvents:UIControlEventTouchUpInside];
            [_viewSuggestion addSubview:bgButton];*/
            
            NSInteger iViewShowLogInfoH=CGRectGetHeight(_viewSuggestion.frame);
            NSInteger iViewShowLogInfoW=CGRectGetWidth(_viewSuggestion.frame);
            NSInteger iViewDetailH=200;
            NSInteger iLeftOrRightGap=10;
            
            UIView *viewDetail=[[UIView alloc]  initWithFrame:CGRectMake(iLeftOrRightGap, (iViewShowLogInfoH-iViewDetailH)/2, iViewShowLogInfoW-iLeftOrRightGap*2, iViewDetailH)];
            viewDetail.backgroundColor=[UIColor whiteColor];
            [_viewSuggestion addSubview:viewDetail];
            
            //title
            NSInteger iLblTitleH=35;
            UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewDetail.frame), iLblTitleH)];
            lblTitle.textColor=[UIColor whiteColor];
            lblTitle.textAlignment=NSTextAlignmentCenter;
            lblTitle.text=@"意见反馈";
            lblTitle.font=[UIFont systemFontOfSize:15];
            lblTitle.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
            [viewDetail addSubview:lblTitle];
            
            //backButton
            NSInteger iBtnBackW=35;
            UIButton *btnBack=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, iBtnBackW, iBtnBackW)];
            [btnBack setBackgroundImage:[UIImage imageNamed:@"modelViewBack.png"] forState:UIControlStateNormal];
            [btnBack addTarget:self action:@selector(hideSuggestionView) forControlEvents:UIControlEventTouchUpInside];
            [viewDetail addSubview:btnBack];
            
            //btn save
            NSInteger iBtnSaveOperateW=50;
            UIButton *btnSaveOperate=[[UIButton alloc] initWithFrame:CGRectMake( CGRectGetWidth(viewDetail.frame)-iBtnSaveOperateW, 0,iBtnSaveOperateW,iLblTitleH)];
            btnSaveOperate.titleLabel.font=[UIFont systemFontOfSize:15];
            btnSaveOperate.backgroundColor=[UIColor clearColor];
            [btnSaveOperate setTitle:@"保存" forState:UIControlStateNormal];
            [btnSaveOperate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnSaveOperate addTarget:self action:@selector(didBtnSaveSuggestion) forControlEvents:UIControlEventTouchUpInside];
            [viewDetail addSubview:btnSaveOperate];
            
            //txtView
            NSInteger iTxtviewGap=10;
            NSInteger iTxtSuggestionH=iViewDetailH-iLblTitleH*2-iTxtviewGap*2;
            _txtSuggestion=[[UITextView alloc] initWithFrame:CGRectMake(iTxtviewGap,iTxtviewGap+iLblTitleH,CGRectGetWidth(viewDetail.frame)-iTxtviewGap*2,iTxtSuggestionH)];
            _txtSuggestion.textColor=[UIColor darkGrayColor];
            _txtSuggestion.text=@"";
            _txtSuggestion.font=[UIFont systemFontOfSize:15];
            _txtSuggestion.backgroundColor=[UIColor whiteColor];
            _txtSuggestion.layer.borderWidth=1.0;
            _txtSuggestion.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            _txtSuggestion.keyboardType=UIKeyboardTypeDefault;
            _txtSuggestion.delegate=self;
            [viewDetail addSubview:_txtSuggestion];
            
             //txtemail
            UIView *viewEmail=[[UIView alloc] initWithFrame:CGRectMake(iTxtviewGap, iViewDetailH-iLblTitleH, CGRectGetWidth(viewDetail.frame)-iTxtviewGap*2, iLblTitleH)];
            [viewDetail addSubview:viewEmail];
            
            NSInteger iLblEmailTitleW=65;
            UILabel *lblEmailTitle=[[UILabel alloc] initWithFrame:CGRectMake(0,0,iLblEmailTitleW, iLblTitleH)];
            lblEmailTitle.textColor=[UIColor darkGrayColor];
            lblEmailTitle.textAlignment=NSTextAlignmentLeft;
            lblEmailTitle.text=@"邮    箱:";
            lblEmailTitle.font=[UIFont systemFontOfSize:15];
            [viewEmail addSubview:lblEmailTitle];
            
            NSInteger iTxtSuggestionEmailH=30;
            _txtSuggestionEmail=[[UITextField alloc] initWithFrame:CGRectMake(iLblEmailTitleW, (iLblTitleH-iTxtSuggestionEmailH)/2, CGRectGetWidth(viewEmail.frame)-iLblEmailTitleW, iTxtSuggestionEmailH)];
            _txtSuggestionEmail.font=[UIFont systemFontOfSize:15];
            _txtSuggestionEmail.layer.borderWidth=1.0;
            _txtSuggestionEmail.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            _txtSuggestionEmail.clearButtonMode=UITextFieldViewModeWhileEditing;
            _txtSuggestionEmail.delegate=self;
            [viewEmail addSubview:_txtSuggestionEmail];
        }else{
            //关于
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            
            UIViewController *aboutView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerMyAbout"];
            [self.navigationController pushViewController:aboutView animated:YES];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要退出并注销登录吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return 1;
            break;
        }case 1:{
            return 3;
            break;
        }
        default:{
            return 1;
            break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return KRowHeightPersion;
    }else{
        return KRowHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (cell) {
        switch (indexPath.section) {
            case 0:{
                //个人信息
                //头像
                //图标
                NSInteger iLeftGap=15;
                NSInteger iIconSize=40;
                
                NSString *sPhoto=[SystemPlist GetPhoto];
                NSString *sBelognName=[SystemPlist GetLoadUser];
                
                _imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KRowHeightPersion-iIconSize)/2, iIconSize, iIconSize)];
                _imageFileIcon.hidden=YES;
                [cell.contentView addSubview:_imageFileIcon];
                
                _lblIcon=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap,(KRowHeightPersion-iIconSize)/2, iIconSize, iIconSize)];
                _lblIcon.textAlignment=NSTextAlignmentCenter;
                _lblIcon.numberOfLines=0;
                _lblIcon.hidden=YES;
                _lblIcon.text=[[[sBelognName componentsSeparatedByString:@"@"] firstObject] substringFromIndex:[[sBelognName componentsSeparatedByString:@"@"] firstObject].length-1];
                _lblIcon.font= [UIFont systemFontOfSize:22];
                _lblIcon.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
                _lblIcon.textColor=[UIColor whiteColor];
                [cell.contentView addSubview:_lblIcon];

                //头像，如果头像为空，就用名字的最后一个字符代替
                if (![sPhoto isEqualToString:@""]) {
                    NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sPhoto options:0];
                    _imageFileIcon.hidden=NO;
                    _imageFileIcon.image=[UIImage imageWithData:photoData];
                }else{
                    _lblIcon.hidden=NO;
                    _lblIcon.text=[[[sBelognName componentsSeparatedByString:@"@"] firstObject] substringFromIndex:[[sBelognName componentsSeparatedByString:@"@"] firstObject].length-1];
                }
                //名称
                NSInteger iLabelH=30;
                NSInteger iLabelW=85;
                UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize,0, iLabelW, iLabelH)];
                lblName.textAlignment=NSTextAlignmentLeft;
                lblName.text=[[sBelognName componentsSeparatedByString:@"@"] firstObject];
                lblName.font= [UIFont systemFontOfSize:15];
                lblName.textColor=[UIColor darkGrayColor];
                [cell.contentView addSubview:lblName];
                //所属用户
                UILabel *lblDelong=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize,iLabelH, iLabelW, iLabelH)];
                lblDelong.textAlignment=NSTextAlignmentLeft;
                lblDelong.text=sBelognName;
                lblDelong.font= [UIFont systemFontOfSize:15];
                lblDelong.textColor=[UIColor darkGrayColor];
                [cell.contentView addSubview:lblDelong];
                
                //箭头
                NSInteger iIconCorrorW=10;
                NSInteger iIconCorrorH=15;
                UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-iLeftGap-iIconCorrorW,(KRowHeightPersion-iIconCorrorH)/2, iIconCorrorW, iIconCorrorH)];
                imageCorror.image=[UIImage imageNamed:@"list_arrowright_grey.png"];
                [cell.contentView addSubview:imageCorror];

                break;
            }case 1:{

                NSString *sIconName;
                NSString *sTitle;
                
                if (indexPath.row==0) {
                    sIconName=@"my_check.png";
                    sTitle=@"检查新版本";
                }else if (indexPath.row==1){
                    sIconName=@"my_suggest.png";
                    sTitle=@"意见反馈";
                }else{
                    sIconName=@"my_about.png";
                    sTitle=@"关于";
                }
                
                NSInteger iLeftGap=15;
                NSInteger iIconSize=20;
                UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KRowHeight-iIconSize)/2, iIconSize, iIconSize)];
                imageFileIcon.image=[UIImage imageNamed:sIconName];
                [cell.contentView addSubview:imageFileIcon];

                NSInteger iLabelH=30;
                NSInteger iLabelW=85;
                UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize,0, iLabelW, iLabelH)];
                lblTitle.textAlignment=NSTextAlignmentLeft;
                lblTitle.text=sTitle;
                lblTitle.font= [UIFont systemFontOfSize:15];
                lblTitle.textColor=[UIColor darkGrayColor];
                [cell.contentView addSubview:lblTitle];
                
                NSInteger iIconCorrorW=10;
                NSInteger iIconCorrorH=15;
                UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-iLeftGap-iIconCorrorW,(KRowHeight-iIconCorrorH)/2, iIconCorrorW, iIconCorrorH)];
                imageCorror.image=[UIImage imageNamed:@"list_arrowright_grey.png"];
                [cell.contentView addSubview:imageCorror];
               
                break;
            }
            default:{
                 NSInteger iLeftGap=15;
                UILabel *lblExit=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap,0, CGRectGetWidth(tableView.frame)-iLeftGap*2, KRowHeight)];
                lblExit.textAlignment=NSTextAlignmentCenter;
                lblExit.text=@"退出登录";
                lblExit.font= [UIFont systemFontOfSize:15];
                lblExit.textColor=[UIColor redColor];
                //lblActionDetail.backgroundColor=[UIColor redColor];
                [cell.contentView addSubview:lblExit];
                
                break;
            }
        }
        
    }
    return cell;
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        //退出
        [SystemPlist SetLogin:NO];
        [PublicFunc ShowSuccessHUD:@"退出成功" view:self.view];
        [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
    }
}
-(void)dismissView{
    exit(0);
}

#pragma mark 保存个人信息后刷新个人icon
- (void)updateIconImage{
    
    NSString *sPhoto=[SystemPlist GetPhoto];
    NSString *sBelognName=[SystemPlist GetLoadUser];
    
    //头像，如果头像为空，就用名字的最后一个字符代替
    if (![sPhoto isEqualToString:@""]) {
        NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sPhoto options:0];
        _lblIcon.hidden=YES;
        _imageFileIcon.hidden=NO;
        _imageFileIcon.image=[UIImage imageWithData:photoData];
    }else{
        _imageFileIcon.hidden=YES;
        _lblIcon.hidden=NO;
        _lblIcon.text=[[[sBelognName componentsSeparatedByString:@"@"] firstObject] substringFromIndex:[[sBelognName componentsSeparatedByString:@"@"] firstObject].length-1];
    }
}

#pragma mark 保存意见
- (void)didBtnSaveSuggestion{
    if (_txtSuggestion.text.length==0) {
        [PublicFunc ShowSimpleHUD:@"请输入您要反馈的内容" view:self.view];
        [_txtSuggestion becomeFirstResponder];
        return;
    }else if (_txtSuggestionEmail.text.length==0){
        [PublicFunc ShowSimpleHUD:@"请输入您的邮箱地址" view:self.view];
        [_txtSuggestionEmail becomeFirstResponder];
        return;
    }else if (_txtSuggestionEmail.text.length>0 && ![PublicFunc isValidateEmail:_txtSuggestionEmail.text]){
        [PublicFunc ShowSimpleHUD:@"邮箱格式不正确" view:self.view];
        [_txtSuggestionEmail becomeFirstResponder];
        return;
    }
    //关闭键盘
    [self disKeyboard];
    
    [ClassMy saveFeedbackInfoWithEmail:_txtSuggestionEmail.text content:_txtSuggestion.text userName:[SystemPlist GetLoadUser] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [PublicFunc ShowSuccessHUD:@"保存成功" view:self.view];
            [self performSelector:@selector(hideSuggestionView) withObject:nil afterDelay:1.5];
        }
    }];
}

#pragma-mark Uitextfiled事件
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = _viewSuggestion.frame.size.width;
    float height = _viewSuggestion.frame.size.height;
    //上移100个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-100.0f,width,height);
    _viewSuggestion.frame=rect;
    [UIView commitAnimations];
    return YES;
}
//键盘消失事件
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]) {
//        _viewSuggestion.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//        [textView resignFirstResponder];
//        return YES;
//    }
    
    return YES;
}

#pragma mark 键盘事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    _viewSuggestion.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self disKeyboard];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = _viewSuggestion.frame.size.width;
    float height = _viewSuggestion.frame.size.height;
    //上移100个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-100.0f,width,height);
    _viewSuggestion.frame=rect;
    [UIView commitAnimations];
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    _viewSuggestion.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [_txtSuggestion resignFirstResponder];
    [_txtSuggestionEmail resignFirstResponder];
}

@end
