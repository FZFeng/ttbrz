//
//  UIViewControllerAddNewLog.m
//  ttbrz
//
//  Created by apple on 16/3/21.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerAddNewLog.h"

@interface UIViewControllerAddNewLog ()<UITextViewDelegate>{

    IBOutlet UILabel *_lblLogDate;
    IBOutlet UILabel *_lblLogConfirmUser;
    IBOutlet UITextView *_txtLogContent;
}

@end

@implementation UIViewControllerAddNewLog

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    if (self.bAddNewLog) {
        lblTitle.text=@"新建日志";
    }else{
        _txtLogContent.text=[self.sGetLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
        lblTitle.text=@"编辑日志";
    }
    
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;

    //保存
    UIButton *btnSaveLog=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,45,35)];
    btnSaveLog.titleLabel.font=[UIFont systemFontOfSize:16];
    btnSaveLog.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [btnSaveLog setTitle:@"保存" forState:UIControlStateNormal];
    [btnSaveLog setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSaveLog addTarget:self action:@selector(didBtnSaveLog) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SaveLogButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSaveLog];
    self.navigationItem.rightBarButtonItem=SaveLogButtonItem;

    
    //点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    [self.view addGestureRecognizer:singleTouch];
    
    
    _lblLogDate.text=self.sGetLogDate;
    _lblLogConfirmUser.text=self.sGetConfirmUser;
    
    _txtLogContent.layer.borderWidth=1.0;
    _txtLogContent.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _txtLogContent.layer.cornerRadius=5.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didBtnSaveLog{
    
    if (_txtLogContent.text.length==0) {
        [PublicFunc ShowNoticeHUD:@"日志内容不能为空" view:self.view];
        return;
    }
    
    if (self.bAddNewLog) {
        //新建
        [ClassLog createLogUserWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] logdate:self.sGetLogDate logcontent:_txtLogContent.text confirmuserguid:self.sGetConfirmUserID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"保存成功" view:self.view];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
            }
        }];
    }else{
        //编辑
        [ClassLog editLogUserWithLogID:self.sGetLogID confirmuserguid:self.sGetConfirmUserID logcontent:_txtLogContent.text fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                [PublicFunc ShowSuccessHUD:@"保存成功" view:self.view];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
            }
        }];
    }
   
    
}

-(void)dismissView{
    UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerMyLog *myLogView=[rootTabBarView.viewControllers objectAtIndex:0];
    [myLogView initTodayLogData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma-mark Uitextfiled事件
//键盘消失事件
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [_txtLogContent resignFirstResponder];
}


@end
