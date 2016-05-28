//
//  FZTextField.m
//  GoTogether
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "FZTextField.h"

@implementation FZTextField


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    int iViewH=1;
    
    // Drawing code
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(rect)-iViewH, CGRectGetWidth(rect), iViewH)];
    view.alpha = 0.5;
    view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:view];
    
    self.textColor=[UIColor darkGrayColor];
    self.placeholder=_placeholderText;
    self.font = [UIFont systemFontOfSize:14];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.delegate=self;
    
    if (!_bNoLeftIcon) {
        UIView *iconV=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
        NSString *sLeftIcon=@"";
        if (_leftIcon==LeftIconTypeUser) {
            sLeftIcon=@"user";
        }else{
            sLeftIcon=@"pwd";
        }
        iconView.image=[UIImage imageNamed:sLeftIcon];
        iconView.clipsToBounds=YES;//如果不希望超过frame的区域显示在屏幕上要设置。clipsToBounds属性。
        iconView.contentMode=UIViewContentModeScaleAspectFill;//最好的显示方式
        [iconV addSubview:iconView];
        
        self.leftView = iconV;
        self.leftViewMode = UITextFieldViewModeAlways;
    }else{
        if (!_bNoLeftLable) {
            UILabel *lblLeft=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, _iLblLeftWidth, 25)];
            lblLeft.font=[UIFont systemFontOfSize:15];
            lblLeft.textColor=[UIColor grayColor];
            lblLeft.textAlignment=NSTextAlignmentCenter;
            lblLeft.backgroundColor= [UIColor clearColor];
            lblLeft.text=_lblLeftText;
            self.leftView = lblLeft;
        }
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
}


#pragma-mark Uitextfiled事件
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_bResetRectMake) {
        NSTimeInterval animationDuration=0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        float width = self.frame.size.width;
        float height = self.frame.size.height;
        //上移60个单位，按实际情况设置(兼容iPhone4S)
        CGRect rect=CGRectMake(0.0f,-60.0f,width,height);
        self.frame=rect;
        [UIView commitAnimations];
    }
    
    //增加数据键盘的完成Button
    /*
    if (textField.keyboardType==UIKeyboardTypeNumberPad) {
        [self performSelector:@selector(keywordboardShow) withObject:nil afterDelay:0.25];
    }*/
    return YES;
}

//键盘消失事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (_bResetRectMake) self.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [textField resignFirstResponder];
    return YES;
}
/*
//键盘显示添加"完成"
- (void)keywordboardShow{
    if (doneInKeyboardButton == nil){
        //初始化完成按钮
        doneInKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneInKeyboardButton.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-53, 106, 53);
        //在按钮被禁用时，图像会被画的颜色深一些
        doneInKeyboardButton.adjustsImageWhenHighlighted = NO;
        
        [doneInKeyboardButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        
        [doneInKeyboardButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneInKeyboardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    UIWindow* myWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if (doneInKeyboardButton.superview == nil){
        //完成按钮添加到window
        [myWindow addSubview:doneInKeyboardButton];
    }
}

//点击"完成"button
-(void)finishAction{
    //隐藏完成按钮
    if (doneInKeyboardButton.superview){
        //从视图中移除掉
        [doneInKeyboardButton removeFromSuperview];
    }
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //数字键盘失去焦点时清除"完成"button
    if (textField.keyboardType==UIKeyboardTypeNumberPad) {
       [self finishAction];
    }
    return YES;
}
  */

@end
