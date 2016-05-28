//
//  UIViewControllerSearchInfo.h
//  ttbrz
//
//  Created by apple on 16/3/27.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZTextField.h"
#import "ClassSearchAndMessage.h"
#import "UIViewControllerPlanTask.h"

@interface UIViewControllerSearchInfo : UIViewController<UITextFieldDelegate>
- (IBAction)didBtnSearch:(id)sender;

- (IBAction)didBtnControl_Log:(id)sender;
- (IBAction)didBtnControl_File:(id)sender;
- (IBAction)didBtnControl_Task:(id)sender;



@end
