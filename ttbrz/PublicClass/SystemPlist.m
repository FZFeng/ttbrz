//
//  cSystemPlist.m
//  BaseModel
//
//  Created by apple on 15/9/1.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//



#import "SystemPlist.h"

#define dbLogin            @"bLogin"
#define dsCompanyNum       @"sCompanyNum"
#define dsUser             @"sUser"
#define dsPwd              @"sPwd"
#define dsHeadLogoFileName @"headlogo.png"
#define dsTaken            @"sTaken"
#define dsCompanyID        @"sCompanyID"
#define dsUserID           @"UserID"
#define dsEmail            @"sEmail"
#define dsPhoto            @"sPhoto"
#define dsRootDomain       @"sRootDomain"

#define dsSystemPlistPath [NSString stringWithFormat:@"%@/SystemPlist.plist",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]


//#define dsHeadLogoFolderPath [NSString stringWithFormat:@"%@/HeadLogo",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]

#define dsDownloadFileFolderPath [NSString stringWithFormat:@"%@/DownloadFile",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]
#define dsDownloadFilePath [NSString stringWithFormat:@"%@/%@",dsDownloadFileFolderPath,@"DownloadFilePlist.plist"]

@implementation SystemPlist

+(SystemPlist*)shared{
    static dispatch_once_t once = 0;
    static SystemPlist *Obj;
    dispatch_once(&once, ^{ Obj = [[SystemPlist alloc] init]; });
    return Obj;
}

#pragma mark 创建信息 登录用户信息的plist 和头像logo文件夹HeadLogo
+(void)CreateSystemPlist{
    if (![[NSFileManager defaultManager] fileExistsAtPath:dsSystemPlistPath]) {
        //系统的plist文件
        NSDictionary *dictInfo=@{dbLogin: @"NO",dsCompanyNum:@"",dsUser:@"",dsPwd:@"",dsHeadLogoFileName:@"",dsTaken:@"",dsCompanyID:@"",dsUserID:@"",dsEmail:@"",dsPhoto:@"",dsRootDomain:@""};
        [dictInfo writeToFile:dsSystemPlistPath atomically:YES];
    }
    //创建下载文件文件夹
    if (![[NSFileManager defaultManager] fileExistsAtPath:dsDownloadFileFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dsDownloadFileFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        //下载文件的plist文件
        NSMutableArray *arrayInfo=[[NSMutableArray alloc] init];
        NSDictionary *dictInfo=@{@"fileFilePath":@"",@"fileExtension":@"",@"fileTitle":@""};
        [arrayInfo addObject:dictInfo];
        [arrayInfo writeToFile:dsDownloadFilePath atomically:YES];
    }

}

#pragma mark 初始化信息 登录用户信息的plist 清空头像logo文件夹HeadLogo文件
+(void)InitSystemPlist{
    //初始化systemplist
   NSDictionary *dictInfo=@{dbLogin: @"NO",dsCompanyNum:@"",dsUser:@"",dsPwd:@"",dsHeadLogoFileName:@"",dsTaken:@"",dsCompanyID:@"",dsUserID:@"",dsEmail:@"",dsPhoto:@"",dsRootDomain:@""};
    [dictInfo writeToFile:dsSystemPlistPath atomically:YES];
}

#pragma mark systemPlist文件是否存在
+(BOOL)ExistSystemPlist{
   return [[NSFileManager defaultManager] fileExistsAtPath:dsSystemPlistPath];
}


#pragma mark 返回downloadPlistPath的路径
+ (NSString*)returnDownloadFileFolderPath{
    return dsDownloadFileFolderPath;
}

#pragma mark 返回dsDownloadFilePath的路径
+ (NSString*)returnDownloadFilePath{
    return dsDownloadFilePath;
}

#pragma mark 返回systemPlist的NSMutableDictionary
-(NSMutableDictionary*)getSystemPlistDictionary{
    
    NSMutableDictionary *dictPlist;
    dictPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:dsSystemPlistPath];
    
    return dictPlist;
}

#pragma mark 设置值
-(void)setPlistValue:(NSString*)psValue sKey:(NSString*)psKey{
    
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    [dictPlist setObject:psValue forKey:psKey];
    //保存
    [dictPlist writeToFile:dsSystemPlistPath atomically:YES];

}
#pragma mark 获取值
-(NSString*)getPlistValue:(NSString*)psKey{
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    return  [dictPlist objectForKey:psKey];
}

#pragma mark 设置bLogin的属性
+(void)SetLogin:(BOOL)pbLogin{
    
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    NSString *sFlag=@"";
    if (pbLogin) {
        sFlag=@"YES";
    }else{
        sFlag=@"NO";
    }

    [dictPlist setObject:sFlag forKey:dbLogin];
    //保存
    [dictPlist writeToFile:dsSystemPlistPath atomically:YES];
    
}
+(BOOL)GetLogin{
    NSMutableDictionary *dictPlist=[[SystemPlist shared] getSystemPlistDictionary];
    
    BOOL sFlag;
    
    if ([[dictPlist objectForKey:dbLogin] isEqualToString:@"YES"]) {
        sFlag=YES;
    }else{
        sFlag=NO;
    }
    return sFlag;
}


//CompanyID
+(void)SetCompanyID:(NSString*)pCompanyID{
    [[SystemPlist shared] setPlistValue:pCompanyID sKey:dsCompanyID];
}
+(NSString*)GetCompanyID{
    return  [[SystemPlist shared] getPlistValue:dsCompanyID];
}

//UserID
+(void)SetUserID:(NSString*)pUserID{
    [[SystemPlist shared] setPlistValue:pUserID sKey:dsUserID];
}
+(NSString*)GetUserID{
    return  [[SystemPlist shared] getPlistValue:dsUserID];
}

//CompanyNum
+(void)SetCompanyNum:(NSString*)pCompanyNum{
    [[SystemPlist shared] setPlistValue:pCompanyNum sKey:dsCompanyNum];
}
+(NSString*)GetCompanyNum{
    return  [[SystemPlist shared] getPlistValue:dsCompanyNum];
}

//user
+(void)SetLoadUser:(NSString*)pLoadUser{
    [[SystemPlist shared] setPlistValue:pLoadUser sKey:dsUser];
}
+(NSString*)GetLoadUser{
    return  [[SystemPlist shared] getPlistValue:dsUser];
}

//pwd
+(void)SetLoadPwd:(NSString*)pLoadPwd{
    [[SystemPlist shared] setPlistValue:pLoadPwd sKey:dsPwd];
}
+(NSString*)GetLoadPwd{
   return  [[SystemPlist shared] getPlistValue:dsPwd];
}


//mail
+(void)SetMail:(NSString*)pMail{
    [[SystemPlist shared] setPlistValue:pMail sKey:dsEmail];
}
+(NSString*)GetMail{
    return  [[SystemPlist shared] getPlistValue:dsEmail];
}

//photo
+(void)SetPhoto:(NSString*)pPhoto{
    [[SystemPlist shared] setPlistValue:pPhoto sKey:dsPhoto];
}
+(NSString*)GetPhoto{
    return  [[SystemPlist shared] getPlistValue:dsPhoto];
}

//rootdomain
+(void)SetRootdomain:(NSString*)pRootdomain{
    [[SystemPlist shared] setPlistValue:pRootdomain sKey:dsRootDomain];
}
+(NSString*)GetRootdomain{
    return  [[SystemPlist shared] getPlistValue:dsRootDomain];
}


#pragma mark 保存头像到本地
+(void)SaveHeadLogoToLocalWithUrl:(NSString*)psHeadLogoUrl{
    
    if ([psHeadLogoUrl isEqualToString:@""]) return;
    
    //NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:psHeadLogoUrl]];
    //UIImage * imageFromURL = [UIImage imageWithData:data];
    
    //设置HeadLogo到systemplist
    //[[SystemPlist shared] setPlistValue:dsHeadLogoFileName sKey:dsHeadLogo];
}

+(void)SaveHeadLogoToLocalWithData:(NSData*)pData{
    if (pData.length==0) return;
    
    //创建文件并重命名
    //[[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@/%@",dsHeadLogoFolderPath,dsHeadLogoFileName] contents:pData attributes:nil];
    
    //设置HeadLogo到systemplist
    //[[SystemPlist shared] setPlistValue:dsHeadLogoFileName sKey:dsHeadLogo];
}

@end
