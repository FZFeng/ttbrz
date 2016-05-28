//
//  ClassTask.h
//  ttbrz
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//  Info:任务业务类

#import "BusinessBase.h"

@interface ClassTask : BusinessBase

@property(nonatomic,strong)NSString *sPK_LookBoardTypeID;     //看板分类ID
@property(nonatomic,strong)NSString *sLookBoardTypeName;      //看板分类名称
@property(nonatomic,strong)NSString *sShowIndex;  //排序号
@property(nonatomic,strong)NSString *sFK_guidCreateUserID;  //看板创建人ID
@property(nonatomic,strong)NSString *sFK_guidCreateUserName;    //看板创建人姓名
@property(assign)NSInteger iFK_AuthorityType;//分类可见权限0-所有人可见(默认) 1-仅自己可见 2-其他人
@property(nonatomic,strong)NSArray  *arrayAuthorityManagementInfo;  //权限管理信息(包含子集):集合中的用户可以操作此分类


@property(nonatomic,strong)NSString *sDeptID;     //部门ID
@property(nonatomic,strong)NSString *sDeptName;   //部门名称
@property(nonatomic,strong)NSArray *arrayUsers;	 //该部门下的用户


@property(nonatomic,strong)NSString *sLookBoardID;
@property(nonatomic,strong)NSString *sLookBoardName;
@property(assign)BOOL bIsCompetence;
@property(nonatomic,strong)NSString *sState;
@property(nonatomic,strong)NSMutableArray *arrayTaskInfo;


@property(nonatomic,strong)NSArray *arrayLookBoardList;

@property(nonatomic,strong)NSString *sTaskID;     //任务ID
@property(nonatomic,strong)NSString *sTaskName;   //任务名称

@property(nonatomic,strong)NSString *sUserID;
@property(nonatomic,strong)NSString *sUserName;
@property(nonatomic,strong)NSString *sVchrPhoto;


@property(nonatomic,strong)NSString *sDtEnd;
@property(nonatomic,strong)NSString *sProgress;
@property(assign)BOOL bIsOntime;
@property(nonatomic,strong)NSString *sTaskTitle;
@property(nonatomic,strong)NSArray *arrayNoCompletedTaskList;


@property(nonatomic,strong)NSString *sExecuteUserName;
@property(assign)BOOL bIsExpired;


typedef void (^returnTaskDictionaryDataBlock) (BOOL bReturn,NSDictionary *returnDictionary);
typedef void (^returnTaskClassDataBlock) (BOOL bReturn,NSArray *returnArray);

//获取看板分类
+ (void)getNormalClassifyKanbanDataWithGuidCompanyID:(NSString*)guidCompanyID
                                             userID:(NSString*)userID
                                               Page:(NSInteger)Page
                                               Rows:(NSInteger)Rows
                                       fatherObject:(id)fatherObject
                                        returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取看板分类(NoHUD)
+ (void)getNormalClassifyKanbanDataNoHUDWithGuidCompanyID:(NSString*)guidCompanyID
                                              userID:(NSString*)userID
                                                Page:(NSInteger)Page
                                                Rows:(NSInteger)Rows
                                         returnBlock:(returnTaskClassDataBlock)returnBlock;


//新建看板分类
+ (void)NewKanbanClassificationWithName:(NSString*)sName
                              ShowIndex:(NSInteger)ShowIndex
                          AuthorityType:(NSString*)AuthorityType
                           AuthorityIds:(NSString*)AuthorityIds
                                 UserID:(NSString*)UserID
                              CompanyID:(NSString*)CompanyID
                           fatherObject:(id)fatherObject
                            returnBlock:(returnTaskClassDataBlock)returnBlock;

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
                             returnBlock:(returnTaskClassDataBlock)returnBlock;
//删除看板分类
+ (void)DeleteKanbanClassificationWithKanbanTypeId:(NSString*)sKanbanTypeId
                                    UserID:(NSString*)UserID
                                 CompanyID:(NSString*)CompanyID
                              fatherObject:(id)fatherObject
                               returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取部门及部门下的子部门用户(选择可见人员时调用)
+ (void)GetAllDeptTreeWithUserID:(NSString*)UserID
                       CompanyID:(NSString*)CompanyID
                    fatherObject:(id)fatherObject
                     returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取看板及看板下的任务信息
+ (void)GetLookBoardAndTaskDataWithCompanyID:(NSString*)companyID
                                      userID:(NSString*)userID
                          strLookBoardTypeID:(NSString*)strLookBoardTypeID
                                        Page:(NSInteger)Page
                                        Rows:(NSInteger)Rows
                                fatherObject:(id)fatherObject
                                 returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取看板及看板下的任务信息(获取某一看板下的任务)
+ (void)GetCertainLookBoardAndTaskDataWithCompanyID:(NSString*)companyID
                                             userID:(NSString*)userID
                                        LookBoardID:(NSString*)LookBoardID
                                               Page:(NSInteger)Page
                                               Rows:(NSInteger)Rows
                                        returnBlock:(returnTaskClassDataBlock)returnBlock;

//操作看板(新建看板, 编辑看板,归档看板,删除看板)
typedef NS_ENUM(NSInteger, ClassTaskOperateKanBanType){
    ClassTaskOperateKanBanTypeAdd,
    ClassTaskOperateKanBanTypeEdit,
    ClassTaskOperateKanBanTypeSave,
    ClassTaskOperateKanBanTypeDelete
};
+ (void)operateKanBanWithCompanyID:(NSString*)companyID
                            userID:(NSString*)userID
                strLookBoardTypeID:(NSString*)strLookBoardTypeID
                    strLookBoardID:(NSString*)strLookBoardID
                  strLookBoardName:(NSString*)strLookBoardName
                 OperateKanBanType:(ClassTaskOperateKanBanType)OperateKanBanType
                      fatherObject:(id)fatherObject
                       returnBlock:(returnTaskClassDataBlock)returnBlock;

//新建任务
+ (void)createTaskLookBoardWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                             strTaskName:(NSString*)strTaskName
                          strLookBoardID:(NSString*)strLookBoardID
                           strFinishDate:(NSString*)strFinishDate
                        strExecuteUserID:(NSString*)strExecuteUserID
                          strTaskContent:(NSString*)strTaskContent
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock;

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
                           returnBlock:(returnTaskClassDataBlock)returnBlock;
//归档任务
+ (void)archiveTaskWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                               strTaskID:(NSString*)strTaskID
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock;

//删除任务
+ (void)deleteTaskLookBoardWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                               TaskID:(NSString*)TaskID
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock;


//获取看板列表信息（选择看板时调用）
+ (void)getLookBoardList:(NSString*)UserID
               CompanyID:(NSString*)CompanyID
            fatherObject:(id)fatherObject
             returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取团队任务信息
+ (void)getDeptTaskPlanListWithCompanyID:(NSString*)companyID
                                  userID:(NSString*)userID
                                    pageindex:(NSInteger)pageindex
                                    pagesize:(NSInteger)pagesize
                                  deptid:(NSString*)deptid
                            fatherObject:(id)fatherObject
                             returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取团队任务信息(noHud)
+ (void)getDeptTaskPlanListNoHUDWithCompanyID:(NSString*)companyID
                                       userID:(NSString*)userID
                                    pageindex:(NSInteger)pageindex
                                     pagesize:(NSInteger)pagesize
                                       deptid:(NSString*)deptid
                                  returnBlock:(returnTaskClassDataBlock)returnBlock;

//获取我安排的任务(进行中、待安排、已完成)
+ (void)getSelfPlanTaskAllCompanyID:(NSString*)companyID
                             userID:(NSString*)userID
                       fatherObject:(id)fatherObject
                        returnBlock:(returnTaskDictionaryDataBlock)returnBlock;

//获取我安排的任务(加载更多时调用)
//我安排的任务类型(进行中, 待安排,已完成)
typedef NS_ENUM(NSInteger, ClassTaskSelfPlanType){
    ClassTaskSelfPlanTypeIng=2,
    ClassTaskSelfPlanTypeNO,
    ClassTaskSelfPlanTypeOk
};
+ (void)getSelfPlanTaskNoHUDCompanyID:(NSString*)companyID
                               userID:(NSString*)userID
                                 Page:(NSInteger)Page
                                 Rows:(NSInteger)Rows
                     TaskSelfPlanType:(ClassTaskSelfPlanType)TaskSelfPlanType
                          returnBlock:(returnTaskClassDataBlock)returnBlock;

@end
