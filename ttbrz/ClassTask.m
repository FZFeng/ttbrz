//
//  ClassTask.m
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ClassTask.h"

@implementation ClassTask

//获取看板分类
+(void)getNormalClassifyKanbanDataWithGuidCompanyID:(NSString*)guidCompanyID
                                             userID:(NSString*)userID
                                               Page:(NSInteger)Page
                                               Rows:(NSInteger)Rows
                                       fatherObject:(id)fatherObject
                                        returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"guidCompanyID=%@",guidCompanyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParapage=[NSString stringWithFormat:@"Page=%ld",(long)Page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"Rows=%ld",(long)Rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/NormalClassifyKanban_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        //只显示部门内容
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        
                        cLogTaskObject.sPK_LookBoardTypeID=[dictData objectForKey:@"PK_LookBoardTypeID"];
                        cLogTaskObject.sLookBoardTypeName=[dictData objectForKey:@"LookBoardTypeName"];
                        cLogTaskObject.sShowIndex=[dictData objectForKey:@"ShowIndex"];
                        cLogTaskObject.sFK_guidCreateUserID=[dictData objectForKey:@"FK_guidCreateUserID"];
                        cLogTaskObject.sFK_guidCreateUserName=[dictData objectForKey:@"FK_guidCreateUserName"];
                        cLogTaskObject.iFK_AuthorityType=[[dictData objectForKey:@"FK_AuthorityType"] integerValue];
                        
                        NSArray *arrayAuthorityManagementInfo=[[dictData objectForKey:@"AuthorityManagementInfo"] objectForKey:@"Result"];
                        
                        NSMutableArray *arrayReturnData=[[NSMutableArray alloc] init];
                        if (arrayAuthorityManagementInfo.count>0) {
                            for (NSDictionary *dictAuthorityManagement in arrayAuthorityManagementInfo) {
                                [arrayReturnData addObject:dictAuthorityManagement];
                            }
                        }
                        cLogTaskObject.arrayAuthorityManagementInfo=arrayReturnData;
                        [resultMutableArray addObject:cLogTaskObject];
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


//获取看板分类(NoHUD)
+ (void)getNormalClassifyKanbanDataNoHUDWithGuidCompanyID:(NSString*)guidCompanyID
                                                   userID:(NSString*)userID
                                                     Page:(NSInteger)Page
                                                     Rows:(NSInteger)Rows
                                              returnBlock:(returnTaskClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"guidCompanyID=%@",guidCompanyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParapage=[NSString stringWithFormat:@"Page=%ld",(long)Page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"Rows=%ld",(long)Rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/NormalClassifyKanban_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        //只显示部门内容
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        
                        cLogTaskObject.sPK_LookBoardTypeID=[dictData objectForKey:@"PK_LookBoardTypeID"];
                        cLogTaskObject.sLookBoardTypeName=[dictData objectForKey:@"LookBoardTypeName"];
                        cLogTaskObject.sShowIndex=[dictData objectForKey:@"ShowIndex"];
                        cLogTaskObject.sFK_guidCreateUserID=[dictData objectForKey:@"FK_guidCreateUserID"];
                        cLogTaskObject.sFK_guidCreateUserName=[dictData objectForKey:@"FK_guidCreateUserName"];
                        cLogTaskObject.iFK_AuthorityType=[[dictData objectForKey:@"FK_AuthorityType"] integerValue];
                        NSArray *arrayAuthorityManagementInfo=[[dictData objectForKey:@"AuthorityManagementInfo"] objectForKey:@"Result"];
                        
                        NSMutableArray *arrayReturnData=[[NSMutableArray alloc] init];
                        if (arrayAuthorityManagementInfo.count>0) {
                            for (NSDictionary *dictAuthorityManagement in arrayAuthorityManagementInfo) {
                                [arrayReturnData addObject:dictAuthorityManagement];
                            }
                        }
                        cLogTaskObject.arrayAuthorityManagementInfo=arrayReturnData;
                        
                        [resultMutableArray addObject:cLogTaskObject];
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

//新建看板分类
+ (void)NewKanbanClassificationWithName:(NSString*)sName
                              ShowIndex:(NSInteger)ShowIndex
                          AuthorityType:(NSString*)AuthorityType
                           AuthorityIds:(NSString*)AuthorityIds
                                 UserID:(NSString*)UserID
                              CompanyID:(NSString*)CompanyID
                           fatherObject:(id)fatherObject
                            returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaName=[NSString stringWithFormat:@"Name=%@",sName];
    [arryInfo addObject:sParaName];
    
    NSString *sParaShowIndex=[NSString stringWithFormat:@"ShowIndex=%ld",(long)ShowIndex];
    [arryInfo addObject:sParaShowIndex];
    
    NSString *sParaAuthorityType=[NSString stringWithFormat:@"AuthorityType=%@",AuthorityType];
    [arryInfo addObject:sParaAuthorityType];
    
    NSString *sParaAuthorityIds=[NSString stringWithFormat:@"AuthorityIds=%@",AuthorityIds];
    [arryInfo addObject:sParaAuthorityIds];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/NewKanbanClassification_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//编辑看板分类或归档看析分类）State=0 编辑 State=1 归档
+ (void)editKanbanClassificationWithName:(NSString*)sName
                               ShowIndex:(NSInteger)ShowIndex
                                   State:(NSInteger)State
                            KanBanTypeId:(NSString*)KanBanTypeId
                           AuthorityType:(NSString*)AuthorityType
                            AuthorityIds:(NSString*)AuthorityIds
                                  UserID:(NSString*)UserID
                               CompanyID:(NSString*)CompanyID
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaName=[NSString stringWithFormat:@"Name=%@",sName];
    [arryInfo addObject:sParaName];
    
    NSString *sParaShowIndex=[NSString stringWithFormat:@"ShowIndex=%ld",(long)ShowIndex];
    [arryInfo addObject:sParaShowIndex];
    
    NSString *sParaState=[NSString stringWithFormat:@"State=%ld",(long)State];
    [arryInfo addObject:sParaState];
    
    NSString *sParaKanBanTypeId=[NSString stringWithFormat:@"KanBanTypeId=%@",KanBanTypeId];
    [arryInfo addObject:sParaKanBanTypeId];
    
    NSString *sParaAuthorityType=[NSString stringWithFormat:@"AuthorityType=%@",AuthorityType];
    [arryInfo addObject:sParaAuthorityType];
    
    NSString *sParaAuthorityIds=[NSString stringWithFormat:@"AuthorityIds=%@",AuthorityIds];
    [arryInfo addObject:sParaAuthorityIds];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/EditKanbanClassification_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//删除看板分类
+ (void)DeleteKanbanClassificationWithKanbanTypeId:(NSString*)sKanbanTypeId
                                            UserID:(NSString*)UserID
                                         CompanyID:(NSString*)CompanyID
                                      fatherObject:(id)fatherObject
                                       returnBlock:(returnTaskClassDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaKanbanTypeId=[NSString stringWithFormat:@"KanbanTypeId=%@",sKanbanTypeId];
    [arryInfo addObject:sParaKanbanTypeId];
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/DeleteKanbanClassification_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//获取部门及部门下的子部门用户(选择可见人员时调用)
+ (void)GetAllDeptTreeWithUserID:(NSString*)UserID
                       CompanyID:(NSString*)CompanyID
                    fatherObject:(id)fatherObject
                     returnBlock:(returnTaskClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetAllDeptTree1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        //只显示部门内容
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        cLogTaskObject.sDeptID=[dictData objectForKey:@"ID"];
                        cLogTaskObject.sDeptName=[dictData objectForKey:@"Name"];
                        cLogTaskObject.arrayUsers=[dictData objectForKey:@"Users"];
                        
                        [resultMutableArray addObject:cLogTaskObject];
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

//获取看板及看板下的任务信息
+ (void)GetLookBoardAndTaskDataWithCompanyID:(NSString*)companyID
                                      userID:(NSString*)userID
                          strLookBoardTypeID:(NSString*)strLookBoardTypeID
                                        Page:(NSInteger)Page
                                        Rows:(NSInteger)Rows
                                fatherObject:(id)fatherObject
                                 returnBlock:(returnTaskClassDataBlock)returnBlock{


    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParastrLookBoardTypeID=[NSString stringWithFormat:@"strLookBoardTypeID=%@",strLookBoardTypeID];
    [arryInfo addObject:sParastrLookBoardTypeID];
    
    NSString *sParapage=[NSString stringWithFormat:@"Page=%ld",(long)Page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"Rows=%ld",(long)Rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetLookBoardAndTaskInfo1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];

                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];

                        cLogTaskObject.sLookBoardID=[dictData objectForKey:@"LookBoardID"];
                        cLogTaskObject.sLookBoardName=[dictData objectForKey:@"LookBoardName"];
                        cLogTaskObject.bIsCompetence=[[dictData objectForKey:@"IsCompetence"] boolValue];
    
                        //任务数据
                        NSArray *arrayTaskInfo=[[dictData objectForKey:@"TaskInfo"] objectForKey:@"Result"];
                        NSMutableArray *arrayReturnTaskInfo=[[NSMutableArray alloc] init];
                        if (arrayTaskInfo.count>0) {
                            for (NSDictionary *dictTaskInfo in arrayTaskInfo) {
                                cLogTaskObject.arrayTaskInfo=[[NSMutableArray alloc] init];
                                [cLogTaskObject.arrayTaskInfo addObject:dictTaskInfo];
                                [arrayReturnTaskInfo addObject:dictTaskInfo];
                            }
                        }
                        cLogTaskObject.arrayTaskInfo=arrayReturnTaskInfo;
                        cLogTaskObject.sState=[dictData objectForKey:@"State"];
                        [resultMutableArray addObject:cLogTaskObject];
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

//获取看板及看板下的任务信息(获取某一看板下的任务)
+ (void)GetCertainLookBoardAndTaskDataWithCompanyID:(NSString*)companyID
                                             userID:(NSString*)userID
                                        LookBoardID:(NSString*)LookBoardID
                                               Page:(NSInteger)Page
                                               Rows:(NSInteger)Rows
                                        returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    
    NSString *sParastrLookBoardID=[NSString stringWithFormat:@"LookBoardID=%@",LookBoardID];
    [arryInfo addObject:sParastrLookBoardID];
    
    
    NSString *sParapage=[NSString stringWithFormat:@"Page=%ld",(long)Page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"Rows=%ld",(long)Rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetTaskInfo_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        [resultMutableArray addObject:dictData];
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

//操作看板(新建看板, 编辑看板,归档看板,删除看板)
+ (void)operateKanBanWithCompanyID:(NSString*)companyID
                            userID:(NSString*)userID
                strLookBoardTypeID:(NSString*)strLookBoardTypeID
                    strLookBoardID:(NSString*)strLookBoardID
                  strLookBoardName:(NSString*)strLookBoardName
                 OperateKanBanType:(ClassTaskOperateKanBanType)OperateKanBanType
                      fatherObject:(id)fatherObject
                       returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    NSString *sApiName=@"";
    
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];

    
    switch (OperateKanBanType) {
        case ClassTaskOperateKanBanTypeAdd:{
            sApiName=@"CreateLookBoard_App";
            
            NSString *sParastrLookBoardTypeID=[NSString stringWithFormat:@"strLookBoardTypeID=%@",strLookBoardTypeID];
            [arryInfo addObject:sParastrLookBoardTypeID];
            
            NSString *sParastrLookBoardName=[NSString stringWithFormat:@"strLookBoardName=%@",strLookBoardName];
            [arryInfo addObject:sParastrLookBoardName];
            
            break;
        }case ClassTaskOperateKanBanTypeEdit:{
            sApiName=@"EditLookBoard_App";
            
            NSString *sParastrLookBoardID=[NSString stringWithFormat:@"strLookBoardID=%@",strLookBoardID];
            [arryInfo addObject:sParastrLookBoardID];
            
            NSString *sParastrLookBoardName=[NSString stringWithFormat:@"strLookBoardName=%@",strLookBoardName];
            [arryInfo addObject:sParastrLookBoardName];
            
            break;
        }case ClassTaskOperateKanBanTypeSave:{
            sApiName=@"ArchiveLookBoard_App";
            
            NSString *sParastrLookBoardID=[NSString stringWithFormat:@"strLookBoardID=%@",strLookBoardID];
            [arryInfo addObject:sParastrLookBoardID];

            break;
        }case ClassTaskOperateKanBanTypeDelete:{
            sApiName=@"DeleteLookBoard_App";
            
            NSString *sParastrLookBoardID=[NSString stringWithFormat:@"strLookBoardID=%@",strLookBoardID];
            [arryInfo addObject:sParastrLookBoardID];

            break;
        }
        default:
            break;
    }
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/%@",KServerUrl_App,sApiName] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *arrayReturn=[[NSMutableArray alloc] init];
                [arrayReturn addObject:[returnData objectForKey:@"Result"]];
                returnBlock(YES,[arrayReturn copy]);
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

//新建任务
+ (void)createTaskLookBoardWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                             strTaskName:(NSString*)strTaskName
                          strLookBoardID:(NSString*)strLookBoardID
                           strFinishDate:(NSString*)strFinishDate
                        strExecuteUserID:(NSString*)strExecuteUserID
                          strTaskContent:(NSString*)strTaskContent
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParastrLookBoardID=[NSString stringWithFormat:@"strLookBoardID=%@",strLookBoardID];
    [arryInfo addObject:sParastrLookBoardID];
    
    NSString *sParastrFinishDate=[NSString stringWithFormat:@"strFinishDate=%@",strFinishDate];
    [arryInfo addObject:sParastrFinishDate];
   
    NSString *sParastrLookBoardTypeID=[NSString stringWithFormat:@"strTaskName=%@",strTaskName];
    [arryInfo addObject:sParastrLookBoardTypeID];
    
    
    NSString *sParastrExecuteUserID=[NSString stringWithFormat:@"strExecuteUserID=%@",strExecuteUserID];
    [arryInfo addObject:sParastrExecuteUserID];
    
    NSString *sParastrTaskContent=[NSString stringWithFormat:@"strTaskContent=%@",strTaskContent];
    [arryInfo addObject:sParastrTaskContent];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/CreateTask_LookBoard_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        //只显示部门内容
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        
                        cLogTaskObject.sTaskID=[dictData objectForKey:@"TaskID"];
                        cLogTaskObject.sTaskName=[dictData objectForKey:@"TaskName"];
                        [resultMutableArray addObject:cLogTaskObject];
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

//编辑任务
+ (void)editTaskLookBoardWithCompanyID:(NSString*)companyID
                                userID:(NSString*)userID
                             strTaskID:(NSString*)strTaskID
                           strTaskName:(NSString*)strTaskName
                        strLookBoardID:(NSString*)strLookBoardID
                         strFinishDate:(NSString*)strFinishDate
                      strExecuteUserID:(NSString*)strExecuteUserID
                        strTaskContent:(NSString*)strTaskContent
                          fatherObject:(id)fatherObject
                           returnBlock:(returnTaskClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParastrLookBoardID=[NSString stringWithFormat:@"strLookBoardID=%@",strLookBoardID];
    [arryInfo addObject:sParastrLookBoardID];
    
    NSString *sParastrFinishDate=[NSString stringWithFormat:@"strFinishDate=%@",strFinishDate];
    [arryInfo addObject:sParastrFinishDate];
    
    NSString *sParastrLookBoardTypeID=[NSString stringWithFormat:@"strTaskName=%@",strTaskName];
    [arryInfo addObject:sParastrLookBoardTypeID];
    
    NSString *sParastrTaskID=[NSString stringWithFormat:@"strTaskID=%@",strTaskID];
    [arryInfo addObject:sParastrTaskID];
    
    NSString *sParastrExecuteUserID=[NSString stringWithFormat:@"strExecuteUserID=%@",strExecuteUserID];
    [arryInfo addObject:sParastrExecuteUserID];
    
    NSString *sParastrTaskContent=[NSString stringWithFormat:@"strTaskContent=%@",strTaskContent];
    [arryInfo addObject:sParastrTaskContent];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/EditTask_LookBoard_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//归档任务
+ (void)archiveTaskWithCompanyID:(NSString*)companyID
                          userID:(NSString*)userID
                       strTaskID:(NSString*)strTaskID
                    fatherObject:(id)fatherObject
                     returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    
    NSString *sParastrTaskID=[NSString stringWithFormat:@"strTaskID=%@",strTaskID];
    [arryInfo addObject:sParastrTaskID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/ArchiveTask_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//删除任务
+ (void)deleteTaskLookBoardWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                                  TaskID:(NSString*)TaskID
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    
    NSString *sParastrTaskID=[NSString stringWithFormat:@"TaskID=%@",TaskID];
    [arryInfo addObject:sParastrTaskID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/DeleteTask_LookBoard_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
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

//获取看板列表信息（选择看板时调用）
+ (void)getLookBoardList:(NSString*)UserID
               CompanyID:(NSString*)CompanyID
            fatherObject:(id)fatherObject
             returnBlock:(returnTaskClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    
    NSString *sParaUserID=[NSString stringWithFormat:@"UserID=%@",UserID];
    [arryInfo addObject:sParaUserID];
    
    NSString *sParaCompanyID=[NSString stringWithFormat:@"CompanyID=%@",CompanyID];
    [arryInfo addObject:sParaCompanyID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetLookBoardList_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        //只显示部门内容
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        cLogTaskObject.sPK_LookBoardTypeID=[dictData objectForKey:@"LookBoardTypeID"];
                        cLogTaskObject.sLookBoardTypeName=[dictData objectForKey:@"LookBoardTypeName"];
                        cLogTaskObject.arrayLookBoardList=[dictData objectForKey:@"LookBoard"];
                        
                        [resultMutableArray addObject:cLogTaskObject];
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

//获取团队任务信息
+ (void)getDeptTaskPlanListWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                               pageindex:(NSInteger)pageindex
                                pagesize:(NSInteger)pagesize
                                  deptid:(NSString*)deptid
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParadeptid=[NSString stringWithFormat:@"deptid=%@",deptid];
    [arryInfo addObject:sParadeptid];
    
    NSString *sParapage=[NSString stringWithFormat:@"pageindex=%ld",(long)pageindex];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"pagesize=%ld",(long)pagesize];
    [arryInfo addObject:sPararows];
    
    NSString *sParastrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParastrUrl];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/GetDeptTaskPlanList_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                    
                        //用户信息数据
                        NSDictionary *dictMemberInfo=[dictData objectForKey:@"WorkUser"];
                        
                        cLogTaskObject.sUserID=[dictMemberInfo objectForKey:@"UserID"];
                        cLogTaskObject.sUserName=[dictMemberInfo objectForKey:@"UserName"];
                        cLogTaskObject.sDeptName=[dictMemberInfo objectForKey:@"Dept"];
                        cLogTaskObject.sVchrPhoto=[dictMemberInfo objectForKey:@"vchrPhoto"];

                        //任务数据
                        NSArray *arrayTaskInfo=[dictData objectForKey:@"NoCompletedTaskList"];
                        NSMutableArray *arraySaveTaskInfo=[[NSMutableArray alloc] init];
                        if (arrayTaskInfo.count>0) {
                            for (NSDictionary *dictTaskInfo in arrayTaskInfo) {
                                ClassTask *cTaskInfoData=[[ClassTask alloc] init];
                                
                                cTaskInfoData.sTaskID=[dictTaskInfo objectForKey:@"TaskGuidId"];
                                
                                BOOL bOntime=[[dictTaskInfo objectForKey:@"IsOntime"] boolValue];
                                NSString *sendDate=@"尽快";
                                if (bOntime) {
                                    sendDate=[dictTaskInfo objectForKey:@"DtEnd"];
                                }
                                cTaskInfoData.sDtEnd=sendDate;
                                cTaskInfoData.sProgress=[NSString stringWithFormat:@"%ld%%",[[dictTaskInfo objectForKey:@"Progress" ] integerValue]];
                                cTaskInfoData.bIsOntime=bOntime;
                                cTaskInfoData.sTaskTitle=[dictTaskInfo objectForKey:@"TaskTitle"];
                                [arraySaveTaskInfo addObject:cTaskInfoData];
                            }
                        }
                        cLogTaskObject.arrayNoCompletedTaskList=[arraySaveTaskInfo copy];
                        [resultMutableArray addObject:cLogTaskObject];
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

//获取团队任务信息(noHud)
+ (void)getDeptTaskPlanListNoHUDWithCompanyID:(NSString*)companyID
                                       userID:(NSString*)userID
                                    pageindex:(NSInteger)pageindex
                                     pagesize:(NSInteger)pagesize
                                       deptid:(NSString*)deptid
                                  returnBlock:(returnTaskClassDataBlock)returnBlock{

    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParadeptid=[NSString stringWithFormat:@"deptid=%@",deptid];
    [arryInfo addObject:sParadeptid];
    
    NSString *sParapage=[NSString stringWithFormat:@"pageindex=%ld",(long)pageindex];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"pagesize=%ld",(long)pagesize];
    [arryInfo addObject:sPararows];
    
    NSString *sParastrUrl=[NSString stringWithFormat:@"strUrl=%@",KStrUrl];
    [arryInfo addObject:sParastrUrl];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/GetDeptTaskPlanList_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *detailDataArray=[returnData objectForKey:@"Result"];
                if (detailDataArray.count>0) {
                    for (int i=0; i<=detailDataArray.count-1; i++) {
                        NSDictionary *dictData=[detailDataArray objectAtIndex:i];
                        ClassTask *cLogTaskObject=[[ClassTask alloc] init];
                        
                        //用户信息数据
                        NSDictionary *dictMemberInfo=[dictData objectForKey:@"WorkUser"];
                        
                        cLogTaskObject.sUserID=[dictMemberInfo objectForKey:@"UserID"];
                        cLogTaskObject.sUserName=[dictMemberInfo objectForKey:@"UserName"];
                        cLogTaskObject.sDeptName=[dictMemberInfo objectForKey:@"Dept"];
                        cLogTaskObject.sVchrPhoto=[dictMemberInfo objectForKey:@"vchrPhoto"];
                        
                        //任务数据
                        NSArray *arrayTaskInfo=[dictData objectForKey:@"NoCompletedTaskList"];
                        NSMutableArray *arraySaveTaskInfo=[[NSMutableArray alloc] init];
                        if (arrayTaskInfo.count>0) {
                            for (NSDictionary *dictTaskInfo in arrayTaskInfo) {
                                ClassTask *cTaskInfoData=[[ClassTask alloc] init];
                                
                                cTaskInfoData.sTaskID=[dictTaskInfo objectForKey:@"TaskGuidId"];
                                
                                BOOL bOntime=[[dictTaskInfo objectForKey:@"IsOntime"] boolValue];
                                NSString *sendDate=@"尽快";
                                if (bOntime) {
                                    sendDate=[dictTaskInfo objectForKey:@"DtEnd"];
                                }
                                cTaskInfoData.sDtEnd=sendDate;
                                cTaskInfoData.sProgress=[NSString stringWithFormat:@"%ld%%",[[dictTaskInfo objectForKey:@"Progress" ] integerValue]];
                                cTaskInfoData.bIsOntime=bOntime;
                                cTaskInfoData.sTaskTitle=[dictTaskInfo objectForKey:@"TaskTitle"];
                                [arraySaveTaskInfo addObject:cTaskInfoData];
                            }
                        }
                        cLogTaskObject.arrayNoCompletedTaskList=[arraySaveTaskInfo copy];
                        [resultMutableArray addObject:cLogTaskObject];
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

+ (void)getSelfPlanTaskAllCompanyID:(NSString*)companyID
                             userID:(NSString*)userID
                       fatherObject:(id)fatherObject
                        returnBlock:(returnTaskDictionaryDataBlock)returnBlock{
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSTaskService/SelfPlanTaskAll1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableDictionary *dictMutableResult=[[NSMutableDictionary alloc] init];
                NSDictionary *dictData=[[returnData objectForKey:@"Result"] firstObject];
                
                //keys： TaskIng  TaskNo  TaskOK
                for (NSString *sKey in [dictData allKeys]) {
                    NSArray *arrayTaskInfo=[[dictData objectForKey:sKey] objectForKey:@"Result"];
                    NSMutableArray *arraySaveTaskInfo=[[NSMutableArray alloc] init];
                    if (arrayTaskInfo.count>0) {
                        for (NSDictionary *dictTaskInfo in arrayTaskInfo) {
                            ClassTask *cTaskInfoData=[[ClassTask alloc] init];
                            cTaskInfoData.sTaskID=[dictTaskInfo objectForKey:@"TaskID"];
                            cTaskInfoData.sTaskName=[dictTaskInfo objectForKey:@"TaskName"];
                            cTaskInfoData.sDtEnd=[dictTaskInfo objectForKey:@"TimeEnd"];
                            cTaskInfoData.sProgress=[dictTaskInfo objectForKey:@"Progress"];
                            cTaskInfoData.sExecuteUserName=[dictTaskInfo objectForKey:@"ExecuteUserName"];
                            cTaskInfoData.bIsExpired=[[dictTaskInfo objectForKey:@"IsExpired"] boolValue];
                            [arraySaveTaskInfo addObject:cTaskInfoData];
                        }
                        [dictMutableResult setObject:arraySaveTaskInfo forKey:sKey];
                    }
                }
                returnBlock(YES,dictMutableResult);
                
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

+ (void)getSelfPlanTaskNoHUDCompanyID:(NSString*)companyID
                               userID:(NSString*)userID
                                 Page:(NSInteger)Page
                                 Rows:(NSInteger)Rows
                     TaskSelfPlanType:(ClassTaskSelfPlanType)TaskSelfPlanType
                          returnBlock:(returnTaskClassDataBlock)returnBlock{
    
    NSMutableArray *arryInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaguidCompanyID=[NSString stringWithFormat:@"CompanyID=%@",companyID];
    [arryInfo addObject:sParaguidCompanyID];
    
    NSString *sParauserID=[NSString stringWithFormat:@"UserID=%@",userID];
    [arryInfo addObject:sParauserID];
    
    NSString *sParastrLookBoardID=[NSString stringWithFormat:@"Type=%ld",(long)TaskSelfPlanType];
    [arryInfo addObject:sParastrLookBoardID];
    
    NSString *sParapage=[NSString stringWithFormat:@"Page=%ld",(long)Page];
    [arryInfo addObject:sParapage];
    
    NSString *sPararows=[NSString stringWithFormat:@"Rows=%ld",(long)Rows];
    [arryInfo addObject:sPararows];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSTaskService/SelfPlanTask1_App",KServerUrl_App] arryPara:[arryInfo copy] requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSMutableArray *resultMutableArray=[[NSMutableArray alloc] init];
                NSArray *arrayTaskInfo=[returnData objectForKey:@"Result"];
                
                if (arrayTaskInfo.count>0) {
                    for (NSDictionary *dictTaskInfo in arrayTaskInfo) {
                        ClassTask *cTaskInfoData=[[ClassTask alloc] init];
                        cTaskInfoData.sTaskID=[dictTaskInfo objectForKey:@"TaskID"];
                        cTaskInfoData.sTaskName=[dictTaskInfo objectForKey:@"TaskName"];
                        cTaskInfoData.sDtEnd=[dictTaskInfo objectForKey:@"TimeEnd"];
                        cTaskInfoData.sProgress=[dictTaskInfo objectForKey:@"Progress"];
                        cTaskInfoData.sExecuteUserName=[dictTaskInfo objectForKey:@"ExecuteUserName"];
                        cTaskInfoData.bIsExpired=[[dictTaskInfo objectForKey:@"IsExpired"] boolValue];
                        
                        [resultMutableArray addObject:cTaskInfoData];
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
