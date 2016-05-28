//
//  UIViewControllerMyAbout.m
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMyAbout.h"

@interface UIViewControllerMyAbout (){

    IBOutlet UILabel *_lblVersion;
    IBOutlet UILabel *_lblCopyright;
}

@end

@implementation UIViewControllerMyAbout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];      //获取项目版本号
    _lblVersion.text=[NSString stringWithFormat:@"天天报 %@",version];
    
    //获取当前年份
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
     NSString *sYear=[[[dateFormatter stringFromDate:nowDate] componentsSeparatedByString:@"-"] firstObject];
    _lblCopyright.text=[NSString stringWithFormat:@"Copyright ©2013-%@ ttbrz.cn",sYear];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didBtnlinese:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ttbrz.cn/yssm/"]];
}

- (IBAction)didBtnWelcome:(id)sender {
    UIViewControllerFirstAd *welcomeView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewFirstAd"];
    welcomeView.bFromAbout=YES;
    [self presentViewController:welcomeView animated:YES completion:nil];

}
@end
