//
//  UIViewControllerMessageCheck.h
//  ttbrz
//
//  Created by apple on 16/2/26.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:短信验证

#import <UIKit/UIKit.h>
#import "FZTextField.h"
#import "FZNoticeView.h"
#import "ClassUser.h"
#import "UIViewControllerUserRegister.h"


@interface UIViewControllerPhoneMessageCheck : UIViewController


- (IBAction)didBackButton:(id)sender;
- (IBAction)didCheckPhoneMessageButton:(id)sender;
- (IBAction)didGetPhoneMessageButton:(id)sender;

@property (strong,nonatomic) NSString *registerEmail;
@property (strong,nonatomic) NSString *registerTeamName;
@property (strong,nonatomic) NSString *registerPhone;
@property (strong,nonatomic) NSString *registerPwd;

@end
