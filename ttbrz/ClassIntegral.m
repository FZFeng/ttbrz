//
//  ClassIntegral.m
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ClassIntegral.h"

@implementation ClassIntegral
//获取我的积分信息
+ (void)getMyScoreDataWithCompanyID:(NSString*)companyID
                             userID:(NSString*)userID
                               Year:(NSInteger)Year
                              Month:(NSInteger)Month
                       fatherObject:(id)fatherObject
                        returnBlock:(returnIntegralClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    
    NSString *sParaYear=[NSString stringWithFormat:@"Year=%ld",(long)Year];
    [arryInfo addObject:sParaYear];
    
    NSString *sParaMonth=[NSString stringWithFormat:@"Month=%ld",(long)Month];
    [arryInfo addObject:sParaMonth];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetMyScoreInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        ClassIntegral *cClassObject=[[ClassIntegral alloc] init];
                        cClassObject.isLogExist=[[dictData objectForKey:@"IsLogExist"] boolValue];
                        cClassObject.sLogDate=[dictData objectForKey:@"LogDate"];
                        cClassObject.sLogScore=[dictData objectForKey:@"LogScore"];
                        cClassObject.sConfirmUser=[dictData objectForKey:@"ConfirmUser"];
                        [resultMutableArray addObject:cClassObject];
                    }
                }
                returnBlock(YES,[resultMutableArray copy]);
                
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

//获取团队积分列表
+ (void)getGroupScoreDataWithDeptID:(NSString*)DeptID
                          PageIndex:(NSInteger)PageIndex
                           PageSize:(NSInteger)PageSize
                              Begin:(NSString*)Begin
                          CompanyID:(NSString*)companyID
                       fatherObject:(id)fatherObject
                        returnBlock:(returnIntegralClassDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParaDeptID=[NSString stringWithFormat:@"DeptID=%@",DeptID];
    [arryInfo addObject:sParaDeptID];
    
    NSString *sParaBegin=[NSString stringWithFormat:@"Begin=%@",Begin];
    [arryInfo addObject:sParaBegin];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"PageIndex=%ld",(long)PageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaPageSize=[NSString stringWithFormat:@"PageSize=%ld",(long)PageSize];
    [arryInfo addObject:sParaPageSize];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetGroupScoreList_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];

                        ClassIntegral *cClassObject=[[ClassIntegral alloc] init];

                        cClassObject.sCTop=[dictData objectForKey:@"CTop"];
                        cClassObject.sUserName=[dictData objectForKey:@"Name"];
                        cClassObject.sDeptName=[dictData objectForKey:@"DeptName"];
                        cClassObject.smaxScore=[dictData objectForKey:@"maxScore"];
                        [resultMutableArray addObject:cClassObject];
                    }
                }
                returnBlock(YES,[resultMutableArray copy]);
                
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

//获取团队积分列表(NoHUD)
+ (void)getGroupScoreDataNoHUDWithDeptID:(NSString*)DeptID
                               PageIndex:(NSInteger)PageIndex
                                PageSize:(NSInteger)PageSize
                                   Begin:(NSString*)Begin
                               CompanyID:(NSString*)companyID
                             returnBlock:(returnIntegralClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParaDeptID=[NSString stringWithFormat:@"DeptID=%@",DeptID];
    [arryInfo addObject:sParaDeptID];
    
    NSString *sParaBegin=[NSString stringWithFormat:@"Begin=%@",Begin];
    [arryInfo addObject:sParaBegin];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"PageIndex=%ld",(long)PageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaPageSize=[NSString stringWithFormat:@"PageSize=%ld",(long)PageSize];
    [arryInfo addObject:sParaPageSize];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetGroupScoreList_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        
                        ClassIntegral *cClassObject=[[ClassIntegral alloc] init];
                        
                        cClassObject.sCTop=[dictData objectForKey:@"CTop"];
                        cClassObject.sUserName=[dictData objectForKey:@"Name"];
                        cClassObject.sDeptName=[dictData objectForKey:@"DeptName"];
                        cClassObject.smaxScore=[dictData objectForKey:@"maxScore"];
                        [resultMutableArray addObject:cClassObject];
                    }
                }
                returnBlock(YES,[resultMutableArray copy]);
            }else{
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}

@end
