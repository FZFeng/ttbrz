//
//  UIViewControllerMessageCheck.m
//  ttbrz
//
//  Created by apple on 16/2/26.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerPhoneMessageCheck.h"

@interface UIViewControllerPhoneMessageCheck (){

    IBOutlet UILabel *_titleLable;
    IBOutlet UIButton *_getPhoneMessageButton;
    IBOutlet UIButton *_checkPhoneMessageButton;
    IBOutlet FZTextField *_phoneMessageFZTextField;
    IBOutlet UIButton *_backButton;
    
    FZNoticeView *_noticeView;
    NSTimer *waitTimer;
    int _iTimer;
    NSString *_codeString;
   
}

@end

@implementation UIViewControllerPhoneMessageCheck

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _getPhoneMessageButton.layer.cornerRadius =5.0;
    _checkPhoneMessageButton.layer.cornerRadius =5.0;
    
    _phoneMessageFZTextField.placeholderText=@"手机校验码";
    _phoneMessageFZTextField.bNoLeftIcon=YES;
    _phoneMessageFZTextField.bNoLeftLable=YES;
    
    NSString *myPhone=self.registerPhone;
    myPhone=[myPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    _titleLable.text=[NSString stringWithFormat:@"请输入手机%@收到的短信校验码",myPhone];
    
    //发送短信
    [self sendVerificationCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didCheckPhoneMessageButton:(id)sender {
    
    //验证信息输入的有效性
    if (!_noticeView) {
        _noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:NO];
    }
    
    if (_phoneMessageFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入手机校验码"];
        [_phoneMessageFZTextField becomeFirstResponder];
    }else{
        //验码手机验证码
        if (![_phoneMessageFZTextField.text isEqualToString:_codeString]) {
            [_noticeView showWithNotice:@"手机校验码不正确"];
            [_phoneMessageFZTextField becomeFirstResponder];
            return;
        }
        //新用户注册
        [ClassUser registerUserWithEmail:self.registerEmail groupName:self.registerTeamName mobiTel:self.registerPhone pwd:self.registerPwd fatherObject:self returnBlock:^(BOOL bReturnBlock) {
            if (bReturnBlock) {
                //关闭窗体并设置回调
                [self dismissViewControllerAnimated:YES completion:^{
                    UIViewControllerUserRegister *userRegisterUIView = [self.navigationController.viewControllers firstObject];
                    [userRegisterUIView.delegate didUserRegisterFinished];
                }];
            }
        }];

    }

}

#pragma mark 获取手机验证码
- (IBAction)didGetPhoneMessageButton:(id)sender {
    [self sendVerificationCode];
}

//发送手机验证码
- (void)sendVerificationCode{
    _iTimer=60;
    waitTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitRegistCode) userInfo:nil repeats:YES];
    [waitTimer fire];
    
    
    //获取6位 0-9 之间的随机数字
    for (int i=0; i<=5; i++) {
        int iValue =arc4random_uniform(10);
        if (i==0) {
            _codeString=[NSString stringWithFormat:@"%d",iValue];
        }else{
            _codeString=[_codeString stringByAppendingString:[NSString stringWithFormat:@"%d",iValue]];
        }
    }
    //调用接口
    [ClassUser sendPhoneCodeWithMobiTel:self.registerPhone phoneCode:_codeString returnBlock:^(BOOL bReturnBlock) {
        if (!bReturnBlock) {
            [_getPhoneMessageButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
            [waitTimer invalidate];
        }
    }];
}

-(void)waitRegistCode{
    if (_iTimer>0) {
        _iTimer--;
        [_getPhoneMessageButton setTitle:[NSString stringWithFormat:@"%d秒后再获取",_iTimer] forState:UIControlStateNormal];
        _getPhoneMessageButton.userInteractionEnabled=NO;
    }else{
        _getPhoneMessageButton.userInteractionEnabled=YES;
        [_getPhoneMessageButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [waitTimer invalidate];
    }
}
@end
