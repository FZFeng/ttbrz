//
//  UIViewControllerPlanTask.m
//  ttbrz
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerPlanTask.h"

#define KEachExecuteUsersHeight 25
#define KEachExecuteUsersRowNum 4

@interface UIViewControllerPlanTask (){
    IBOutlet UIView *_viewUserProgressInfo;
    
    IBOutlet UILabel *_lblUserProgressInfo;
    IBOutlet UIView *_viewDetailInfo;

    IBOutlet UILabel *lblTitleText;
    IBOutlet UILabel *lblEndTimeText;
    IBOutlet UITextView *txtLogContent;
    IBOutlet NSLayoutConstraint *_layoutConstraintHeightExecuteUsers;
    
    NSInteger _iViewControlH;
    NSInteger _iViewDetailInfoW;
    NSInteger iDidLayoutSubviewsTimer;
}


@end

@implementation UIViewControllerPlanTask

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    iDidLayoutSubviewsTimer=0;
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"查看任务";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    
    //执行第二次时才执行
    if (iDidLayoutSubviewsTimer==1) {
        
        _iViewControlH=CGRectGetHeight(_viewUserProgressInfo.frame);
        _iViewDetailInfoW=CGRectGetWidth(_viewDetailInfo.frame);
       
        txtLogContent.layer.borderWidth=1.0;
        txtLogContent.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        txtLogContent.layer.cornerRadius=5.0;
        txtLogContent.editable=NO;
        //查找时设置红色设置
        NSString *sTaskTitle=self.cGetDetailPlanTaskData.sTaskTitle;
        NSString *sTaskContent=self.cGetDetailPlanTaskData.sTaskContent;
        
        lblTitleText.text=sTaskTitle;
        lblEndTimeText.text=self.cGetDetailPlanTaskData.sEndDate;
        txtLogContent.text=sTaskContent;
        
        if (self.sGetSearchKey && self.sGetSearchKey.length>0) {
            NSString *sSearchKey=self.sGetSearchKey;
            //标题
            if (sTaskTitle && sTaskTitle.length>0) {
                NSMutableAttributedString *sMutTitle = [[NSMutableAttributedString alloc]initWithString:sTaskTitle];
                for (int i=0; i<=sSearchKey.length-1; i++) {
                    NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
                    NSRange range;
                    range = [sTaskTitle rangeOfString:KeyChar];
                    [sMutTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
                }
                lblTitleText.attributedText=sMutTitle;
            }
           
            //内容
            if (sTaskContent && sTaskContent.length>0) {
                NSMutableAttributedString *sMutContent = [[NSMutableAttributedString alloc]initWithString:sTaskContent];
                for (int i=0; i<=sSearchKey.length-1; i++) {
                    NSString *KeyChar=[sSearchKey substringWithRange:NSMakeRange(i, 1)];
                    NSRange range;
                    range = [sTaskContent rangeOfString:KeyChar];
                    [sMutContent addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.length)];
                }
                txtLogContent.attributedText=sMutContent;
            }
        }
        
        NSArray *arrayUserInfo=[self.cGetDetailPlanTaskData.sUserInfo componentsSeparatedByString:@"="];
        NSArray *arrayUserID=[[arrayUserInfo firstObject] componentsSeparatedByString:@"|"];
        NSArray *arrayUserName=[[arrayUserInfo objectAtIndex:1] componentsSeparatedByString:@","];
        NSArray *arrayProgress=[[arrayUserInfo objectAtIndex:2] componentsSeparatedByString:@","];
        
        //没指定人员，不显示
        if (arrayUserID.count==1 && [[arrayUserID firstObject] isEqualToString:@""]) {
            return;
        }
        
        NSInteger iSelectIndex=0;
        NSInteger iLblUserNameHeaderW=30;
        NSInteger iLblTaskProgressW=40;
        if (self.sGetUserID) {
            //指定某一userid的任务
            for (NSString *sCurUserID in arrayUserID) {
                if ([sCurUserID isEqualToString:self.sGetUserID]) {
                    break;
                }
                iSelectIndex++;
            }
            
            //name header
            UILabel *lblUserNameHeader=[[UILabel alloc] initWithFrame:CGRectMake(0, (_iViewControlH-iLblUserNameHeaderW)/2, iLblUserNameHeaderW, iLblUserNameHeaderW)];
            lblUserNameHeader.backgroundColor=randomColor;;
            lblUserNameHeader.textAlignment=NSTextAlignmentCenter;
            lblUserNameHeader.textColor=[UIColor whiteColor];
            lblUserNameHeader.text=[[arrayUserName objectAtIndex:iSelectIndex] substringFromIndex:((NSString*)[arrayUserName objectAtIndex:iSelectIndex]).length-1];
            [_viewDetailInfo addSubview:lblUserNameHeader];
            
            //progress
            UILabel *lblTaskProgress=[[UILabel alloc] initWithFrame:CGRectMake(iLblUserNameHeaderW, 0, iLblTaskProgressW, _iViewControlH)];
            lblTaskProgress.textColor=[UIColor darkGrayColor];
            lblTaskProgress.font=[UIFont systemFontOfSize:15];
            lblTaskProgress.text=[NSString stringWithFormat:@"%@%%",[arrayProgress objectAtIndex:iSelectIndex]];
            [_viewDetailInfo addSubview:lblTaskProgress];
            
        }else{
        
            //显示所有任务
            /*
            UIScrollView *scrolUserProgressInfo=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0, _iViewDetailInfoW, _iViewControlH)];
            scrolUserProgressInfo.bounces=NO;
            scrolUserProgressInfo.scrollEnabled=NO;
            scrolUserProgressInfo.showsHorizontalScrollIndicator=NO;
            scrolUserProgressInfo.showsVerticalScrollIndicator=NO;
            [_viewDetailInfo addSubview:scrolUserProgressInfo];
            
            NSInteger iIndex=0;
            NSInteger iCurOriginX=0;
            
            for (NSString *sUserName in arrayUserName) {
                //name header
                UILabel *lblUserNameHeader=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX, (_iViewControlH-iLblUserNameHeaderW)/2, iLblUserNameHeaderW, iLblUserNameHeaderW)];
                lblUserNameHeader.backgroundColor=randomColor;;
                lblUserNameHeader.textAlignment=NSTextAlignmentCenter;
                lblUserNameHeader.textColor=[UIColor whiteColor];
                lblUserNameHeader.text=[sUserName substringFromIndex:sUserName.length-1];
                [scrolUserProgressInfo addSubview:lblUserNameHeader];
                iCurOriginX=iCurOriginX+iLblUserNameHeaderW;
                
                //progress
                UILabel *lblTaskProgress=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX, 0, iLblTaskProgressW, _iViewControlH)];
                lblTaskProgress.textColor=[UIColor darkGrayColor];
                lblTaskProgress.font=[UIFont systemFontOfSize:15];
                lblTaskProgress.text=[NSString stringWithFormat:@"%@%%",[arrayProgress objectAtIndex:iIndex]];
                [scrolUserProgressInfo addSubview:lblTaskProgress];
                
                iCurOriginX=iCurOriginX+iLblTaskProgressW;
                iIndex++;
            }
            
            if (iCurOriginX>_iViewDetailInfoW) {
                scrolUserProgressInfo.contentSize=CGSizeMake(iCurOriginX, _iViewControlH);
            }*/
            
            NSInteger iViewExecuteUsersW=CGRectGetWidth(_viewDetailInfo.frame);
            NSInteger iUserNameW=KEachExecuteUsersHeight;
            NSInteger iUserNameH=KEachExecuteUsersHeight;
            NSInteger iTaskProgressW=(iViewExecuteUsersW-iUserNameW*KEachExecuteUsersRowNum)/KEachExecuteUsersRowNum;
            NSInteger iTaskProgressH=KEachExecuteUsersHeight;
            NSInteger iCurOriginX=0;
            NSInteger iCurOriginY=0;
            NSInteger iGap=5;
            NSInteger iDataNum=arrayUserName.count;
            
            
            //执行人 每行 最多4个执行人
            NSInteger iExecuteUsersRowNum=iDataNum/KEachExecuteUsersRowNum;
            NSInteger iAllExecuteUsersHeight=(iExecuteUsersRowNum+1)*KEachExecuteUsersHeight+iExecuteUsersRowNum*iGap;
            _layoutConstraintHeightExecuteUsers.constant=iAllExecuteUsersHeight;
 
            NSInteger iIndex=0;
            for (NSString *sUserName in arrayUserName) {
                //执行人
                UILabel *lblName=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX,iCurOriginY,iUserNameW, iUserNameH)];
                lblName.text=[sUserName substringFromIndex:sUserName.length-1];
                lblName.textAlignment=NSTextAlignmentCenter;
                lblName.textColor=[UIColor whiteColor];
                lblName.font=[UIFont systemFontOfSize:17];
                lblName.backgroundColor=randomColor;
                [_viewDetailInfo addSubview:lblName];
                iCurOriginX=iCurOriginX+iUserNameW;
                
                //完成进度
                UILabel *lblPersent=[[UILabel alloc] initWithFrame:CGRectMake(iCurOriginX,iCurOriginY,iTaskProgressW, iTaskProgressH)];
                lblPersent.text=[NSString stringWithFormat:@"%@%%",[arrayProgress objectAtIndex:iIndex]];
                lblPersent.textAlignment=NSTextAlignmentLeft;
                lblPersent.textColor=defaultColor;
                lblPersent.font=[UIFont systemFontOfSize:13];
                lblPersent.backgroundColor=[UIColor clearColor];
                [_viewDetailInfo addSubview:lblPersent];
                iCurOriginX=iCurOriginX+iTaskProgressW;
                
                iIndex++;
                if (iIndex%KEachExecuteUsersRowNum==0) {
                    iCurOriginX=0;
                }
                iCurOriginY=(iIndex/KEachExecuteUsersRowNum)*KEachExecuteUsersHeight+(iIndex/KEachExecuteUsersRowNum)*iGap;
            }
        }
  
    }else{
        iDidLayoutSubviewsTimer++;
    }
}

@end
