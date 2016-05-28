//
//  UIViewControllerDownloadFile.m
//  ttbrz
//
//  Created by apple on 16/3/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerDownloadFile.h"

#define KTbCellRowHeight  40

@interface UIViewControllerDownloadFile ()<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *_tbDownloadFileView;
    IBOutlet NSLayoutConstraint *_tbLayoutBottom;
    BOOL _bDidLayoutSubviews;
    NSMutableArray *_arrayDownloadFile;
    NSInteger _iTbViewH;

}

@end

@implementation UIViewControllerDownloadFile

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"已下载文件";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    _tbDownloadFileView.rowHeight=KTbCellRowHeight;

    
    NSArray *arrayData=[[NSArray  alloc]initWithContentsOfFile: [SystemPlist returnDownloadFilePath]];
    _arrayDownloadFile=[[NSMutableArray alloc] init];
    for (NSDictionary *dictData in arrayData) {
        if (![[dictData objectForKey:@"fileFilePath"] isEqualToString:@""]) {
            [_arrayDownloadFile addObject:dictData];
        }
    }
    //去掉左边的空白
//    if ([_tbDownloadFileView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [_tbDownloadFileView setLayoutMargins:UIEdgeInsetsZero];
//    }
//    if ([_tbDownloadFileView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [_tbDownloadFileView setSeparatorInset:UIEdgeInsetsZero];
//    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (_arrayDownloadFile.count>0) {
        NSInteger iCurTbHeight=_arrayDownloadFile.count*KTbCellRowHeight;
        if (iCurTbHeight>_iTbViewH) {
            _tbLayoutBottom.constant=0.0;
            _tbDownloadFileView.scrollEnabled=YES;
        }else{
            _tbLayoutBottom.constant=_iTbViewH-iCurTbHeight;
            _tbDownloadFileView.scrollEnabled=NO;
        }
        _tbDownloadFileView.delegate=self;
        _tbDownloadFileView.dataSource=self;
        [_tbDownloadFileView reloadData];

    }else{
        
        _tbLayoutBottom.constant=_iTbViewH;
        _tbDownloadFileView.scrollEnabled=NO;
    
        _tbDownloadFileView.delegate=nil;
        _tbDownloadFileView.dataSource=nil;
        
    }
}

-(void)viewDidLayoutSubviews{
    //根据arryActionJoinor来计算tbview的高度
    if (!_bDidLayoutSubviews) {
        _bDidLayoutSubviews=YES;
        _iTbViewH=CGRectGetHeight(_tbDownloadFileView.frame);
        [self setTbBottomConstant];
    }
}

#pragma mark 根据文件名称获取图片名
-(NSString*)getFileIconWithName:(NSString*)sExtension{
    
    if ([sExtension isEqualToString:@"jpg"] || [sExtension isEqualToString:@"jpeg"] || [sExtension isEqualToString:@"png"]) {
        return @"img.png";
    }else if ([sExtension isEqualToString:@"doc"] || [sExtension isEqualToString:@"docx"]){
        return @"docx.png";
    }else if ([sExtension isEqualToString:@"xls"] || [sExtension isEqualToString:@"xlsx"]){
        return @"xls.png";
    }else if ([sExtension isEqualToString:@"ppt"] || [sExtension isEqualToString:@"pptx"]){
        return @"ppt.png";
    }else if ([sExtension isEqualToString:@"zip"] || [sExtension isEqualToString:@"rar"]){
        return @"zip.png";
    }else{
        return @"txt.png";
    }
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictData=[_arrayDownloadFile objectAtIndex:indexPath.row];
    
    NSString *reuseIdentifier = @"myCell";
    
    UITableViewCell *myCell;
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSInteger iLeftGap=15;
    NSInteger iIconSize=30;
    //图标
    UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KTbCellRowHeight-iIconSize)/2, iIconSize, iIconSize)];
    imageFileIcon.image=[UIImage imageNamed:[self getFileIconWithName:[dictData objectForKey:@"fileExtension"]]];
    [myCell.contentView addSubview:imageFileIcon];
    //标题
    UILabel *lblDownloadFileName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize, 0, CGRectGetWidth(self.view.frame)-iLeftGap*2-iIconSize, KTbCellRowHeight)];
    lblDownloadFileName.text=[dictData objectForKey:@"fileTitle"];
    lblDownloadFileName.font=[UIFont systemFontOfSize:15];
    [myCell.contentView addSubview:lblDownloadFileName];

    return myCell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayDownloadFile.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dictData=[_arrayDownloadFile objectAtIndex:indexPath.row];
    
    NSString *sFileName=[NSString stringWithFormat:@"%@.%@",[PublicFunc getRandomGUID],[dictData objectForKey:@"fileExtension"]];
    NSData *fileData=[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[SystemPlist returnDownloadFileFolderPath],[dictData objectForKey:@"fileTitle"]]];
    
      
    //UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerUploadFile *uploadFileView=[self.navigationController.viewControllers objectAtIndex:1];
    [uploadFileView upLoadWithFileName:sFileName fileData:fileData];
    [self.navigationController popToViewController:uploadFileView animated:YES];

}

@end
