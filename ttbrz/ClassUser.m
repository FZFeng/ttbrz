//
//  cUser.m
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  

#import "ClassUser.h"

@implementation ClassUser

#pragma mark 验证用户并获取用户信息 1.是否存在 2.是否有效用户 3.获取指定用户信息
+(void)checkUserAndGetDataWithID:(NSString*)sID sPwd:(NSString*)sPwd fatherObject:(id)fatherObject returnBlock:(returnUserDataBlock)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    //用户名
    NSString *sParaUserID=[NSString stringWithFormat:@"UserName=%@",sID];
    [arryUserInfo addObject:sParaUserID];
    //用户密码
    NSString *sParaUserPwd=[NSString stringWithFormat:@"PWD=%@",sPwd];
    [arryUserInfo addObject:sParaUserPwd];
    
    //自动登录 默认 -1
    NSString *sParaAutoLogin=@"autoLogin=-1";
    [arryUserInfo addObject:sParaAutoLogin];
    
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSBasicPlatService/UserLogin_App",KServerUrl_Saas] arryPara:[arryUserInfo copy] requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO  block:^(NSDictionary *returnData, BOOL bReturn)
    {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (bSuc)  {
                NSDictionary *dictData=[returnData objectForKey:@"Result"];
                [SystemPlist SetCompanyID:[dictData objectForKey:@"CompanyID"]];
                [SystemPlist SetUserID:[dictData objectForKey:@"UserID"]];
                [SystemPlist SetLoadPwd:sPwd];
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


#pragma mark 新用户注册
+(void)registerUserWithEmail:(NSString*)email
                   groupName:(NSString*)groupName
                     mobiTel:(NSString*)mobiTel
                         pwd:(NSString*)pwd
                fatherObject:(id)fatherObject
                 returnBlock:(blockFunctionReturn)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    //email
    NSString *sParaEmail=[NSString stringWithFormat:@"Email=%@",email];
    [arryUserInfo addObject:sParaEmail];
    //groupName
    NSString *sParaGroupName=[NSString stringWithFormat:@"GroupName=%@",groupName];
    [arryUserInfo addObject:sParaGroupName];
    //mobiTel
    NSString *sParaMobiTel=[NSString stringWithFormat:@"MobiTel=%@",mobiTel];
    [arryUserInfo addObject:sParaMobiTel];
    
    //pwd
    NSString *sParaPwd=[NSString stringWithFormat:@"PWD=%@",pwd];
    [arryUserInfo addObject:sParaPwd];
    
    [FZNetworkHelper dataTaskWithApiName:@"SaaSServiceAPI/TelRegisterCompanyInfo" arryPara:arryUserInfo requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO sWaitingMsg:nil block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (!bSuc) {
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                bReturn=NO;
            }else{
                //设置全局信息
                NSDictionary *resultDictionaryData=[returnData objectForKey:@"Result"];
                //公司编号
                NSString *companyNumString=[resultDictionaryData objectForKey:@"CompanyNum"];
                //密码
                NSString *pwdString=[resultDictionaryData objectForKey:@"Pwd"];
                //登录用户
                NSString *userString=[NSString stringWithFormat:@"admin@%@",companyNumString];
                 //保存数据到systemplist中
                [SystemPlist SetCompanyNum:companyNumString];
                [SystemPlist SetLoadPwd:pwdString];
                [SystemPlist SetLoadUser:userString];
            }
        }
        returnBlock(bReturn);
    }];
}

+(void)validUserWithEmail:(NSString *)email groupName:(NSString *)groupName mobiTel:(NSString *)mobiTel fatherObject:(id)fatherObject returnBlock:(blockFunctionReturn)returnBlock{
    
    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    //email
    NSString *sParaEmail=[NSString stringWithFormat:@"Email=%@",email];
    [arryUserInfo addObject:sParaEmail];
    //groupName
    NSString *sParaGroupName=[NSString stringWithFormat:@"GroupName=%@",groupName];
    [arryUserInfo addObject:sParaGroupName];
    //mobiTel
    NSString *sParaMobiTel=[NSString stringWithFormat:@"MobiTel=%@",mobiTel];
    [arryUserInfo addObject:sParaMobiTel];
    
    [FZNetworkHelper dataTaskWithUrl:[NSString stringWithFormat:@"%@SaaSServiceAPI/TelRegisterDataValid",KServerUrl_WWW] arryPara:arryUserInfo requestMethodType:requestMethodPost fatherObject:fatherObject bShowSuccessMsg:NO block:^(NSDictionary *returnData, BOOL bReturn) {
        if (bReturn) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (!bSuc) {
                NSString *sErrorMsg=[returnData objectForKey:@"Message"];
                [PublicFunc ShowErrorHUD:sErrorMsg view:((UIViewController*)fatherObject).view];
                bReturn=NO;
            }
        }
        returnBlock(bReturn);
    }];

}

//发送短信验证码
+(void)sendPhoneCodeWithMobiTel:(NSString*)mobiTel
                       phoneCode:(NSString*)phoneCode
                     returnBlock:(blockFunctionReturn)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];

    //mobiTel
    NSString *sParaMobiTel=[NSString stringWithFormat:@"Mobile=%@",mobiTel];
    [arryUserInfo addObject:sParaMobiTel];
    
    //email
    NSString *sParaPhoneCode=[NSString stringWithFormat:@"Code=%@",phoneCode];
    [arryUserInfo addObject:sParaPhoneCode];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSServiceAPI/SendVerificationCode",KServerUrl_WWW] arryPara:arryUserInfo requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (!bSuc) {
                returnBlock(NO);
            }else{
                returnBlock(YES);
            }
        }else{
            returnBlock(NO);
        }
    }];

}


//获取软件使用期限及日志填报时限
+ (void)getLoginInfoWithUserName:(NSString*)sUserName
                             pwd:(NSString*)sPwd
                     returnBlock:(returnUserDataBlock)returnBlock{

    NSMutableArray *arryUserInfo=[[NSMutableArray alloc] init];
    
    NSString *sParaUserName=[NSString stringWithFormat:@"UserName=%@",sUserName];
    [arryUserInfo addObject:sParaUserName];
    
    NSString *sParaPwd=[NSString stringWithFormat:@"PWD=%@",sPwd];
    [arryUserInfo addObject:sParaPwd];
    
    [FZNetworkHelper dataTaskWithUrlNoHUD:[NSString stringWithFormat:@"%@SaaSBasicPlatService/GetLoginInfo1_App",KServerUrl_Saas] arryPara:arryUserInfo requestMethodType:requestMethodPost block:^(NSDictionary *returnData, NSString *sError) {
        if ([sError isEqualToString:@""]) {
            BOOL bSuc=[[returnData objectForKey:@"IsSuc"] boolValue];
            if (!bSuc) {
                returnBlock(NO,nil);
            }else{
                NSDictionary *dictData=[[returnData objectForKey:@"Result"] firstObject];
                ClassUser *cClassObject=[[ClassUser alloc] init];
                cClassObject.sEndDay=[dictData objectForKey:@"EndDay"];
                cClassObject.sEndTime=[dictData objectForKey:@"EndTime"];
                cClassObject.sBuyEmployee=[dictData objectForKey:@"BuyEmployee"];
                cClassObject.sWorkSet=[dictData objectForKey:@"WorkSet"];
                returnBlock(YES,cClassObject);
            }
        }else{
            returnBlock(NO,nil);
        }
    }];
}
@end
