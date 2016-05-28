//
//  UIViewControllerUserRegister.m
//  ttbrz
//
//  Created by apple on 16/2/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerUserRegister.h"

@interface UIViewControllerUserRegister ()<UITextFieldDelegate>{

    BOOL _bChcekClause;
    
    IBOutlet FZTextField *_phoneFZTextField;
    IBOutlet FZTextField *_teamNameFZTextField;
    IBOutlet FZTextField *_emailFZTextField;
    IBOutlet FZTextField *_pwdFZTextField;
    IBOutlet FZTextField *_confimPwdFZTextField;
    IBOutlet UIView *_clauseView;
    
   
    IBOutlet UIButton *_checkButton;
    
    FZNoticeView *_noticeView;
    
}

@end

@implementation UIViewControllerUserRegister

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _phoneFZTextField.placeholderText=@"";
    _phoneFZTextField.bNoLeftIcon=YES;
    _phoneFZTextField.iLblLeftWidth=65;
    _phoneFZTextField.lblLeftText=@"手 机 号";
    
    _teamNameFZTextField.placeholderText=@"";
    _teamNameFZTextField.bNoLeftIcon=YES;
    _teamNameFZTextField.iLblLeftWidth=65;
    _teamNameFZTextField.lblLeftText=@"团队名称";
    
    _emailFZTextField.placeholderText=@"请如实填写,用于找回密码";
    _emailFZTextField.bNoLeftIcon=YES;
    _emailFZTextField.iLblLeftWidth=65;
    _emailFZTextField.lblLeftText=@"邮      箱";
    
    _pwdFZTextField.placeholderText=@"";
    _pwdFZTextField.bNoLeftIcon=YES;
    _pwdFZTextField.iLblLeftWidth=65;
    _pwdFZTextField.lblLeftText=@"密      码";
    
    _confimPwdFZTextField.placeholderText=@"";
    _confimPwdFZTextField.bNoLeftIcon=YES;
    _confimPwdFZTextField.iLblLeftWidth=65;
    _confimPwdFZTextField.lblLeftText=@"确认密码";
    
    _checkButton.accessibilityLabel=@"Off";
    _bChcekClause=NO;
    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];

       
}

- (IBAction)didRegistNowButton:(id)sender {

    //验证信息输入的有效性
    if (!_noticeView) {
        _noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:NO];
    }
    
    if (!_bChcekClause) {
        [_noticeView showWithNotice:@"确认同意服务条款及隐私声明后才能注册!"];
        return;
    }else if (_phoneFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 手机号"];
        [_phoneFZTextField becomeFirstResponder];
        return;
    }else if (![PublicFunc checkTelNumber:_phoneFZTextField.text]) {
        [_noticeView showWithNotice:@"手机号格式不正确"];
        [_phoneFZTextField becomeFirstResponder];
        return;
    }else if (_teamNameFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 团队名称"];
        [_teamNameFZTextField becomeFirstResponder];
        return;
    }else if (_emailFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 邮箱"];
        [_emailFZTextField becomeFirstResponder];
        return;
    }else if (![PublicFunc isValidateEmail:_emailFZTextField.text]){
        [_noticeView showWithNotice:@"邮箱格式不正确"];
        [_emailFZTextField becomeFirstResponder];
        return;
    }else if (_pwdFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 密码"];
        [_pwdFZTextField becomeFirstResponder];
        return;
    }else if (_pwdFZTextField.text.length<6 || _pwdFZTextField.text.length>20){
        [_noticeView showWithNotice:@"请输入 6位到20位的密码"];
        [_pwdFZTextField becomeFirstResponder];
        return;
    }else if (![_confimPwdFZTextField.text isEqualToString:_pwdFZTextField.text]){
        [_noticeView showWithNotice:@"两次输入密码不一致"];
        [_confimPwdFZTextField becomeFirstResponder];
        return;
    }
    //关闭键盘
    [self disKeyboard];
    
    //新注册
    [ClassUser validUserWithEmail:_emailFZTextField.text groupName:_teamNameFZTextField.text mobiTel:_phoneFZTextField.text fatherObject:self returnBlock:^(BOOL bReturnBlock) {
        if (bReturnBlock) {
            UIViewControllerPhoneMessageCheck *phoneMessageCheckUIView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewPhoneMessageCheck"];
            phoneMessageCheckUIView.registerEmail=_emailFZTextField.text;
            phoneMessageCheckUIView.registerTeamName=_teamNameFZTextField.text;
            phoneMessageCheckUIView.registerPhone=_phoneFZTextField.text;
            phoneMessageCheckUIView.registerPwd=_pwdFZTextField.text;
            [self.navigationController pushViewController:phoneMessageCheckUIView animated:YES];
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 是否选中条款
- (IBAction)didCheckButton:(id)sender {
    
    UIButton *btnObject=sender;
    if ([btnObject.accessibilityLabel isEqualToString:@"On"]) {
        _bChcekClause=NO;
        _checkButton.accessibilityLabel=@"Off";
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"userRegister_checkOff"] forState:UIControlStateNormal];
    }else{
        _bChcekClause=YES;
        _checkButton.accessibilityLabel=@"On";
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"userRegister_checkOn"] forState:UIControlStateNormal];
    }
}

#pragma mark 服务条款
- (IBAction)didServerClauseButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ttbrz.cn/fwtk/"]];
}

#pragma mark 隐私声明
- (IBAction)didPrivateClauseButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ttbrz.cn/yssm/"]];
}

- (IBAction)didCloseRegisterButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [_phoneFZTextField resignFirstResponder];
    [_teamNameFZTextField resignFirstResponder];
    [_emailFZTextField resignFirstResponder];
    [_pwdFZTextField resignFirstResponder];
    [_confimPwdFZTextField resignFirstResponder];
}
@end
