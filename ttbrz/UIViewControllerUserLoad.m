//
//  UIViewControllerUserLoad.m
//  ttbrz
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerUserLoad.h"



@interface UIViewControllerUserLoad ()<UITextFieldDelegate,UIViewControllerUserRegisterDelegate>{
    FZNoticeView *_noticeView;
}



@end

@implementation UIViewControllerUserLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userNameFZTextField.placeholderText=@"手机号码|邮箱|企业帐号";
    self.userNameFZTextField.bNoLeftIcon=YES;
    self.userNameFZTextField.bNoLeftLable=YES;
    self.userNameFZTextField.delegate=self;
    
    self.userPwdFZTextField.placeholderText=@"密码";
    self.userPwdFZTextField.bNoLeftIcon=YES;
    self.userPwdFZTextField.bNoLeftLable=YES;
    self.userPwdFZTextField.delegate=self;
    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 用户登录
- (IBAction)didUserLoadButton:(id)sender {
    
    //验证信息输入的有效性
    if (!_noticeView) {
        _noticeView=[[FZNoticeView alloc] initWithReferView:self.view bHasNavItem:NO];
    }
    
    if (self.userNameFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 手机号码|邮箱|企业帐号"];
        [self.userNameFZTextField becomeFirstResponder];
        return;
    }else if (self.userPwdFZTextField.text.length==0){
        [_noticeView showWithNotice:@"请输入 密码"];
        [self.userPwdFZTextField becomeFirstResponder];
        return;
    }
    //关闭键盘
    [self disKeyboard];
    
    //去服务器验证用户的有效性
    [ClassUser checkUserAndGetDataWithID:self.userNameFZTextField.text sPwd:self.userPwdFZTextField.text fatherObject:self returnBlock:^(BOOL bReturn, ClassUser *cUserObject) {
        if (bReturn) {
            //保存数据到systemplist中
            [SystemPlist SetLogin:YES];
            //保存数据到systemplist中
            [SystemPlist SetLoadUser:self.userNameFZTextField.text];
            [SystemPlist SetLoadPwd:self.userPwdFZTextField.text];
            
            [self.delegate didUserLoadFinished];
        }
    }];
}

#pragma mark 新用户注册
- (IBAction)didUserRegistButton:(id)sender {
    UINavigationController *navRegister = [self.storyboard instantiateViewControllerWithIdentifier:@"UINavigationUserRegister"];
   
    UIViewControllerUserRegister *userRegisterUIView = [navRegister.viewControllers firstObject];
    userRegisterUIView.delegate=self;
    
    [self presentViewController:navRegister animated:YES completion:nil];
    
}
#pragma mark UIViewControllerPhoneMessageCheck 回调
- (void)didUserRegisterFinished{
    self.userNameFZTextField.text=[SystemPlist GetLoadUser];
    self.userPwdFZTextField.text=[SystemPlist GetLoadPwd];
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [self.userNameFZTextField resignFirstResponder];
    [self.userPwdFZTextField resignFirstResponder];
}

@end
