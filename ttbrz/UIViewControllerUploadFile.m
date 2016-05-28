//
//  UIViewControllerUploadFile.m
//  ttbrz
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerUploadFile.h"

#define sSuccess             @"操作成功"
#define sFailed              @"操作失败"
#define sWaiting             @"正在处理中..."
#define sError_Connection    @"网络连接错误"
#define sError_Timeout       @"网络连接超时"
#define sError_GetData       @"获取网络数据错误"
#define sError_upload        @"上传文件错误"
#define sSSOLoadError        @"授权失败"
#define iTimeoutForPost      30.0

@interface UIViewControllerUploadFile (){

    IBOutlet UIProgressView *_upLoadFileProgress;

    IBOutlet UIView *_viewProgress;
    IBOutlet UILabel *_lblProgressValue;
    IBOutlet UILabel *_lblFileName;
}

@end

@implementation UIViewControllerUploadFile

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"上传文件";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didBtnLocalImage:(id)sender {
    [self showPhotoLibrary];
}

- (IBAction)didBtnCammerImage:(id)sender {
    [self showCameraDeviceRear];
}

- (IBAction)didBtnLocalFile:(id)sender {
    UIViewControllerDownloadFile *downloadFileView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerDownloadFile"];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:downloadFileView animated:YES];
}

#pragma mark 启动相册
-(void)showPhotoLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]==NO) {
        //提示要访问设备
        NSLog(@"设备相机功能不能启动");
        return;
    }
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing=YES;
    imagePicker.delegate=self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark 启动相机
-(void)showCameraDeviceRear{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO) {
        //提示要访问设备
        NSLog(@"设备相机功能不能启动");
        return;
    }
    
    // 前面的摄像头是否可用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]==NO) {
        NSLog(@"前摄像头不可用");
        return;
    }
    
    // 后面的摄像头是否可用
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]==NO) {
        NSLog(@"后摄像头不可用");
        return;
    }
    
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    
    //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
    imagePicker.showsCameraControls  = YES;
    
    //设置闪光灯模式
    /*
     typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraFlashMode) {
     UIImagePickerControllerCameraFlashModeOff  = -1,
     UIImagePickerControllerCameraFlashModeAuto = 0,
     UIImagePickerControllerCameraFlashModeOn   = 1
     };
     */
    
    imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    
    imagePicker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    //设置当拍照完或在相册选完照片后，是否跳到编辑模式进行图片剪裁。只有当showsCameraControls属性为true时才有效果
    imagePicker.allowsEditing = NO;
    imagePicker.delegate=self;
    
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark UIImagePickerController 回调--取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//UIImagePickerController 回调--选中相片
/*
 NSString *const UIImagePickerControllerMediaType;         选取的类型 public.image  public.movie
 NSString *const UIImagePickerControllerOriginalImage;    修改前的UIImage object.
 NSString *const UIImagePickerControllerEditedImage;      修改后的UIImage object.
 NSString *const UIImagePickerControllerCropRect; 原始图片的尺寸NSValue object containing a CGRect data type
 NSString *const UIImagePickerControllerMediaURL;          视频在文件系统中 的 NSURL地址
 保存视频主要时通过获取其NSURL 然后转换成NSData
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //只是图片类型
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *getImage=nil;
        
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            getImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            getImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        NSData *getImageData;
        NSString *sFileName=[PublicFunc getRandomGUID];
         if (UIImagePNGRepresentation(getImage) == nil) {
             getImageData = UIImageJPEGRepresentation(getImage, 1.0f);
             sFileName=[sFileName stringByAppendingString:@".jpg"];
         } else {
             getImageData = UIImagePNGRepresentation(getImage);
             sFileName=[sFileName stringByAppendingString:@".png"];
         }
        
        [self upLoadWithFileName:sFileName fileData:getImageData];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissView{
    UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerMyLog *myLogView=[rootTabBarView.viewControllers objectAtIndex:0];
    [myLogView initTodayLogData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 上传文件/图片过程
- (void)upLoadWithFileName:(NSString*)sFileName fileData:(NSData*)fileData{
    
    NSString *sFilebase64Encoded = [fileData base64EncodedStringWithOptions:0];
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)sFilebase64Encoded,
                                                                                         NULL,
                                                                                         CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                         kCFStringEncodingUTF8);
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *sTodayDate = [dateFormatter stringFromDate:nowDate];
    
    NSString *sCompanyID=[SystemPlist GetCompanyID];
    NSString *sFilePath=[NSString stringWithFormat:@"/UpLoadFiles/%@/%@/%@",sCompanyID,sTodayDate,sFileName];
    
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaFileName=[NSString stringWithFormat:@"FileName=%@",sFileName];
    [arryInfo addObject:sParaFileName];
    
    NSString *sParaFile=[NSString stringWithFormat:@"File=%@",baseString];
    [arryInfo addObject:sParaFile];
    
    NSString *sParaTag=[NSString stringWithFormat:@"Tag=%d",0];
    [arryInfo addObject:sParaTag];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",sCompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaDataTime=[NSString stringWithFormat:@"DataTime=%@",sTodayDate];
    [arryInfo addObject:sParaDataTime];
    
    _viewProgress.hidden=NO;
    _lblFileName.text=sFileName;
    _lblFileName.lineBreakMode = NSLineBreakByTruncatingMiddle;//使用截取 在中间省略
    
    
    [self dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@UploadService/UpFile_App",KServerUrl_file] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                //调用另一api
                [ClassLog saveUpLoadFilePathWithLogDate:self.sGetLogDate FileName:sFileName FilePath:sFilePath UserID:[SystemPlist GetUserID] CompanyID:sCompanyID fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                    if (bReturn) {
                        [PublicFunc ShowSuccessHUD:@"上传成功" view:self.view];
                        [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
                    }
                }];
            }else{
                [PublicFunc ShowErrorHUD:[returnData objectForKey:@"Message"] view:self.view];
            }
        }else{
            [PublicFunc ShowErrorHUD:sError view:self.view];
        }
    }];


}

-(void)dataTaskWithUrlNoHUD:(NSString *)url arryPara:(NSArray*)arryPara requestMethodType:(requestMethodType)requestMethodType  block:(returnBlockNoHUD)block{
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        
        if (requestMethodType==requestMethodGet) {
            urlStr=[NSString stringWithFormat:@"%@?%@",url,sPara];
        }else if (requestMethodType==requestMethodPost){
            urlStr=url;
        }
    }else{
        urlStr=url;
    }
    
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //NSString 中包含中文字符时转换为NSURL
    //由于url支持26个英文字母、数字和少数几个特殊字符，因此，对于url中包含非标准url的字符时，就需要对其进行编码。iOS中提供了函数stringByAddingPercentEscapesUsingEncoding对中文和一些特殊字符进行编码，但是stringByAddingPercentEscapesUsingEncoding的功能并不完善，对一些较为特殊的字符无效。而对这些字符则可以使用CFURLCreateStringByteAddingPercentEscapes函数，
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    if (requestMethodType==requestMethodGet) {
        [request setHTTPMethod:@"Get"];
    }else if (requestMethodType==requestMethodPost){
        [request setHTTPMethod:@"POST"];
        //创建post参数
        NSData *bodyData=[sPara dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[self returnPublicSession:requestMethodType];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([sErrMsg isEqualToString:@""]) {
                block(dictReturn,sErrMsg);
            }else{
                block(nil,sErrMsg);
            }
        }];
    }];
    //恢复线程，启动任务
    [dataTask resume];
}

// 返回nsurlsession 对象
-(NSURLSession*)returnPublicSession:(requestMethodType)requestMethodType{
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    //post 方式的时间会长一点
    sessionConfig.timeoutIntervalForRequest=iTimeoutForPost;
    sessionConfig.timeoutIntervalForResource=iTimeoutForPost;
    
    sessionConfig.allowsCellularAccess=YES;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    //[NSURLSession sessionWithConfiguration:sessionConfig];
    
    return session;
}

// 上传进度中 (会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    //bytesSent                 每次理论上传的数据
    //totalBytesSent            每次实际上传的数据
    //totalBytesExpectedToSend  每次要上传的总数据
    //在主线程中更新UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _lblProgressValue.text=[NSString stringWithFormat:@"%0.0f%%", ((double)totalBytesSent / (double)totalBytesExpectedToSend)*100];
        _upLoadFileProgress.progress = totalBytesSent/(float)totalBytesExpectedToSend;
    }];
    
}

// 上传完成，不管是否下载成功
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        //[FZNetworkHelper shared].bTaskSuccess=NO;
        //[FZNetworkHelper shared].bTaskWaitting=NO;
        
        //[[FZNetworkHelper shared].taskUpLoadMultiFile cancel];
        
        NSLog(@"Error is:%@",error.localizedDescription);
    }
}



@end
