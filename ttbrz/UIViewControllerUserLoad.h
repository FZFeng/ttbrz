//
//  UIViewControllerUserLoad.h
//  ttbrz
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:用户登录

#import <UIKit/UIKit.h>
#import "FZNoticeView.h"
#import "FZTextField.h"
#import "ClassUser.h"

#import "UIViewControllerUserRegister.h"

@protocol UIViewControllerUserLoadDelegate

- (void)didUserLoadFinished;

@end

@interface UIViewControllerUserLoad : UIViewController

@property (strong, nonatomic) IBOutlet FZTextField *userNameFZTextField;

@property (strong, nonatomic) IBOutlet FZTextField *userPwdFZTextField;

@property (weak,nonatomic) id<UIViewControllerUserLoadDelegate> delegate;


- (IBAction)didUserLoadButton:(id)sender;

- (IBAction)didUserRegistButton:(id)sender;

@end
