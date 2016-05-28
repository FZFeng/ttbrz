//
//  ClassLog.h
//  ttbrz
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:日志功能模块业务类

#import "BusinessBase.h"

@interface ClassLog : BusinessBase

//日志中待办任务属性
@property(nonatomic,strong)NSString *sPlanID;
@property(nonatomic,strong)NSString *sPlanItemId;
@property(nonatomic,strong)NSString *sPlanName;
@property(nonatomic,strong)NSString *sState;
@property(nonatomic,strong)NSString *sProgress;
@property(nonatomic,strong)NSString *sEndDate;
@property(nonatomic)BOOL isOntime;


//日志属性
@property(nonatomic)BOOL isLogExist; //是否填报日志
@property(nonatomic,strong)NSString *sLogID;     //日志ID
@property(nonatomic,strong)NSString *sLogDate;   //日志日期
@property(nonatomic,strong)NSString *sLogState;  //日志状态：2为填报中，3为待考评，4为完成
@property(nonatomic,strong)NSString *sConfirmUserID;  //考评人ID
@property(nonatomic,strong)NSString *sConfirmUser;    //考评人姓名
@property(nonatomic,strong)NSString *sLogScore;       //日志积分
@property(nonatomic,strong)NSString *sLogContent;     //日志内容
@property(nonatomic,strong)NSArray *arrayAccessory;  //上传文件信息（包含子集
@property(nonatomic,strong)NSString *sEvaluationItemInfo; //考评项信息

//待办任务
@property(nonatomic,strong)NSString *sTaskTitle;
@property(nonatomic,strong)NSString *sLookBoardID;
@property(nonatomic,strong)NSString *sLookBoardName;
@property(nonatomic,strong)NSString *sTaskContent;
@property(nonatomic,strong)NSString *sUserInfo;

//考评人信息
@property(nonatomic,strong)NSString *sCompanyUserID;
@property(nonatomic,strong)NSString *sCompangUserName;

//部门信息
@property(nonatomic,strong)NSString *sDeptID;     //部门ID
@property(nonatomic,strong)NSString *sDeptName;   //部门名称
@property(nonatomic,strong)NSString *sDepartmentType;      //部门类型 0:公司 1:部门

//团队日志
@property(nonatomic,strong)NSString *sCreateUserID;	//日志创建人ID
@property(nonatomic,strong)NSString *sCreateUserName;	//日志创建人姓名
@property(nonatomic,strong)NSString *sCreateUserDept;	//日志创建人所在部门名称
@property(nonatomic,strong)NSString *sCreateUserPhoto;	//日志创建人头像（Base64编码）

//同事日志
@property(nonatomic,strong)NSString *sUsersNum;	//该部门下的用户数量
@property(nonatomic,strong)NSArray *arrayUsers;	//该部门下的用户
//@property(nonatomic,strong)NSString *sUserID;	//该部门下的用户ID
//@property(nonatomic,strong)NSString *sUserName;	//该部门下的用户姓名
//@property(nonatomic,strong)NSString *sUserFromDepartmentName;	//用户所在部门名称
//@property(nonatomic,strong)NSString *sUserHeadPhoto;	//用户头像

//日志考评
@property(assign,nonatomic)BOOL bSelected;
@property(nonatomic,strong)NSArray *arrayCommentTemplate; //评语模板
@property(nonatomic,strong)NSArray *arrayEvaluationItem; //考评项目信息
@property(nonatomic,strong)NSString *sDayNum;//一天的标准积分;



//返回结果集的block
typedef void (^returnLogDictionaryDataBlock) (BOOL bReturn,NSDictionary *returnDictionary);
typedef void (^returnLogDataBlock) (BOOL bReturn,NSArray *returnArray);
typedef void (^returnLogDataWithErrMsgBlock) (BOOL bReturn,NSArray *returnArray,NSString *errMsg);

//进入系统后获取的初始化数据
+(void)initInfoWithID:(NSString*)sID
            companyID:(NSString*)companyID
         fatherObject:(id)fatherObject
          returnBlock:(returnLogDictionaryDataBlock)returnBlock;

//获取待办任务
+(void)getPlanTaskWithID:(NSString*)sID
               companyID:(NSString*)companyID
               pageIndex:(NSInteger)pageIndex
                    rows:(NSInteger)rows
             returnBlock:(returnLogDataBlock)returnBlock;

//更新待办任务进度
+ (void)updateTaskProgressWithItemID:(NSString*)itemID
                           iProgress:(NSInteger)iProgress
                        fatherObject:(id)fatherObject
                         returnBlock:(returnLogDataBlock)returnBlock;

//查看某一待办任务的详细信息
+ (void)getDetailPlanTaskWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                      strTaskID:(NSString*)strTaskID
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDataBlock)returnBlock;

//获取日志信息
+(void)getLogDataWithBeginTime:(NSString*)beginTime
                        dayNum:(NSInteger)dayNum
                         iType:(NSInteger)iType
                        userID:(NSString*)userID
                     companyID:(NSString*)companyID
             returnBlock:(returnLogDataWithErrMsgBlock)returnBlock;

//获取指定日期日志信息
+(void)getLogDataWithDate:(NSString*)sDate
                   dayNum:(NSInteger)dayNum
                    iType:(NSInteger)iType
                   userID:(NSString*)userID
                companyID:(NSString*)companyID
             fatherObject:(id)fatherObject
              returnBlock:(returnLogDataBlock)returnBlock;

//获取考评人信息(新建日志时需要)
+ (void)getDefaultConfirmUserWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDataBlock)returnBlock;


//新建日志
+ (void)createLogUserWithID:(NSString*)createuserguid
                  companyID:(NSString*)companyID
                    logdate:(NSString*)logdate
                 logcontent:(NSString*)logcontent
            confirmuserguid:(NSString*)confirmuserguid
               fatherObject:(id)fatherObject
                returnBlock:(returnLogDataBlock)returnBlock;

//编辑日志
+ (void)editLogUserWithLogID:(NSString*)logID
             confirmuserguid:(NSString*)confirmuserguid
                 logcontent:(NSString*)logcontent
               fatherObject:(id)fatherObject
                returnBlock:(returnLogDataBlock)returnBlock;

//删除日志中的文件
+ (void)deleteLogFileWithFilePath:(NSString*)FilePath
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock;

//删除数据库中的文件路径（成功删除文件后调用）
+ (void)deleteLogFilePathWithFileID:(NSString*)FileID
                      returnBlock:(returnLogDataWithErrMsgBlock)returnBlock;

//保存上传文件路径服务（文件上传成功后调用）
+ (void)saveUpLoadFilePathWithLogDate:(NSString*)logDate
                             FileName:(NSString*)FileName
                             FilePath:(NSString*)FilePath
                               UserID:(NSString*)UserID
                            CompanyID:(NSString*)CompanyID
                         fatherObject:(id)fatherObject
                          returnBlock:(returnLogDataBlock)returnBlock;

//图片在线预览
+ (void)imagePreviewWithStrUrl:(NSString*)strUrl
                  fatherObject:(id)fatherObject
                   returnBlock:(returnLogDictionaryDataBlock)returnBlock;

//提交日志
+ (void)commitLogWithTaskID:(NSString*)taskID
                  companyID:(NSString*)companyID
                   userName:(NSString*)userName
               fatherObject:(id)fatherObject
                returnBlock:(returnLogDataBlock)returnBlock;

//后台下载文件
+ (void)downFileWithFilePath:(NSString*)filePath
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock;

//获取部门信息
+ (void)getDepartmentDataWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                        strType:(NSString*)strType
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDataBlock)returnBlock;

//获取部门日志数据
+ (void)getTeamLogDataWithID:(NSString*)sID
                   companyID:(NSString*)companyID
                   pageIndex:(NSInteger)pageIndex
                        rows:(NSInteger)rows
                       sDate:(NSString*)sDate
                     sDeptID:(NSString*)sDeptID
                fatherObject:(id)fatherObject
                 returnBlock:(returnLogDataBlock)returnBlock;

//获取更多部门日志数据 NoHUD
+ (void)getTeamLogMoreDataWithID:(NSString*)sID
                   companyID:(NSString*)companyID
                   pageIndex:(NSInteger)pageIndex
                        rows:(NSInteger)rows
                       sDate:(NSString*)sDate
                     sDeptID:(NSString*)sDeptID
                 returnBlock:(returnLogDataBlock)returnBlock;

//获取部门名称及部门下的用户信息
+ (void)getDepartmentAndUserDataWithID:(NSString*)sID
                             companyID:(NSString*)companyID
                          fatherObject:(id)fatherObject
                           returnBlock:(returnLogDataBlock)returnBlock;

//获取考评日志列表(所有日期下的日志/指定日期) 当指定日期的参数传为nil/@"" 时。为所有日期下的日志
+ (void)getNeedAssessLogDataWithID:(NSString*)sID
                         companyID:(NSString*)companyID
                            strDate:(NSString*)strDate
                         pageIndex:(NSInteger)pageIndex
                              rows:(NSInteger)rows
                      fatherObject:(id)fatherObject
                       returnBlock:(returnLogDataBlock)returnBlock;

//获取考评日志评分项
+ (void)getEvaluationDataWithID:(NSString*)sID
                      companyID:(NSString*)companyID
                   fatherObject:(id)fatherObject
                    returnBlock:(returnLogDictionaryDataBlock)returnBlock;

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
                            returnBlock:(returnLogDictionaryDataBlock)returnBlock;

@end
