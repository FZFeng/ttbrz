//
//  cBusinessBase.h
//  BaseModel
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 Fabius's Studio. All rights reserved.
//  Info:业务操作的基类 定义公共的属性,方法 所以业务类都继承此类

#import <Foundation/Foundation.h>
#import "FZNetworkHelper.h"
#import "SystemPlist.h"

extern NSString *KServerUrl_WWW;
extern NSString *KServerUrl_Saas;
extern NSString *KServerUrl_App;
extern NSString *KStrUrl;
extern NSString *KServerUrl_file;
extern NSString *KServerUrl_file2;

@interface BusinessBase : NSObject

//新建sqlite表
-(BOOL)createTable;

//插入数据
-(BOOL)insertData;

//修改数据
-(BOOL)updateData;

//删除数据
-(BOOL)deleteData;

//结果block
typedef void (^blockFunctionReturn)(BOOL bReturnBlock);

//返回日志状态 日志状态：2为填报中，3为待考评，4为完成
typedef NS_ENUM(NSInteger, LogStateType){
   LogStateTypeDoing=2,
    LogStateTypeWaitting,
    LogStateTypeFinished
};

//日志评选类型 选择类型：0:全选 1:先全选,部分取消 2:未全选,部分勾选 -1:单篇日报考评
typedef NS_ENUM(NSInteger, LogEvaluationType){
    LogEvaluationTypeNone=-2,//什么都没选
    LogEvaluationTypeSingle=-1,
    LogEvaluationTypeAll,
    LogEvaluationTypeAllButSomeCancel,
    LogEvaluationTypeUnAllButSomeCheck,
    
};

@end
