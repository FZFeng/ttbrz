//
//  FZTextField.h
//  GoTogether
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LeftIconTypeUser = 0,
    LeftIconTypePwd,
}LeftIconType;

@interface FZTextField : UITextField<UITextFieldDelegate>{

    UIButton *doneInKeyboardButton;
}
//输入前的提示
@property(nonatomic,strong)NSString *placeholderText;
//左边icon图标
@property(nonatomic)LeftIconType leftIcon;
//左边lable内容
@property(nonatomic,strong)NSString *lblLeftText;
//左边是lable还是icon默认为icon
@property(nonatomic)BOOL bNoLeftIcon;
//左边是lable是否出现
@property(nonatomic)BOOL bNoLeftLable;
//left label 的宽度
@property(nonatomic) int iLblLeftWidth;
//消失键盘时是否需要偏移位置
@property(nonatomic) BOOL bResetRectMake;

@end
