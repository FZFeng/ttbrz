//
//  TbCellAssessLog.m
//  ttbrz
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "TbCellAssessLog.h"

#define KAccessoryImage  201
#define KAccessoryFile   202

@implementation TbCellAssessLog

- (void)initData{
    //动态加载主数据
    NSInteger cellRowHeight=0;
    NSInteger leftGap=20;
    NSInteger detailControlHeight=30;
    NSInteger logTitleWidth=85;
    NSInteger lineHeight=2;
    NSInteger logTbCellDetailViewWidth;
    NSInteger fileIconImageSize=15;
    
    logTbCellDetailViewWidth=CGRectGetWidth(self.viewTeamLogDetail.frame);
    
    self.btnAssess.layer.cornerRadius =5.0;
    
    //头像，如果头像为空，就用名字的最后一个字符代替
    NSString *sMemberName=self.cLogObject.sCreateUserName;
    NSString *sUserPhoto=self.cLogObject.sCreateUserPhoto;
    if ([sUserPhoto isEqualToString:@""]) {
        _lblMemberMark.text=[sMemberName substringFromIndex:sMemberName.length-1];
        _lblMemberMark.hidden=NO;
        
        _imageMemberIcon.hidden=YES;
        _imageMemberIcon.image=nil;
    }else{
        _lblMemberMark.hidden=YES;
        
        NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sUserPhoto options:0];
        _imageMemberIcon.hidden=NO;
        _imageMemberIcon.image=[UIImage imageWithData:photoData];
    }

    
    //成员名称
    _lblMemberName.text=sMemberName;
    
    //选中状态
    if (!self.cLogObject.bSelected) {
        _btnAssess.hidden=NO;
        [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
    }else{
        _btnAssess.hidden=YES;
        [_btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_AllSelected.png"] forState:UIControlStateNormal];
    }
    //日志日期
    _lblLogDate.text=self.cLogObject.sLogDate;
    
    //新除旧内容
    for (UIView *subView in self.viewTeamLogDetail.subviews) {
        [subView removeFromSuperview];
    }
    
    //日志内容
    if (self.cLogObject.sLogContent) {
        //日志内容
        NSString *sLogContent=[self.cLogObject.sLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
        NSInteger logContentLabelHeight=[PublicFunc heightForString:sLogContent font:[UIFont systemFontOfSize:15] andWidth:logTbCellDetailViewWidth];
        UILabel *logContentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth,logContentLabelHeight )];
        logContentLabel.numberOfLines=0;
        logContentLabel.textColor=[UIColor grayColor];
        logContentLabel.font=[UIFont systemFontOfSize:14];
        logContentLabel.text=[self.cLogObject.sLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
        [self.viewTeamLogDetail addSubview:logContentLabel];
        cellRowHeight=cellRowHeight+logContentLabelHeight;
    }
    //上传文件内容
    if (self.cLogObject.arrayAccessory) {
        
        NSMutableArray *arrayAccessory=[[self.cLogObject.arrayAccessory copy] objectForKey:@"Result"];
        
        if (arrayAccessory.count>0) {
            
            //标题
            UILabel *logTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(leftGap, cellRowHeight, logTitleWidth, detailControlHeight)];
            logTitleLabel.text=@"上传文件";
            logTitleLabel.font=[UIFont systemFontOfSize:17];
            [self.viewTeamLogDetail addSubview:logTitleLabel];
            
            cellRowHeight=cellRowHeight+detailControlHeight;
            //分隔线
            UIImageView *logDetailLineImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth-10, lineHeight)];
            logDetailLineImage.image=[UIImage imageNamed:@"logDetailLine.png"];
            [self.viewTeamLogDetail addSubview:logDetailLineImage];
            cellRowHeight=cellRowHeight+lineHeight;
            
            for (int i=0; i<=arrayAccessory.count-1; i++) {
                //根据文件名称判断图标
                
                UIView *fileView=[[UIView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth, detailControlHeight)];
                [self.viewTeamLogDetail addSubview:fileView];
                
                NSDictionary *dictData=[arrayAccessory objectAtIndex:i];
                NSString *sFileTitle=[dictData objectForKey:@"Title"];
                UIImageView *fileIconImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,(detailControlHeight-fileIconImageSize)/2, fileIconImageSize, fileIconImageSize)];
                fileIconImage.image=[UIImage imageNamed:[self getFileIconWithName:sFileTitle]];
                [fileView addSubview:fileIconImage];
                
                //内容
                UIButton *btnLink=[[UIButton alloc] initWithFrame:CGRectMake(fileIconImageSize+5,0, logTbCellDetailViewWidth-fileIconImageSize-5, detailControlHeight)];
                [btnLink setTitle:sFileTitle forState:UIControlStateNormal];
                [btnLink setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btnLink addTarget:self action:@selector(didFileEdit:) forControlEvents:UIControlEventTouchUpInside];
                btnLink.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
                if ([[self getFileIconWithName:sFileTitle] isEqualToString:@"img.png"]) {
                    //图片
                    btnLink.tag=KAccessoryImage;
                }
                btnLink.titleLabel.font=[UIFont systemFontOfSize:14];
                btnLink.accessibilityIdentifier=[dictData objectForKey:@"AssID"];
                btnLink.accessibilityLabel=[dictData objectForKey:@"URL"];
                
                [fileView addSubview:btnLink];
                cellRowHeight=cellRowHeight+detailControlHeight;
            }
        }
    }
    
}

//根据文件名称获取图片名
-(NSString*)getFileIconWithName:(NSString*)sName{
    
    NSString *sExtension=[sName pathExtension];
    
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

//编缉文件事件
- (void)didFileEdit:(id)sender {
    [self.delegate didTbCellAssessLogButtonDelegate:sender curLogData:self.cLogObject ];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
