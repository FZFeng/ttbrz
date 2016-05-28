//
//  UIViewControllerUserRegister.h
//  ttbrz
//
//  Created by apple on 16/2/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZNoticeView.h"
#import "FZTextField.h"
#import "ClassUser.h"
#import "UIViewControllerPhoneMessageCheck.h"

@protocol UIViewControllerUserRegisterDelegate

- (void)didUserRegisterFinished;

@end


@interface UIViewControllerUserRegister : UIViewController


@property (weak,nonatomic) id<UIViewControllerUserRegisterDelegate> delegate;

- (IBAction)didCheckButton:(id)sender;

- (IBAction)didServerClauseButton:(id)sender;

- (IBAction)didPrivateClauseButton:(id)sender;

- (IBAction)didCloseRegisterButton:(id)sender;

- (IBAction)didRegistNowButton:(id)sender;

@end
