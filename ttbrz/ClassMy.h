//
//  ClassMy.h
//  ttbrz
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:我的业务类

#import "BusinessBase.h"

@interface ClassMy : BusinessBase

typedef void (^returnMyClassDataBlock) (BOOL bReturn,NSArray *returnArray);

//保存个人信息
+ (void)saveMyInfoWithCompanyID:(NSString*)companyID
                         userID:(NSString*)userID
                            pwd:(NSString*)pwd
                          photo:(NSString*)photo
                          email:(NSString*)email
                   fatherObject:(id)fatherObject
                    returnBlock:(returnMyClassDataBlock)returnBlock;

//保存意见反馈信息
+ (void)saveFeedbackInfoWithEmail:(NSString*)email
                          content:(NSString*)content
                         userName:(NSString*)userName
                     fatherObject:(id)fatherObject
                      returnBlock:(returnMyClassDataBlock)returnBlock;
@end
