//
//  ClassSearchAndMessage.h
//  ttbrz
//
//  Created by apple on 16/3/28.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:搜索和消息类

#import "BusinessBase.h"

@interface ClassSearchAndMessage : BusinessBase

@property(nonatomic,strong)NSArray *arraySearchData_LogInfo;
@property(assign)NSInteger iSearchData_LogInfoCount;//总数量
@property(nonatomic,strong)NSArray *arraySearchData_TaskInfo;
@property(assign)NSInteger iSearchData_TaskInfoCount;//总数量
@property(nonatomic,strong)NSArray *arraySearchData_FileInfo;
@property(assign)NSInteger iSearchData_FileInfoCount;//总数量


@property(nonatomic,strong)NSArray *arrayMessageInfo;
@property(assign)NSInteger iMessageCount;//消息总数量

typedef void (^returnSearchOrMessageDataBlock) (BOOL bReturn,NSArray *returnArray);

typedef void (^returnVersionBlock) (BOOL bReturn,NSString *sVersion);

+(void)searchDataWithKey:(NSString*)sKey
                   iType:(NSInteger)iType
                    page:(NSInteger)page
                    rows:(NSInteger)rows
               companyID:(NSString*)companyID
                  userID:(NSString*)userID
            fatherObject:(id)fatherObject
             returnBlock:(returnSearchOrMessageDataBlock)returnBlock;

+(void)searchDataNoHUDWithKey:(NSString*)sKey
                   iType:(NSInteger)iType
                    page:(NSInteger)page
                    rows:(NSInteger)rows
               companyID:(NSString*)companyID
                  userID:(NSString*)userID
             returnBlock:(returnSearchOrMessageDataBlock)returnBlock;

//获取消息信息
+ (void)getMessageInfoWithID:(NSString*)sID
                     strType:(NSString*)strType
                        page:(NSInteger)page
                        rows:(NSInteger)rows
                 returnBlock:(returnSearchOrMessageDataBlock)returnBlock;

//获取消息信息(HUD)
+ (void)getMessageInfoHUDWithID:(NSString*)sID
                        strType:(NSString*)strType
                           page:(NSInteger)page
                           rows:(NSInteger)rows
                   fatherObject:(id)fatherObject
                    returnBlock:(returnSearchOrMessageDataBlock)returnBlock;

//获取待审阅日报篇数
+ (void)GetConfirmLogNumWithID:(NSString*)sID
                   returnBlock:(returnSearchOrMessageDataBlock)returnBlock;

//知道了确定消息
+ (void)updateMessageStateWithMessageID:(NSString*)messageID
                           fatherObject:(id)fatherObject
                            returnBlock:(returnSearchOrMessageDataBlock)returnBlock;
//检查版本
+ (void)checkVersion:(returnVersionBlock)returnBlock;

@end
