//
//  ClassLog.m
//  ttbrz
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ClassLog.h"

@implementation ClassLog

//进入系统后获取的初始化数据
+(void)initInfoWithID:(NSString*)sID
            companyID:(NSString*)companyID
         fatherObject:(id)fatherObject
          returnBlock:(returnLogDictionaryDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];

    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/InitInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 //最终要返回的数据
                 NSMutableDictionary *returnMutableDictionary=[[NSMutableDictionary alloc] init];
                 NSDictionary *curDataDictionary=[[returnData objectForKey:@"Result"] firstObject];
                 
                 for (NSString *skey in curDataDictionary.allKeys) {
                     if ([skey isEqualToString:@"TaskInfo"]) {
                         //等办任务数据
                         NSMutableArray *resultTaskInfoArray=[[NSMutableArray alloc] init];
                         NSArray *detailTaskInfoArray=[[curDataDictionary objectForKey:skey] objectForKey:@"Result"];
                         if (detailTaskInfoArray.count>0) {
                             for (int i=0; i<=detailTaskInfoArray.count-1; i++) {
                                 NSDictionary *dictData=[detailTaskInfoArray objectAtIndex:i];
                                 
                                 ClassLog *cLogObject=[[ClassLog alloc] init];
                                 cLogObject.sPlanID=[dictData objectForKey:@"PlanID"];
                                 cLogObject.sPlanItemId=[dictData objectForKey:@"PlanItemId"];
                                 cLogObject.sPlanName=[dictData objectForKey:@"PlanName"];
                                 cLogObject.sState=[dictData objectForKey:@"State"];
                                 cLogObject.sProgress=[dictData objectForKey:@"Progress"];
                                 cLogObject.sEndDate=[dictData objectForKey:@"EndDate"];
                                 cLogObject.isOntime=[[dictData objectForKey:@"IsOntime"] boolValue] ;
                                 
                                 [resultTaskInfoArray addObject:cLogObject];
                             }
                         }
                         //[returnMutableArray addObject:resultTaskInfoArray];
                         [returnMutableDictionary setObject:resultTaskInfoArray forKey:skey];
                     }else if ([skey isEqualToString:@"LogInfo"]){
                         //日志
                         NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                         NSArray *detailLogInfoArray=[[curDataDictionary objectForKey:skey] objectForKey:@"Result"];
                         if (detailLogInfoArray.count>0) {
                             for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                                 NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                                 
                                 BOOL bIsLogExist=[[dictData objectForKey:@"IsLogExist"] boolValue];
                                 ClassLog *cLogObject=[[ClassLog alloc] init];
                                 cLogObject.isLogExist=bIsLogExist;
                                 cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];
                                 cLogObject.sLogState=[dictData objectForKey:@"LogState"];
                                 
                                 //有填报日志时才记录详细信息
                                 if (bIsLogExist || [cLogObject.sLogState integerValue]==LogStateTypeFinished) {
                                     cLogObject.sLogID=[dictData objectForKey:@"LogID"];     //日志ID
                                     cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];   //日志日期
                                     cLogObject.sConfirmUserID=[dictData objectForKey:@"ConfirmUserID"];  //考评人ID
                                     cLogObject.sConfirmUser=[dictData objectForKey:@"ConfirmUser"];    //考评人姓名
                                     cLogObject.sLogScore=[dictData objectForKey:@"LogScore"];       //日志积分
                                     cLogObject.sLogContent=[dictData objectForKey:@"LogContent"];     //日志内容
                                     cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];  //上传文件信息（包含子集
                                     cLogObject.sEvaluationItemInfo=[dictData objectForKey:@"EvaluationItemInfo"]; //考评项信息
                                 }

                                 [resultLogInfoArray addObject:cLogObject];
                             }
                         }
                         [returnMutableDictionary setObject:resultLogInfoArray forKey:skey];
                         
                     }else if ([skey isEqualToString:@"DeptInfo"]){
                         //部门
                         NSMutableArray *resultTeamLogInfoArray=[[NSMutableArray alloc] init];
                         NSArray *detailTeamLogInfoArray=[[curDataDictionary objectForKey:skey] objectForKey:@"Result"];
                         if (detailTeamLogInfoArray.count>0) {
                             for (int i=0; i<=detailTeamLogInfoArray.count-1; i++) {
                                 NSDictionary *dictData=[detailTeamLogInfoArray objectAtIndex:i];
                                 //只显示部门内容
                                 ClassLog *cLogObject=[[ClassLog alloc] init];
                                 if (i==0 && [[dictData objectForKey:@"Type"] isEqualToString:@"0"]) {
                                     cLogObject.sDeptID=@"";
                                 }else{
                                     cLogObject.sDeptID=[dictData objectForKey:@"DeptID"];
                                 }
                                 cLogObject.sDeptName=[dictData objectForKey:@"DeptName"];
                                 cLogObject.sDepartmentType=[dictData objectForKey:@"Type"];
                                 
                                 [resultTeamLogInfoArray addObject:cLogObject];
                             }
                         }
                         [returnMutableDictionary setObject:resultTeamLogInfoArray forKey:skey];
                         
                     }else{
                         //我的
                         NSArray *myInfoArray=[[curDataDictionary objectForKey:skey] objectForKey:@"Result"];
                         if (myInfoArray.count>0) {
                             NSDictionary *dictData=[myInfoArray firstObject];
                             //设置个人信息
                             [SystemPlist SetMail:[dictData objectForKey:@"Email"]];
                             [SystemPlist SetPhoto:[dictData objectForKey:@"Photo"]];
                             [SystemPlist SetRootdomain:[dictData objectForKey:@"RootDomain"]];
                         }
                     }
                 }
                 
                 returnBlock(YES,returnMutableDictionary);
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

//获取待办任务
+(void)getPlanTaskWithID:(NSString*)sID
               companyID:(NSString*)companyID
               pageIndex:(NSInteger)pageIndex
                    rows:(NSInteger)rows
             returnBlock:(returnLogDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];

    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"Page=%ld",(long)pageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"Rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetPlanInfoListInLog_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        
                        ClassLog *cLogObject=[[ClassLog alloc] init];
                        cLogObject.sPlanID=[dictData objectForKey:@"PlanID"];
                        cLogObject.sPlanItemId=[dictData objectForKey:@"PlanItemId"];
                        cLogObject.sPlanName=[dictData objectForKey:@"PlanName"];
                        cLogObject.sState=[dictData objectForKey:@"State"];
                        cLogObject.sProgress=[dictData objectForKey:@"Progress"];
                        cLogObject.sEndDate=[dictData objectForKey:@"EndDate"];
                        cLogObject.isOntime=[[dictData objectForKey:@"IsOntime"] boolValue];
                        
                        [resultMutableArray addObject:cLogObject];
                    }
                }
                returnBlock(YES,[resultMutableArray copy]);
            }else{
                //NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                //[PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                returnBlock(NO,nil);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}

//更新待办任务进度
+ (void)updateTaskProgressWithItemID:(NSString*)itemID
                           iProgress:(NSInteger)iProgress
                        fatherObject:(id)fatherObject
                         returnBlock:(returnLogDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaItemID=[NSString stringWithFormat:@"ItemID=%@",itemID];
    [arryInfo addObject:sParaItemID];
    
    NSString *sParaiProgress=[NSString stringWithFormat:@"iProgress=%ld",(long)iProgress];
    [arryInfo addObject:sParaiProgress];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/UpdateTaskProgress_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//查看某一待办任务的详细信息
+ (void)getDetailPlanTaskWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                      strTaskID:(NSString*)strTaskID
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParastrTaskID=[NSString stringWithFormat:@"strTaskID=%@",strTaskID];
    [arryInfo addObject:sParastrTaskID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetEditTask_LookBoard_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
                //日志
                NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                NSArray *detailLogInfoArray=[returnData objectForKey:@"Result"];
                if (detailLogInfoArray.count>0) {
                    for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                        NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                        
                        ClassLog *cLogObject=[[ClassLog alloc] init];
                        cLogObject.sTaskTitle=[dictData objectForKey:@"TaskTitle"];
                        cLogObject.isOntime=[[dictData objectForKey:@"IsOntime"] boolValue];
                        cLogObject.sEndDate=[dictData objectForKey:@"EndTime"];
                        
                        
                        if ([dictData objectForKey:@"LookBoardID"]==[NSNull null]) {
                            cLogObject.sLookBoardID=@"00000000-0000-0000-0000-000000000000";
                        }else{
                            cLogObject.sLookBoardID=[dictData objectForKey:@"LookBoardID"];
                        }
                        
                        if ([dictData objectForKey:@"LookBoardName"]== [NSNull null]) {
                            cLogObject.sLookBoardName=@"";
                        }else{
                            cLogObject.sLookBoardName=[dictData objectForKey:@"LookBoardName"];
                        }
                        cLogObject.sTaskContent=[[dictData objectForKey:@"TaskContent"] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
                        cLogObject.sUserInfo=[dictData objectForKey:@"UserInfo"];
                        
                        [resultLogInfoArray addObject:cLogObject];
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

//获取日志信息
+(void)getLogDataWithBeginTime:(NSString*)beginTime
                        dayNum:(NSInteger)dayNum
                         iType:(NSInteger)iType
                        userID:(NSString*)userID
                     companyID:(NSString*)companyID
                   returnBlock:(returnLogDataWithErrMsgBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaBeginTime=[NSString stringWithFormat:@"BeginTime=%@",beginTime];
    [arryInfo addObject:sParaBeginTime];
    
    NSString *sParaDayNum=[NSString stringWithFormat:@"DaysNum=%ld",(long)dayNum];
    [arryInfo addObject:sParaDayNum];

    NSString *sParaType=[NSString stringWithFormat:@"iType=%ld",(long)iType];
    [arryInfo addObject:sParaType];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetLogInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                //日志
                NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                NSArray *detailLogInfoArray=[returnData objectForKey:@"Result"];
                if (detailLogInfoArray.count>0) {
                    for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                        NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                        
                        BOOL bIsLogExist=[[dictData objectForKey:@"IsLogExist"] boolValue];
                        ClassLog *cLogObject=[[ClassLog alloc] init];
                        cLogObject.isLogExist=bIsLogExist;
                        cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];
                        cLogObject.sLogState=[dictData objectForKey:@"LogState"];
                        
                        //有填报日志时才记录详细信息
                        if (bIsLogExist || [cLogObject.sLogState integerValue]==LogStateTypeFinished) {
                            cLogObject.sLogID=[dictData objectForKey:@"LogID"];     //日志ID
                            cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];   //日志日期
                            cLogObject.sConfirmUserID=[dictData objectForKey:@"ConfirmUserID"];  //考评人ID
                            cLogObject.sConfirmUser=[dictData objectForKey:@"ConfirmUser"];    //考评人姓名
                            cLogObject.sLogScore=[dictData objectForKey:@"LogScore"];       //日志积分
                            cLogObject.sLogContent=[dictData objectForKey:@"LogContent"];     //日志内容
                            cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];  //上传文件信息（包含子集
                            cLogObject.sEvaluationItemInfo=[dictData objectForKey:@"EvaluationItemInfo"]; //考评项信息
                        }
                        
                        [resultLogInfoArray addObject:cLogObject];
                    }
                }
                returnBlock(YES,[resultLogInfoArray copy],@"");
            }else{
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                returnBlock(NO,nil,sErrorMsg);
            }
        }else{
            returnBlock(NO,nil,sError);
        }
    }];
}

//获取指定日期日志信息
+(void)getLogDataWithDate:(NSString*)sDate
                   dayNum:(NSInteger)dayNum
                    iType:(NSInteger)iType
                   userID:(NSString*)userID
                companyID:(NSString*)companyID
             fatherObject:(id)fatherObject
              returnBlock:(returnLogDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaBeginTime=[NSString stringWithFormat:@"BeginTime=%@",sDate];
    [arryInfo addObject:sParaBeginTime];
    
    NSString *sParaDayNum=[NSString stringWithFormat:@"DaysNum=%ld",(long)dayNum];
    [arryInfo addObject:sParaDayNum];
    
    NSString *sParaType=[NSString stringWithFormat:@"iType=%ld",(long)iType];
    [arryInfo addObject:sParaType];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetLogInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc) {
                //日志
                NSMutableArray *resultLogInfoArray=[[NSMutableArray alloc] init];
                NSArray *detailLogInfoArray=[returnData objectForKey:@"Result"];
                if (detailLogInfoArray.count>0) {
                    for (int i=0; i<=detailLogInfoArray.count-1; i++) {
                        NSDictionary *dictData=[detailLogInfoArray objectAtIndex:i];
                        
                        BOOL bIsLogExist=[[dictData objectForKey:@"IsLogExist"] boolValue];
                        ClassLog *cLogObject=[[ClassLog alloc] init];
                        cLogObject.isLogExist=bIsLogExist;
                        cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];
                        cLogObject.sLogState=[dictData objectForKey:@"LogState"];
                        
                        //有填报日志时才记录详细信息
                        if (bIsLogExist || [cLogObject.sLogState integerValue]==LogStateTypeFinished) {
                            cLogObject.sLogID=[dictData objectForKey:@"LogID"];     //日志ID
                            cLogObject.sLogDate=[dictData objectForKey:@"LogDate"];   //日志日期
                            cLogObject.sConfirmUserID=[dictData objectForKey:@"ConfirmUserID"];  //考评人ID
                            cLogObject.sConfirmUser=[dictData objectForKey:@"ConfirmUser"];    //考评人姓名
                            cLogObject.sLogScore=[dictData objectForKey:@"LogScore"];       //日志积分
                            cLogObject.sLogContent=[dictData objectForKey:@"LogContent"];     //日志内容
                            cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];  //上传文件信息（包含子集
                            cLogObject.sEvaluationItemInfo=[dictData objectForKey:@"EvaluationItemInfo"]; //考评项信息
                        }
                        
                        [resultLogInfoArray addObject:cLogObject];
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

//获取考评人信息(新建日志时需要)
+ (void)getDefaultConfirmUserWithID:(NSString*)sID
                          companyID:(NSString*)companyID
                       fatherObject:(id)fatherObject
                        returnBlock:(returnLogDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/NewGetDefaultConfirmUser_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                 NSDictionary *dictData=[returnData objectForKey:@"Result"];
                 NSArray *detailDataArray=[dictData objectForKey:@"rows"];
                 if (detailDataArray.count>0) {
                     for (int i=0; i<=detailDataArray.count-1; i++) {
                         NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                         ClassLog *cLogObject=[[ClassLog alloc] init];
                         cLogObject.sCompanyUserID=[dictData objectForKey:@"CompanyUserID"];
                         //NSLog(@"%@",[dictData objectForKey:@"CompanyUserName"]);
                         cLogObject.sCompangUserName=[dictData objectForKey:@"CompanyUserName"];
                         [resultMutableArray addObject:cLogObject];
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



//新建日志
+ (void)createLogUserWithID:(NSString*)createuserguid
                  companyID:(NSString*)companyID
                    logdate:(NSString*)logdate
                 logcontent:(NSString*)logcontent
            confirmuserguid:(NSString*)confirmuserguid
               fatherObject:(id)fatherObject
                returnBlock:(returnLogDataBlock)returnBlock;{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParacreateuserguid=[NSString stringWithFormat:@"createuserguid=%@",createuserguid];
    [arryInfo addObject:sParacreateuserguid];
    
    NSString *sParacompanyID=[NSString stringWithFormat:@"companyID=%@",companyID];
    [arryInfo addObject:sParacompanyID];
    
    
    NSString *sParalogdate=[NSString stringWithFormat:@"logdate=%@",logdate];
    [arryInfo addObject:sParalogdate];
    
    NSString *sParalogcontent=[NSString stringWithFormat:@"logcontent=%@",logcontent];
    [arryInfo addObject:sParalogcontent];
    
    NSString *sParaconfirmuserguid=[NSString stringWithFormat:@"confirmuserguid=%@",confirmuserguid];
    [arryInfo addObject:sParaconfirmuserguid];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/CreateEmployeesLog_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//编辑日志
+ (void)editLogUserWithLogID:(NSString*)logID
             confirmuserguid:(NSString*)confirmuserguid
                  logcontent:(NSString*)logcontent
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParalogID=[NSString stringWithFormat:@"logID=%@",logID];
    [arryInfo addObject:sParalogID];
    
    NSString *sParaconfirmuserguid=[NSString stringWithFormat:@"confirmuserguid=%@",confirmuserguid];
    [arryInfo addObject:sParaconfirmuserguid];
    
    NSString *sParalogcontent=[NSString stringWithFormat:@"logcontent=%@",logcontent];
    [arryInfo addObject:sParalogcontent];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/EditEmployeesLog_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//删除日志中的文件
+ (void)deleteLogFileWithFilePath:(NSString*)FilePath
                     fatherObject:(id)fatherObject
                      returnBlock:(returnLogDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaFilePath=[NSString stringWithFormat:@"FilePath=%@",FilePath];
    [arryInfo addObject:sParaFilePath];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@UploadService/DelFile_App",KServerUrl_file] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//删除数据库中的文件路径（成功删除文件后调用）
+ (void)deleteLogFilePathWithFileID:(NSString*)FileID
                        returnBlock:(returnLogDataWithErrMsgBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    NSString *sParaFileID=[NSString stringWithFormat:@"FileID=%@",FileID];
    [arryInfo addObject:sParaFileID];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/DelFilePath_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                returnBlock(YES,nil,@"");
            }else{
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                returnBlock(NO,nil,sErrorMsg);
            }
        }else{
            returnBlock(NO,nil,sError);
        }
    }];
}

//保存上传文件路径服务（文件上传成功后调用）
+ (void)saveUpLoadFilePathWithLogDate:(NSString*)logDate
                             FileName:(NSString*)FileName
                             FilePath:(NSString*)FilePath
                               UserID:(NSString*)UserID
                            CompanyID:(NSString*)CompanyID
                         fatherObject:(id)fatherObject
                          returnBlock:(returnLogDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParalogDate=[NSString stringWithFormat:@"LogDate=%@",logDate];
    [arryInfo addObject:sParalogDate];
    
    NSString *sParaFileName=[NSString stringWithFormat:@"FileName=%@",FileName];
    [arryInfo addObject:sParaFileName];
    
    NSString *sParaFilePath=[NSString stringWithFormat:@"FilePath=%@",FilePath];
    [arryInfo addObject:sParaFilePath];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/SaveUploadFilePath",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//图片在线预览
+ (void)imagePreviewWithStrUrl:(NSString*)strUrl
                  fatherObject:(id)fatherObject
                   returnBlock:(returnLogDictionaryDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParastrUrl=[NSString stringWithFormat:@"strUrl=%@%@",KServerUrl_file2,strUrl];
    [arryInfo addObject:sParastrUrl];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@UploadService/ImagePreview_App",KServerUrl_file] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 returnBlock(YES,[[returnData objectForKey:@"Result"] firstObject]);
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

//提交日志
+ (void)commitLogWithTaskID:(NSString*)taskID
                  companyID:(NSString*)companyID
                   userName:(NSString*)userName
               fatherObject:(id)fatherObject
                returnBlock:(returnLogDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParataskID=[NSString stringWithFormat:@"taskid=%@",taskID];
    [arryInfo addObject:sParataskID];
    
    NSString *sParacompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParacompanyID];
    
    NSString *sParauserName=[NSString stringWithFormat:@"UserName=%@",userName];
    [arryInfo addObject:sParauserName];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/CommitLog_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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

//后台下载文件
+ (void)downFileWithFilePath:(NSString*)filePath
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock{
    
    NSString *urlStr=[NSString stringWithFormat: @"%@%@",KServerUrl_file,filePath];
    
    //保存文件
    NSString *sExtension=[filePath pathExtension];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *sFileTitle=[NSString stringWithFormat:@"%@.%@",currentDateStr,sExtension];
    NSString *saveUrl=[NSString stringWithFormat:@"%@/%@",[SystemPlist returnDownloadFileFolderPath],sFileTitle];

    [FZNetworkHelper downTaskInBackgroundWithUrl:urlStr arryPara:nil savePath:saveUrl  block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            returnBlock(YES,nil);
        }else{
            returnBlock(NO,nil);
        }
    }];
}

//获取部门信息
+ (void)getDepartmentDataWithID:(NSString*)sID
                   companyID:(NSString*)companyID
                     strType:(NSString*)strType
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock{


    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaStrType=[NSString stringWithFormat:@"strType=%@",strType];
    [arryInfo addObject:sParaStrType];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/NewGetDept_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                 NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                 if (detailDataArray.count>0) {
                     for (int i=0; i<=detailDataArray.count-1; i++) {
                         NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                         //只显示部门内容
                         //if ([[dictData objectForKey:@"Type"] isEqualToString:@"1"]) {
                             ClassLog *cLogObject=[[ClassLog alloc] init];
                             cLogObject.sDeptID=[dictData objectForKey:@"DeptID"];
                             cLogObject.sDeptName=[dictData objectForKey:@"DeptName"];
                             cLogObject.sDepartmentType=[dictData objectForKey:@"Type"];
                             
                             [resultMutableArray addObject:cLogObject];
                         //}
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

//获取部门日志数据
+ (void)getTeamLogDataWithID:(NSString*)sID
                   companyID:(NSString*)companyID
                   pageIndex:(NSInteger)pageIndex
                        rows:(NSInteger)rows
                       sDate:(NSString*)sDate
                     sDeptID:(NSString*)sDeptID
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaUser=[NSString stringWithFormat:@"sUser=%@",@""];
    [arryInfo addObject:sParaUser];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"page=%ld",(long)pageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    NSString *sParaDepID=[NSString stringWithFormat:@"sDeptId=%@",sDeptID];
    [arryInfo addObject:sParaDepID];
    
    NSString *sParaDate=[NSString stringWithFormat:@"Date=%@",sDate];
    [arryInfo addObject:sParaDate];
    
    NSString *sParaState=[NSString stringWithFormat:@"state=%d",2];
    [arryInfo addObject:sParaState];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetWorklogList2_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                 NSArray *detailDataArray=[[returnData objectForKey:@"Result"] objectForKey:@"rows"];
                 
                 if (detailDataArray.count>0) {
                     for (int i=0; i<=detailDataArray.count-1; i++) {
                         NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        
                         ClassLog *cLogObject=[[ClassLog alloc] init];
                         cLogObject.sLogID=[dictData objectForKey:@"LogID"];     //日志ID
                         cLogObject.sLogState=[dictData objectForKey:@"State"];
                         
                         cLogObject.sCreateUserID=[dictData objectForKey:@"CreateUserID"];      //日志创建人ID
                         cLogObject.sCreateUserName=[dictData objectForKey:@"CreateUserName"];  //日志创建人姓名
                         cLogObject.sCreateUserDept=[dictData objectForKey:@"CreateUserDept"];    //日志创建人所在部门名称
                         cLogObject.sCreateUserPhoto=[dictData objectForKey:@"CreateUserPhoto"];  //日志创建人头像（Base64编码）
                         cLogObject.sLogScore=[dictData objectForKey:@"fWorkUserScore"];          //日志积分
                         cLogObject.sLogContent=[dictData objectForKey:@"vchrContent"];          //日志内容
                         cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];         //上传文件信息（包含子集
                         cLogObject.sEvaluationItemInfo=[dictData objectForKey:@"Yspy"];         //考评项信息
                         
                         [resultMutableArray addObject:cLogObject];
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


//获取更多部门日志数据 NoHUD
+ (void)getTeamLogMoreDataWithID:(NSString*)sID
                   companyID:(NSString*)companyID
                   pageIndex:(NSInteger)pageIndex
                        rows:(NSInteger)rows
                       sDate:(NSString*)sDate
                     sDeptID:(NSString*)sDeptID
                 returnBlock:(returnLogDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaUser=[NSString stringWithFormat:@"sUser=%@",@""];
    [arryInfo addObject:sParaUser];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"page=%ld",(long)pageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    NSString *sParaDepID=[NSString stringWithFormat:@"sDeptId=%@",sDeptID];
    [arryInfo addObject:sParaDepID];
    
    NSString *sParaDate=[NSString stringWithFormat:@"Date=%@",sDate];
    [arryInfo addObject:sParaDate];
    
    NSString *sParaState=[NSString stringWithFormat:@"state=%d",2];
    [arryInfo addObject:sParaState];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetWorklogList2_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
        
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[[returnData objectForKey:@"Result"] objectForKey:@"rows"];
                
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        
                        ClassLog *cLogObject=[[ClassLog alloc] init];
                        cLogObject.sLogID=[dictData objectForKey:@"LogID"];     //日志ID
                        cLogObject.sLogState=[dictData objectForKey:@"State"];
                        
                        cLogObject.sCreateUserID=[dictData objectForKey:@"CreateUserID"];      //日志创建人ID
                        cLogObject.sCreateUserName=[dictData objectForKey:@"CreateUserName"];  //日志创建人姓名
                        cLogObject.sCreateUserDept=[dictData objectForKey:@"CreateUserDept"];    //日志创建人所在部门名称
                        cLogObject.sCreateUserPhoto=[dictData objectForKey:@"CreateUserPhoto"];  //日志创建人头像（Base64编码）
                        cLogObject.sLogScore=[dictData objectForKey:@"fWorkUserScore"];          //日志积分
                        cLogObject.sLogContent=[dictData objectForKey:@"vchrContent"];          //日志内容
                        cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];         //上传文件信息（包含子集
                        cLogObject.sEvaluationItemInfo=[dictData objectForKey:@"Yspy"];         //考评项信息
                        
                        [resultMutableArray addObject:cLogObject];
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

//获取部门名称及部门下的用户信息
+ (void)getDepartmentAndUserDataWithID:(NSString*)sID
                             companyID:(NSString*)companyID
                          fatherObject:(id)fatherObject
                           returnBlock:(returnLogDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetDeptAndUser_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                 NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                 
                 if (detailDataArray.count>0) {
                     
                     for (int i=0; i<=detailDataArray.count-1; i++) {
                         NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                         //不显示admin用户
                         //if ([[dictData objectForKey:@"ID"] integerValue]!=0) {
                             ClassLog *cLogObject=[[ClassLog alloc] init];
                             cLogObject.sDeptID=[dictData objectForKey:@"ID"];
                             cLogObject.sDeptName=[dictData objectForKey:@"Name"];
                             cLogObject.sUsersNum=[dictData objectForKey:@"UsersNum"];
                             cLogObject.arrayUsers=[dictData objectForKey:@"Users"];
                             
                             [resultMutableArray addObject:cLogObject];
                         //}
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
//获取考评日志列表(所有日期下的日志)
+ (void)getNeedAssessLogDataWithID:(NSString*)sID
                         companyID:(NSString*)companyID
                            strDate:(NSString*)strDate
                         pageIndex:(NSInteger)pageIndex
                              rows:(NSInteger)rows
                      fatherObject:(id)fatherObject
                       returnBlock:(returnLogDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    NSString *sApiMethodName=@"SaaSTaskService/ConfirmLogList2_App";
    
    NSString *sParaUserID=[NSString stringWithFormat:@"userId=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    //根据日期查询
    if (![strDate isEqualToString:@""]) {
        NSString *sParastrDate=[NSString stringWithFormat:@"strDate=%@",strDate];
        [arryInfo addObject:sParastrDate];
        sApiMethodName=@"SaaSTaskService/ConfirmLogListTime2_App";
    }
    
    NSString *sParaPageIndex=[NSString stringWithFormat:@"page=%ld",(long)pageIndex];
    [arryInfo addObject:sParaPageIndex];
    
    NSString *sParaRows=[NSString stringWithFormat:@"rows=%ld",(long)rows];
    [arryInfo addObject:sParaRows];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@%@",KServerUrl_App,sApiMethodName] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                 NSArray *detailDataArray=[returnData objectForKey:@"Result"] ;
                 
                 if (detailDataArray.count>0) {
                     for (int i=0; i<=detailDataArray.count-1; i++) {
                         NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                         
                         ClassLog *cLogObject=[[ClassLog alloc] init];
                         cLogObject.bSelected=NO;
                         cLogObject.sLogID=[dictData objectForKey:@"ID"];     //日志ID
                         cLogObject.sLogDate=[dictData objectForKey:@"BeginDate"];
                         cLogObject.sCreateUserID=[dictData objectForKey:@"ConfirmUserID"];      //日志创建人ID
                         cLogObject.sCreateUserName=[dictData objectForKey:@"ConfirmUser"];  //日志创建人姓名
                         cLogObject.sCreateUserPhoto=[dictData objectForKey:@"Photo"];  //日志创建人头像（Base64编码）
                         cLogObject.sLogContent=[dictData objectForKey:@"vchrContent"];          //日志内容
                         cLogObject.arrayAccessory=[dictData objectForKey:@"Accessory"];         //上传文件信息（包含子集

                         [resultMutableArray addObject:cLogObject];
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

//获取考评日志评分项
+ (void)getEvaluationDataWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDictionaryDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",sID];
    [arryInfo addObject:sParaUserID];
    
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaCompanyID];
    
    NSString *sParaStrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParaStrUrl];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetEvaluationInfo1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
         if (bReturn) {
             BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
             if (bSuc)  {
                 NSMutableDictionary *resultMutableDictionary=[[NSMutableDictionary alloc] init];
                 //最高奖励加分
                 NSString *sMaxAward=[returnData objectForKey:@"RsCount"];
                 [resultMutableDictionary setObject:sMaxAward forKey:@"MaxAward"];
                 
                 NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                 
                 NSDictionary *curDict=[detailDataArray firstObject];
                 ClassLog *cLogObject=[[ClassLog alloc] init];
                 //评语模板
                 cLogObject.arrayCommentTemplate=[curDict objectForKey:@"CommentTemplate"];
                 //考评项目信息
                 cLogObject.arrayEvaluationItem=[curDict objectForKey:@"EvaluationItem"];
                 //一天的标准积分
                 cLogObject.sDayNum=[curDict objectForKey:@"DayNum"];
                 
                 [resultMutableDictionary setObject:cLogObject forKey:@"value"];
                 
                 returnBlock(YES,resultMutableDictionary);
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

//日志考评
+ (void)checkEmployeesLogWithSelectType:(NSInteger)iSelectType
                          strSelectDate:(NSString*)strSelectDate
                                  LogID:(NSString*)LogID
                                 UserID:(NSString*)UserID
                              CompanyID:(NSString*)CompanyID
                                    Num:(NSString*)Num
                                strYSPY:(NSString*)strYSPY
                   strLogEvaluationItem:(NSString*)strLogEvaluationItem
                           fatherObject:(id)fatherObject
                            returnBlock:(returnLogDictionaryDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaSelectType=[NSString stringWithFormat:@"iSelectType=%ld",(long)iSelectType];
    [arryInfo addObject:sParaSelectType];
    
    NSString *sParaSelectDate=[NSString stringWithFormat:@"strSelectDate=%@",strSelectDate];
    [arryInfo addObject:sParaSelectDate];
    
    NSString *sParaLogID=[NSString stringWithFormat:@"LogID=%@",LogID];
    [arryInfo addObject:sParaLogID];
    
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    
    NSString *sParaNum=[NSString stringWithFormat:@"Num=%@",Num];
    [arryInfo addObject:sParaNum];
    
    NSString *sParaYSPY=[NSString stringWithFormat:@"strYSPY=%@",strYSPY];
    [arryInfo addObject:sParaYSPY];
    
    NSString *sParaLogEvaluationItem=[NSString stringWithFormat:@"strLogEvaluationItem=%@",strLogEvaluationItem];
    [arryInfo addObject:sParaLogEvaluationItem];

    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/CheckEmployeesLog1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
     {
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
