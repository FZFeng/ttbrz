//
//  ClassIntegral.h
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:积分

#import "BusinessBase.h"

@interface ClassIntegral : BusinessBase


@property(nonatomic)BOOL isLogExist; //是否填报日志
@property(nonatomic,strong)NSString *sLogDate;   //日志日期
@property(nonatomic,strong)NSString *sConfirmUser;    //考评人姓名
@property(nonatomic,strong)NSString *sLogScore;       //日志积分




@property(nonatomic,strong)NSString *sCTop;
@property(nonatomic,strong)NSString *sUserName;
@property(nonatomic,strong)NSString *sDeptName;
@property(nonatomic,strong)NSString *smaxScore;



typedef void (^returnIntegralClassDataBlock) (BOOL bReturn,NSArray *returnArray);

//获取我的积分信息
+ (void)getMyScoreDataWithCompanyID:(NSString*)companyID
                             userID:(NSString*)userID
                               Year:(NSInteger)Year
                              Month:(NSInteger)Month
                       fatherObject:(id)fatherObject
                        returnBlock:(returnIntegralClassDataBlock)returnBlock;

//获取团队积分列表
+ (void)getGroupScoreDataWithDeptID:(NSString*)DeptID
                          PageIndex:(NSInteger)PageIndex
                           PageSize:(NSInteger)PageSize
                              Begin:(NSString*)Begin
                          CompanyID:(NSString*)companyID
                       fatherObject:(id)fatherObject
                        returnBlock:(returnIntegralClassDataBlock)returnBlock;

//获取团队积分列表(NoHUD)
+ (void)getGroupScoreDataNoHUDWithDeptID:(NSString*)DeptID
                          PageIndex:(NSInteger)PageIndex
                           PageSize:(NSInteger)PageSize
                              Begin:(NSString*)Begin
                          CompanyID:(NSString*)companyID
                        returnBlock:(returnIntegralClassDataBlock)returnBlock;

@end
