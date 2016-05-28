//
//  UIViewControllerUploadFile.h
//  ttbrz
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerMyLog.h"
#import "UIViewControllerDownloadFile.h"
#import "ClassLog.h"
#import "PublicFunc.h"
#import "ClassLog.h"

@interface UIViewControllerUploadFile : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,NSURLSessionTaskDelegate,NSURLSessionTaskDelegate>
- (IBAction)didBtnLocalImage:(id)sender;
- (IBAction)didBtnCammerImage:(id)sender;
- (IBAction)didBtnLocalFile:(id)sender;

@property (nonatomic,strong)NSString *sGetLogDate;

//上传文件
- (void)upLoadWithFileName:(NSString*)sFileName  fileData:(NSData*)fileData;
@end
