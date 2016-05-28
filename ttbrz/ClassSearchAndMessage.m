//
//  ClassSearchAndMessage.m
//  ttbrz
//
//  Created by apple on 16/3/28.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ClassSearchAndMessage.h"

@implementation ClassSearchAndMessage


+(void)searchDataWithKey:(NSString*)sKey
                   iType:(NSInteger)iType
                    page:(NSInteger)page
                    rows:(NSInteger)rows
               companyID:(NSString*)companyID
                  userID:(NSString*)userID
            fatherObject:(id)fatherObject
             returnBlock:(returnSearchOrMessageDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    
    NSString *sParastrKey=[NSString stringWithFormat:@"strKey=%@",sKey];
    [arryInfo addObject:sParastrKey];
    
    NSString *sParaiType=[NSString stringWithFormat:@"iType=%ld",(long)iType];
    [arryInfo addObject:sParaiType];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"Page=%ld",(long)page];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"Rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/SearchInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
                //日志
                NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                NSArray *detailLogInfoArray=[returnData objectForKey:@"Result"];
                if (detailLogInfoArray.count>0) {
                    for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                        NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                        ClassSearchAndMessage *cObject=[[ClassSearchAndMessage alloc] init];
                        cObject.arraySearchData_LogInfo=[[dictData objectForKey:@"LogInfo"] objectForKey:@"Result"];
                        cObject.iSearchData_LogInfoCount=[[[dictData objectForKey:@"LogInfo"] objectForKey:@"RsCount"] integerValue];
                        
                        cObject.arraySearchData_TaskInfo=[[dictData objectForKey:@"TaskInfo"] objectForKey:@"Result"];
                        cObject.iSearchData_TaskInfoCount=[[[dictData objectForKey:@"TaskInfo"] objectForKey:@"RsCount"] integerValue];
                        
                        cObject.arraySearchData_FileInfo=[[dictData objectForKey:@"FileInfo"] objectForKey:@"Result"];
                        cObject.iSearchData_FileInfoCount=[[[dictData objectForKey:@"FileInfo"] objectForKey:@"RsCount"] integerValue];
                        
                        [resultLogInfoArray addObject:cObject];
                    }
                }
                returnBlock(YES,[resultLogInfoArray copy]);
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


+(void)searchDataNoHUDWithKey:(NSString*)sKey
                        iType:(NSInteger)iType
                         page:(NSInteger)page
                         rows:(NSInteger)rows
                    companyID:(NSString*)companyID
                       userID:(NSString*)userID
                  returnBlock:(returnSearchOrMessageDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    
    NSString *sParastrKey=[NSString stringWithFormat:@"strKey=%@",sKey];
    [arryInfo addObject:sParastrKey];
    
    NSString *sParaiType=[NSString stringWithFormat:@"iType=%ld",(long)iType];
    [arryInfo addObject:sParaiType];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"Page=%ld",(long)page];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"Rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/SearchInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
                //日志
                NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                NSArray *detailLogInfoArray=[returnData objectForKey:@"Result"];
                if (detailLogInfoArray.count>0) {
                    for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                        NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                        ClassSearchAndMessage *cObject=[[ClassSearchAndMessage alloc] init];
                        cObject.arraySearchData_LogInfo=[[dictData objectForKey:@"LogInfo"] objectForKey:@"Result"];
                        cObject.arraySearchData_TaskInfo=[[dictData objectForKey:@"TaskInfo"] objectForKey:@"Result"];
                        cObject.arraySearchData_FileInfo=[[dictData objectForKey:@"FileInfo"] objectForKey:@"Result"];
                        [resultLogInfoArray addObject:cObject];
                    }
                }
                returnBlock(YES,[resultLogInfoArray copy]);
            }else{
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}

//获取消息信息
+ (void)getMessageInfoWithID:(NSString*)sID
                     strType:(NSString*)strType
                        page:(NSInteger)page
                        rows:(NSInteger)rows
                 returnBlock:(returnSearchOrMessageDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaLogID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaLogID];
    
    NSString *sParastrType=[NSString stringWithFormat:@"strType=%@",strType];
    [arryInfo addObject:sParastrType];
    
    NSString *sParapage=[NSString stringWithFormat:@"page=%ld",(long)page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"rows=%ld",(long)rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetMessageInfo_App",KServerUrl_App]  arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *arrayResult=[[NSMutableArray alloc] init];
                ClassSearchAndMessage *cObject=[[ClassSearchAndMessage alloc] init];
                cObject.arrayMessageInfo=[returnData objectForKey:@"Result"];
                cObject.iMessageCount=[[returnData objectForKey:@"RsCount"] integerValue];
                [arrayResult addObject:cObject];
                returnBlock(YES,arrayResult);
            }else{
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}

//获取消息信息(HUD)
+ (void)getMessageInfoHUDWithID:(NSString*)sID
                        strType:(NSString*)strType
                           page:(NSInteger)page
                           rows:(NSInteger)rows
                   fatherObject:(id)fatherObject
                    returnBlock:(returnSearchOrMessageDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaLogID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaLogID];
    
    NSString *sParastrType=[NSString stringWithFormat:@"strType=%@",strType];
    [arryInfo addObject:sParastrType];
    
    NSString *sParapage=[NSString stringWithFormat:@"page=%ld",(long)page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"rows=%ld",(long)rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetMessageInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *arrayResult=[[NSMutableArray alloc] init];
                ClassSearchAndMessage *cObject=[[ClassSearchAndMessage alloc] init];
                cObject.arrayMessageInfo=[returnData objectForKey:@"Result"];
                cObject.iMessageCount=[[returnData objectForKey:@"RsCount"] integerValue];
                [arrayResult addObject:cObject];
                returnBlock(YES,arrayResult);

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

//获取待审阅日报篇数
+ (void)GetConfirmLogNumWithID:(NSString*)sID
                   returnBlock:(returnSearchOrMessageDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaLogID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaLogID];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetConfirmLog_App",KServerUrl_App]  arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                returnBlock(YES,detailDataArray);
            }else{
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];

}


//知道了确定消息
+ (void)updateMessageStateWithMessageID:(NSString*)messageID
                           fatherObject:(id)fatherObject
                            returnBlock:(returnSearchOrMessageDataBlock)returnBlock{


    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    
    NSString *sParaMessageID=[NSString stringWithFormat:@"MessageID=%@",messageID];
    [arryInfo addObject:sParaMessageID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/UpdateMessageState_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
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
//检查app 版本
+ (void)checkVersion:(returnVersionBlock)returnBlock{
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetIOSVersionsCode",KServerUrl_App] arryPara:nil requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
                NSDictionary *dictData=[[returnData objectForKey:@"Result"] firstObject];
                returnBlock(YES,[dictData objectForKey:@"Version"]);
            }else{
                returnBlock(NO,nil);
            }

        }else{
            returnBlock(NO,nil);
        }
    }];
}

@end
