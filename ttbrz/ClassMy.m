//
//  ClassMy.m
//  ttbrz
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ClassMy.h"

@implementation ClassMy

#pragma mark 保存个人信息
+ (void)saveMyInfoWithCompanyID:(NSString*)companyID
                         userID:(NSString*)userID
                            pwd:(NSString*)pwd
                          photo:(NSString*)photo
                          email:(NSString*)email
                   fatherObject:(id)fatherObject
                    returnBlock:(returnMyClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParaEmail=[NSString stringWithFormat:@"Email=%@",email];
    [arryInfo addObject:sParaEmail];
    
    NSString *sParaPhoto=[NSString stringWithFormat:@"Photo=%@",photo];
    [arryInfo addObject:sParaPhoto];
    
    NSString *sParaPwd=[NSString stringWithFormat:@"Pwd=%@",pwd];
    [arryInfo addObject:sParaPwd];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/SaveMyInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                returnBlock(YES,nil);
            }else{
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}

//保存意见反馈信息
+ (void)saveFeedbackInfoWithEmail:(NSString*)email
                          content:(NSString*)content
                         userName:(NSString*)userName
                     fatherObject:(id)fatherObject
                      returnBlock:(returnMyClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaContent=[NSString stringWithFormat:@"Content=%@",content];
    [arryInfo addObject:sParaContent];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserName=%@",userName];
    [arryInfo addObject:sParauserID];
    
    NSString *sParaEmail=[NSString stringWithFormat:@"Email=%@",email];
    [arryInfo addObject:sParaEmail];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/SaveFeedbackInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                returnBlock(YES,nil);
            }else{
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];

}

@end
