//
//  TbCellLog.m
//  ttbrz
//
//  Created by apple on 16/3/7.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "TbCellLog.h"

#define KAccessoryImage  201
#define KAccessoryFile   202

@implementation TbCellLog


- (void)initData{
    //动态加载主数据
    NSInteger cellRowHeight=0;
    NSInteger leftGap=20;
    NSInteger detailControlHeight=30;
    NSInteger editButtonWidth=50;
    NSInteger logTitleWidth=85;
    NSInteger lineHeight=2;
    NSInteger logTbCellDetailViewWidth;
    NSInteger fileIconImageSize=15;
    
    logTbCellDetailViewWidth=CGRectGetWidth(self.logTbCellDetailView.frame);
    
    NSString *sLogDate=self.cLogObject.sLogDate;
    NSArray *arryLogDate=[sLogDate componentsSeparatedByString:@"-"];
    self.monthLabel.text=[NSString stringWithFormat:@"%@ 月",[arryLogDate objectAtIndex:1]];
    self.dayLabel.text=[NSString stringWithFormat:@"%@",[arryLogDate objectAtIndex:2]];
    self.weekLabel.text=[PublicFunc returnWeekDateWithDate:sLogDate];
    
    //title上的日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *dLogDate= [dateFormatter dateFromString:sLogDate];
    NSTimeInterval time=[dLogDate timeIntervalSinceNow];
    int days=((int)time)/(3600*24);
    if (days==0) {
        self.detailTitleLabel.text=@"今天";
    }else if (days==-1){
        self.detailTitleLabel.text=@"昨天";
    }else if (days==-2){
        self.detailTitleLabel.text=@"前天";
    }else{
        self.detailTitleLabel.text=[NSString stringWithFormat:@"%d天前",-days];
    }
    
    //新除旧内容
    for (UIView *subView in self.logTbCellDetailView.subviews) {
        [subView removeFromSuperview];
    }
    
    if ([self.cLogObject.sLogState integerValue]==LogStateTypeFinished) {
        //已完成了，显示示评分
        _lblLogState.hidden=NO;
        self.btnEdit.hidden=YES;
        
        _lblLogState.text=self.cLogObject.sLogScore;
    }else if ([self.cLogObject.sLogState integerValue]==LogStateTypeWaitting){
        //待考评
        _lblLogState.hidden=NO;
        _lblLogState.text=@"待考评";
        self.btnEdit.hidden=YES;
    }else{
        _lblLogState.hidden=YES;
        self.btnEdit.hidden=NO;
    }
    
    //同事日志
    if (self.bColleagueLog) {
        self.btnEdit.hidden=YES;
    }
    
    _imageBtnEdit.hidden=self.btnEdit.hidden;

    
    if (self.cLogObject.isLogExist || [self.cLogObject.sLogState integerValue]==LogStateTypeFinished) {
        
        //日志内容
        if (self.cLogObject.sLogContent) {
            //标题
            UILabel *logTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(leftGap, cellRowHeight, logTitleWidth, detailControlHeight)];
            logTitleLabel.text=@"工作日志";
            logTitleLabel.font=[UIFont systemFontOfSize:17];
            [self.logTbCellDetailView addSubview:logTitleLabel];
            
            if (self.cLogObject.isLogExist && !self.bColleagueLog && [self.cLogObject.sLogState integerValue]!=LogStateTypeFinished) {
                UIButton *logEditButton=[[UIButton alloc] initWithFrame:CGRectMake(leftGap+logTitleWidth, cellRowHeight, editButtonWidth, detailControlHeight)];
                [logEditButton setTitle:@"[编辑]" forState:UIControlStateNormal];
                [logEditButton addTarget:self action:@selector(didLogEdit:) forControlEvents:UIControlEventTouchUpInside];
                [logEditButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                [self.logTbCellDetailView addSubview:logEditButton];
            }
            cellRowHeight=cellRowHeight+detailControlHeight;
            //分隔线
            UIImageView *logDetailLineImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth-10, lineHeight)];
            logDetailLineImage.image=[UIImage imageNamed:@"logDetailLine.png"];
            [self.logTbCellDetailView addSubview:logDetailLineImage];
            cellRowHeight=cellRowHeight+lineHeight;
            //内容
            NSString *sLogContent=[self.cLogObject.sLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
            NSInteger logContentLabelHeight=[PublicFunc heightForString:sLogContent font:[UIFont systemFontOfSize:15] andWidth:logTbCellDetailViewWidth];
            UILabel *logContentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth,logContentLabelHeight )];
            logContentLabel.numberOfLines=0;
            logContentLabel.textColor=[UIColor grayColor];
            logContentLabel.font=[UIFont systemFontOfSize:14];
            logContentLabel.text=[self.cLogObject.sLogContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
            [self.logTbCellDetailView addSubview:logContentLabel];
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
                [self.logTbCellDetailView addSubview:logTitleLabel];
                
                if (self.cLogObject.isLogExist && !self.bColleagueLog && [self.cLogObject.sLogState integerValue]!=LogStateTypeFinished) {
                    UIButton *logEditButton=[[UIButton alloc] initWithFrame:CGRectMake(leftGap+logTitleWidth, cellRowHeight, editButtonWidth, detailControlHeight)];
                    [logEditButton setTitle:@"[上传]" forState:UIControlStateNormal];
                    [logEditButton addTarget:self action:@selector(didUpFileEdit:) forControlEvents:UIControlEventTouchUpInside];
                    [logEditButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    [self.logTbCellDetailView addSubview:logEditButton];
                }
                cellRowHeight=cellRowHeight+detailControlHeight;
                //分隔线
                UIImageView *logDetailLineImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth-10, lineHeight)];
                logDetailLineImage.image=[UIImage imageNamed:@"logDetailLine.png"];
                [self.logTbCellDetailView addSubview:logDetailLineImage];
                cellRowHeight=cellRowHeight+lineHeight;
                
                for (int i=0; i<=arrayAccessory.count-1; i++) {
                    //根据文件名称判断图标
                    
                    UIView *fileView=[[UIView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth, detailControlHeight)];
                    [self.logTbCellDetailView addSubview:fileView];
                    
                    NSDictionary *dictData=[arrayAccessory objectAtIndex:i];
                    NSString *sFileTitle=[dictData objectForKey:@"Title"];
                    UIImageView *fileIconImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,(detailControlHeight-fileIconImageSize)/2, fileIconImageSize, fileIconImageSize)];
                    fileIconImage.image=[UIImage imageNamed:[self getFileIconWithName:sFileTitle]];
                    [fileView addSubview:fileIconImage];
                    
                    //内容
                    UIButton *btnLink=[[UIButton alloc] initWithFrame:CGRectMake(fileIconImageSize+5,0, logTbCellDetailViewWidth-fileIconImageSize-10, detailControlHeight)];
                    [btnLink setTitle:sFileTitle forState:UIControlStateNormal];
                    [btnLink setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    [btnLink addTarget:self action:@selector(didFileEdit:) forControlEvents:UIControlEventTouchUpInside];
                    if ([[self getFileIconWithName:sFileTitle] isEqualToString:@"img.png"]) {
                        //图片
                        btnLink.tag=KAccessoryImage;
                    }
                    
                    btnLink.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
                    btnLink.titleLabel.font=[UIFont systemFontOfSize:14];
                    btnLink.accessibilityIdentifier=[dictData objectForKey:@"AssID"];
                    btnLink.accessibilityLabel=[dictData objectForKey:@"URL"];
                    
                    [fileView addSubview:btnLink];
                    cellRowHeight=cellRowHeight+detailControlHeight;
                }
            }
        }
        //点评内容
        if (self.cLogObject.sEvaluationItemInfo && self.cLogObject.sEvaluationItemInfo.length>0 && !self.bColleagueLog) {
            //标题
            UILabel *logTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(leftGap, cellRowHeight, logTitleWidth, detailControlHeight)];
            logTitleLabel.text=@"日志考评";
            logTitleLabel.font=[UIFont systemFontOfSize:17];
            [self.logTbCellDetailView addSubview:logTitleLabel];
            
            cellRowHeight=cellRowHeight+detailControlHeight;
            //分隔线
            UIImageView *logDetailLineImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth-10, lineHeight)];
            logDetailLineImage.image=[UIImage imageNamed:@"logDetailLine.png"];
            [self.logTbCellDetailView addSubview:logDetailLineImage];
            cellRowHeight=cellRowHeight+lineHeight;
            
            //内容
            NSString *sEvaluationItemInfo=[self.cLogObject.sEvaluationItemInfo stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
            NSInteger logContentLabelHeight=[PublicFunc heightForString:sEvaluationItemInfo font:[UIFont systemFontOfSize:15] andWidth:logTbCellDetailViewWidth];
            UILabel *logContentLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,cellRowHeight, logTbCellDetailViewWidth,logContentLabelHeight )];
            logContentLabel.numberOfLines=0;
            logContentLabel.textColor=[UIColor grayColor];
            logContentLabel.font=[UIFont systemFontOfSize:14];
            logContentLabel.text=[self.cLogObject.sEvaluationItemInfo stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
            [self.logTbCellDetailView addSubview:logContentLabel];
            cellRowHeight=cellRowHeight+logContentLabelHeight;
        }
    }else{
        UILabel *notResultTitle=[[UILabel alloc] initWithFrame:CGRectMake(leftGap, 0, logTbCellDetailViewWidth, detailControlHeight)];
        notResultTitle.text=@"无日志内容";
        notResultTitle.font=[UIFont systemFontOfSize:17];
        notResultTitle.textColor=[UIColor grayColor];
        [self.logTbCellDetailView addSubview:notResultTitle];
    }


}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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

//编缉日志事件
- (void)didLogEdit:(id)sender{
    [self.delegate didTbCellButtonDelegate:sender curLogData:self.cLogObject  returnType:TbCellLogDelegateTypeLogEdit];
}

//上传文件事件
- (void)didUpFileEdit:(id)sender{
    [self.delegate didTbCellButtonDelegate:sender curLogData:self.cLogObject returnType:TbCellLogDelegateTypeUpFileEdit];
}

//编缉文件事件
- (void)didFileEdit:(id)sender {
    [self.delegate didTbCellButtonDelegate:sender curLogData:self.cLogObject returnType:TbCellLogDelegateTypeFileEdit];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    curLocation = [touch locationInView:self];
    

    //坐标： location.x, location.y
    
    // .....
}

- (IBAction)didBtnEdit:(id)sender {
    
    if ([self.cLogObject.sLogState integerValue]==LogStateTypeWaitting) {
        //填报中
       //写日志,上传文件,提交文件
        return;
    }
    
    if (!self.cLogObject.isLogExist) {
        //没填日志
        //写日志,上传文件
        CGPoint point = CGPointMake(self.btnEdit.frame.origin.x + self.btnEdit.frame.size.width/2, self.btnEdit.frame.origin.y + self.btnEdit.frame.size.height);
        NSArray *titles = @[@"写日志", @"上传文件"];
        NSArray *images = @[@"log_addNewLog.png", @"log_upLoadFile.png"];
        PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:images];
        pop.selectRowAtIndex = ^(NSInteger index){
            if (index==0) {
                [self.delegate didTbCellButtonDelegate:sender curLogData:self.cLogObject returnType:TbCellLogDelegateTypeLogAddNew];
            }else{
                [self.delegate didTbCellButtonDelegate:sender  curLogData:self.cLogObject returnType:TbCellLogDelegateTypeUpFileEdit];
            }
        };
        [pop show];

    }
    
    
}

@end
