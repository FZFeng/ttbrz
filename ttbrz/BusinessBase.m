//
//  cBusinessBase.m
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//

#import "BusinessBase.h"

@implementation BusinessBase

NSString *KServerUrl_WWW=@"http://testwww.ttbrz.cn/";
NSString *KServerUrl_Saas=@"http://testsaas.ttbrz.cn/";
NSString *KServerUrl_App=@"http://testapp.ttbrz.cn/";
NSString *KStrUrl=@"http://testapp.ttbrz.cn";
NSString *KServerUrl_file=@"http://testfile.ttbrz.cn/";
NSString *KServerUrl_file2=@"http://testfile.ttbrz.cn";

//新建sqlite表
-(BOOL)createTable{
    return YES;
}

//插入数据
-(BOOL)insertData{
    return YES;
}

//修改数据
-(BOOL)updateData{
    return YES;
}

//删除数据
-(BOOL)deleteData{
    return YES;
}

@end
