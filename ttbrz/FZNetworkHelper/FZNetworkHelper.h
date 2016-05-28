//
//  NetworkHelper.m
//  iCanteen
//
//  Created by DYF on 14-6-5.
//  Copyright (c) 2014年 Himasoft. All rights reserved.
//  Info:网络通讯的业务类 原生的
//  Ps:使用前先设定好 serverURL值

//原生类 get/post
//获取数据（通常是JSON、XML）DataTaskWithCondition
//文件上传
//文件下载
//判断服务器的可连通性
//判断当前网络类型 2G/3G/4G/Wifi

#import <Foundation/Foundation.h>
#import "PublicFunc.h"
#import "SystemPlist.h"

@interface FZNetworkHelper : NSObject<NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>

//上传文件到服务器(多文件,后台上传) 全局对象
@property(nonatomic,strong)NSURLSession *sessionUpLoadMultiFile;
@property (nonatomic, strong) NSURLSessionUploadTask *taskUpLoadMultiFile;
@property(nonatomic) BOOL bTaskSuccess;
@property(nonatomic) BOOL bTaskWaitting;
@property(nonatomic,strong) NSURLSessionDownloadTask *sessionDownLoad;

#pragma mark enum
/**
 请求方法类型 get,post
 */
typedef enum {
    requestMethodGet,
    requestMethodPost
}requestMethodType;

//上传文件类型 updateFileTypeText文件 updateFileTypeImage 图片
typedef enum{
    updateFileTypeText=0,
    updateFileTypeImage
} updateFileType;


#pragma mark block
/**
 *  定义一个返回数据的block
 *
 *  @param returnData 返回的数据集 一般为json数据
 *  @param bReturn    返回结果 yes/no
 */
typedef void (^returnBlock) (NSDictionary *returnData,BOOL bReturn);

/**
 *  定义一个返回数据的block
 *
 *  @param returnData 返回的数据集 一般为json数据
 *  @param sError     返回结果
 */
typedef void (^returnBlockNoHUD) (NSDictionary *returnData,NSString *sError);

/**
 *  使用soap返回数据的block
 *
 *  @param sReturnSoap 返回数据集
 *  @param bReturn     返回结果 yes/no
 */
typedef void (^returnBlock_Soap)(NSString *sReturnSoap,BOOL bReturn);


#pragma mark DataTask
/**
 *  访问网络数据(通过api名称和参数集)
 *
 *  @param pApiName           api接口名称 如productlist
 *  @param parryPara          接口使用的参数集 categoryid=1&currentpage=1
 *  @param pRequestMethodType 请求方法类型
 *  @param pFatherObject      调用此接口的对象 使用 HUD 时需要
 *  @param bShowSuccessMsg    是否显示成功提示
 *  @param sWaitingMsg        自定义等待提示内容 当值为nil 时 用默认值
 *  @param pBlock             调用此接口时 要进行的业务逻辑块
 */
+ (void)dataTaskWithApiName:(NSString *)apiName
                  arryPara:(NSArray*)arryPara
         requestMethodType:(requestMethodType)requestMethodType
              fatherObject:(id)fatherObject
           bShowSuccessMsg:(BOOL)bShowSuccessMsg
               sWaitingMsg:(NSString*)sWaitingMsg
                     block:(returnBlock)block;

/**
 *  访问网络数据(通过url)
 *
 *  @param pUrl               api接url
 *  @param parryPara          接口使用的参数集 如 categoryid=1&currentpage=1 
 *  @param pRequestMethodType 请求方法类型
 *  @param pFatherObject      调用此接口的对象 使用 HUD 时需要
 *  @param bShowSuccessMsg    是否显示成功提示
 *  @param pBlock             调用此接口时 要进行的业务逻辑块
 */
+ (void)dataTaskWithUrl:(NSString *)url
              arryPara:(NSArray*)arryPara
     requestMethodType:(requestMethodType)requestMethodType
          fatherObject:(id)fatherObject
       bShowSuccessMsg:(BOOL)bShowSuccessMsg
                 block:(returnBlock) block;

//访问网络数据 没有HUD
+ (void)dataTaskWithApiNameNoHUD:(NSString *)apiName
                       arryPara:(NSArray*)arryPara
              requestMethodType:(requestMethodType)requestMethodType
                          block:(returnBlockNoHUD) block;

//访问网络数据 没有HUD
+ (void)dataTaskWithUrlNoHUD:(NSString *)url
                   arryPara:(NSArray*)arryPara
          requestMethodType:(requestMethodType)requestMethodType
                      block:(returnBlockNoHUD)block;


/**
 *  访问网络数据 soap协议xml
 *
 *  @param pApiName           api接口名称
 *  @param psoapMsg
    接口使用的参数集 例
                 <?xml version="1.0" encoding="utf-8"?>
                 <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                     <soap:Body>
                         <CheckUserPWD xmlns="http://tempuri.org/">
                         <psUser>dbo</psUser>
                         <psPWD></psPWD>
                         </CheckUserPWD>
                     </soap:Body>
                 </soap:Envelope>
 *  @param pFatherObject      调用此接口的对象 使用 HUD 时需要
 *  @param pBlock             调用此接口时 要进行的业务逻辑块
 */
+ (void)dataTaskWithApiName_Soap:(NSString *)apiName
                        soapMsg:(NSString*)soapMsg
                   fatherObject:(id)fatherObject
                          block:(returnBlock_Soap)block;

//没有 HUD
+ (void)dataTaskWithApiNameNoHUD_Soap:(NSString *)apiName
                             soapMsg:(NSString*)soapMsg
                               block:(returnBlock_Soap) block;


#pragma mark UpLoadTask
/**
 *  上传文件到服务器
 *
 *  @param pApiName           api接口名称 如 productlist
 *  @param parryPara          接口使用的参数集 如 categoryid=1&currentpage=1
 *  @param pfromDict          要上传的文件集(如图片 key:headlogo.png value:image data)
 *  @param pFatherObject      调用此接口的对象 使用 HUD 时需要
 *  @param updateFileType     上传的类型 图片/文件
 *  @param sWaitingMsg        自定义等待提示内容 当值为nil 时 用默认值
 *  @param pBlock             调用此接口时 要进行的业务逻辑块
 */
+ (void)upLoadTaskWithApiName:(NSString *)apiName
                    arryPara:(NSArray*)arryPara
                    fromDict:(NSDictionary*)fromDict
                fatherObject:(id)fatherObject
              updateFileType:(updateFileType)updateFileType
                 sWaitingMsg:(NSString*)sWaitingMsg
                       block:(returnBlock)block;

//没有HUD的上传
+ (void)upLoadTaskWithApiNameNoHUD:(NSString *)apiName
                         arryPara:(NSArray*)arryPara
                         fromDict:(NSDictionary*)fromDict
                   updateFileType:(updateFileType)updateFileType
                            block:(returnBlockNoHUD) block;


/**
 *  上传文件到服务器(多文件,后台上传)
 *
 *  @param pCondition    以http形式访问的url字符串 如:productlist?categoryid=1&currentpage=1 productlist为webapi接口名
 *  @param pArryFilePath 上传文件地址集
 *  @param pFatherObject 调用此接口的对象 使用 HUD 时需要
 */
+ (void)upLoadTaskWithCondition:(NSString *)condition
                  arryFilePath:(NSArray *)arryFilePath
                  fatherObject:(id)fatherObject;


#pragma mark DownTask
/**
 *  后台下载
 *
 *  @param url               url 地址
 *  @param arryPara          url 中的参数
 *  @param savePath          保存到本地的路
 *  @param block             返回 block
 */
+ (void)downTaskInBackgroundWithUrl:(NSString *)url
                           arryPara:(NSArray*)arryPara
                           savePath:(NSString*)savePath
                              block:(returnBlockNoHUD)block;


+ (void)downTaskWithCondition:(NSString *)condition
                arryFilePath:(NSArray *)arryFilePath
                fatherObject:(id)fatherObject;


#pragma mark checkNetwork
/**
 *  判断网络是否连通
 *
 *  @param pServerUrl       目标服务器url
 *  @param piTimeOutSeconds 超时时间
 *  @param pFatherObject    调用此接口的对象 使用 HUD 时需要
 *  @param pShowErrorMsg    返回错误
 *
 *  @return yes/no
 */
+ (BOOL)checkNetWork:(NSString *)serverUrl
    iTimeOutSeconds:(int)iTimeOutSeconds
       fatherObject:(id)fatherObject
       showErrorMsg:(BOOL)showErrorMsg;

//判断当前网络的类型 2G/3G/4G/wifi

+ (NSString*)getServerUrl;

@end
