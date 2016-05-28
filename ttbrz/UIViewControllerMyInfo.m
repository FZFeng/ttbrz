//
//  UIViewControllerMyInfo.m
//  ttbrz
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerMyInfo.h"
#define KRowHeightPersion  60
#define KRowHeight  40

@interface UIViewControllerMyInfo()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {

    UITextField *_txtEmail;
    UITextField *_txtNewPwd;
    UITextField *_txtConfirmPwd;
    IBOutlet UITableView *_tbView;
    
    NSData *_dataSelectImg;
    UILabel *_lblIcon;
    UIImageView *_imageFileIcon;
}

@end

@implementation UIViewControllerMyInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"个人信息";
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
    [btnSaveLog addTarget:self action:@selector(didBtnSaveUserInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SaveLogButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSaveLog];
    self.navigationItem.rightBarButtonItem=SaveLogButtonItem;
    
    _tbView.scrollEnabled=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 保存用户修改信息
- (void)didBtnSaveUserInfo{
    
    if (_txtEmail.text.length>0 && ![PublicFunc isValidateEmail:_txtEmail.text]){
        [PublicFunc ShowSimpleHUD:@"邮箱格式不正确" view:self.view];
        [_txtEmail becomeFirstResponder];
        return;
    }else if (_txtNewPwd.text.length>0 && ( _txtNewPwd.text.length<6 || _txtNewPwd.text.length>20)){
        [PublicFunc ShowSimpleHUD:@"请输入 6位到20位的密码" view:self.view];
        [_txtNewPwd becomeFirstResponder];
        return;
    }else if (![_txtConfirmPwd.text isEqualToString:_txtNewPwd.text]){
        [PublicFunc ShowSimpleHUD:@"两次输入密码不一致" view:self.view];
        [_txtConfirmPwd becomeFirstResponder];
        return;
    }
    //关闭键盘
    [self disKeyboard];
    
    //保存数据
    NSString *sFilebase64Encoded;
    NSString *baseString;
    if (_dataSelectImg && _dataSelectImg.length>0) {
        sFilebase64Encoded = [_dataSelectImg base64EncodedStringWithOptions:0];
    }else{
        sFilebase64Encoded=[SystemPlist GetPhoto];
    }
    
    baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                               (CFStringRef)sFilebase64Encoded,
                                                                               NULL,
                                                                               CFSTR(":/?#[]@!$&’()*+,;="),
                                                                               kCFStringEncodingUTF8);

    
    [ClassMy saveMyInfoWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] pwd:_txtConfirmPwd.text photo:baseString email:_txtEmail.text fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            [SystemPlist SetMail:_txtEmail.text];
            [SystemPlist SetPhoto:sFilebase64Encoded];
            [SystemPlist SetLoadPwd:_txtConfirmPwd.text];
            [PublicFunc ShowSuccessHUD:@"保存成功" view:self.view];
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
        }
    }];

}

#pragma mark 保存后返回上级菜单
- (void)dismissView{
    UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerMy *myView=[rootTabBarView.viewControllers objectAtIndex:3];
    [myView updateIconImage];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 键盘事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self disKeyboard];
    return YES;
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [_txtEmail resignFirstResponder];
    [_txtNewPwd resignFirstResponder];
    [_txtConfirmPwd resignFirstResponder];
}

#pragma mark UITableview Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        //上传头像
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:@"选择图片" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self showPhotoLibrary];
            }];
            UIAlertAction *cameraDeviceRearAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self showCameraDeviceRear];
            }];
            
            [alertSelect addAction:cancelAction];
            [alertSelect addAction:photoLibraryAction];
            [alertSelect addAction:cameraDeviceRearAction];
            
            [self presentViewController:alertSelect animated:YES completion:nil];
        });
        
    }else if (indexPath.section==1) {
        if (indexPath.row==0) {
            //检查新版本
        }else if (indexPath.row==1){
            //意见反馈
        }else{
            //关于
            
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            
            UIViewController *aboutView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerMyAbout"];
            [self.navigationController pushViewController:aboutView animated:YES];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要退出并注销登录吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            return 1;
            break;
        }case 1:{
            return 3;
            break;
        }default:{
            return 1;
            break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return KRowHeightPersion;
    }else{
        return KRowHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (cell) {
        switch (indexPath.section) {
            case 0:{
                //个人信息
                NSInteger iLeftGap=15;
                //头像label
                NSInteger iLabelH=30;
                NSInteger iLabelW=65;
                UILabel *lblIconTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap,(KRowHeightPersion-iLabelH)/2, iLabelW, iLabelH)];
                lblIconTitle.textAlignment=NSTextAlignmentLeft;
                lblIconTitle.text=@"头像:";
                lblIconTitle.font= [UIFont systemFontOfSize:15];
                lblIconTitle.textColor=[UIColor darkGrayColor];
                [cell.contentView addSubview:lblIconTitle];
                
                //头像
                //图标
                NSInteger iIconSize=40;
                
                NSString *sPhoto=[SystemPlist GetPhoto];
                NSString *sBelognName=[SystemPlist GetLoadUser];
                
                
                _imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap+iLabelW,(KRowHeightPersion-iIconSize)/2, iIconSize, iIconSize)];
                _imageFileIcon.hidden=YES;
                [cell.contentView addSubview:_imageFileIcon];
                
                _lblIcon=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap+iLabelW,(KRowHeightPersion-iIconSize)/2, iIconSize, iIconSize)];
                _lblIcon.textAlignment=NSTextAlignmentCenter;
                _lblIcon.numberOfLines=0;
                _lblIcon.hidden=YES;
                _lblIcon.font= [UIFont systemFontOfSize:22];
                _lblIcon.backgroundColor=[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0];
                _lblIcon.textColor=[UIColor whiteColor];
                [cell.contentView addSubview:_lblIcon];
                
                //头像，如果头像为空，就用名字的最后一个字符代替
                if (![sPhoto isEqualToString:@""]) {
                
                    NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sPhoto options:0];
                     _imageFileIcon.image=[UIImage imageWithData:photoData];
                    _imageFileIcon.hidden=NO;
                }else{
                    _lblIcon.text=[[[sBelognName componentsSeparatedByString:@"@"] firstObject] substringFromIndex:[[sBelognName componentsSeparatedByString:@"@"] firstObject].length-1];
                    _lblIcon.hidden=NO;
                }

                //箭头
                NSInteger iIconCorrorW=10;
                NSInteger iIconCorrorH=15;
                UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-iLeftGap-iIconCorrorW,(KRowHeightPersion-iIconCorrorH)/2, iIconCorrorW, iIconCorrorH)];
                imageCorror.image=[UIImage imageNamed:@"list_arrowright_grey.png"];
                [cell.contentView addSubview:imageCorror];

                break;
            }case 1:{

                NSInteger iLeftGap=15;
                //头像label
                NSInteger iLabelTxtH=30;
                NSInteger iLabelW=65;
                NSInteger iTxtFieldW=CGRectGetWidth(self.view.frame)-iLabelW-iLeftGap*2;

                NSString *sTitle;
                UITextField *txtObject;
                
                if (indexPath.row==0) {
                    sTitle=@"邮箱:";
                    
                    _txtEmail=[[UITextField alloc] initWithFrame:CGRectMake(iLeftGap+iLabelW,(KRowHeight-iLabelTxtH)/2, iTxtFieldW, iLabelTxtH)];
                    _txtEmail.placeholder=@"可用该邮箱登录";
                    _txtEmail.text=[SystemPlist GetMail];
                    txtObject=_txtEmail;
                    
                }else if (indexPath.row==1){
                    sTitle=@"新密码:";
                    _txtNewPwd=[[UITextField alloc] initWithFrame:CGRectMake(iLeftGap+iLabelW,(KRowHeight-iLabelTxtH)/2, iTxtFieldW, iLabelTxtH)];
                    _txtNewPwd.secureTextEntry=YES;
                    txtObject=_txtNewPwd;
                }else{
                    sTitle=@"重复密码:";
                    _txtConfirmPwd=[[UITextField alloc] initWithFrame:CGRectMake(iLeftGap+iLabelW,(KRowHeight-iLabelTxtH)/2, iTxtFieldW, iLabelTxtH)];
                    _txtConfirmPwd.secureTextEntry=YES;
                    txtObject=_txtConfirmPwd;
                }

                UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap,(KRowHeight-iLabelTxtH)/2, iLabelW, iLabelTxtH)];
                lblTitle.textAlignment=NSTextAlignmentLeft;
                lblTitle.text=sTitle;
                lblTitle.font= [UIFont systemFontOfSize:15];
                lblTitle.textColor=[UIColor darkGrayColor];
                [cell.contentView addSubview:lblTitle];
                //txt
                txtObject.delegate=self;
                txtObject.layer.borderColor=[[UIColor lightGrayColor] CGColor];
                txtObject.layer.borderWidth=1.0;
                txtObject.font=[UIFont systemFontOfSize:15];
                [cell.contentView addSubview:txtObject];
                
                break;
            }
            default:{
                
                break;
            }
        }
        
    }
    return cell;
}

#pragma mark 相册/拍照
//启动相册
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
//启动相机
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

//UIImagePickerController 回调--取消
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
        //压缩图片
        getImageData =[PublicFunc resetSizeOfImageData:getImage newSourceImageSize:100 maxSize:50];
        
        _dataSelectImg=getImageData;
        //显示照片
        UIImage *img=[[UIImage alloc] initWithData:_dataSelectImg];
        [_imageFileIcon setImage:img];
        _imageFileIcon.hidden=NO;
        
        _lblIcon.hidden=YES;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
