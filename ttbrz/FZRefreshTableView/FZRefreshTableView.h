//
//  FZRefreshTableView.h
//  PullingRefresh
//
//  Created by dengyufeng on 15/8/11.
//  Copyright (c) 2015年 rang. All rights reserved.
//  Info:上,拉刷新tableview

#import <UIKit/UIKit.h>

typedef enum {
    FinishedLoadingNoDataUpdate = 0,//暂无数据可更新
    FinishedLoadingMessageHasUpdateNum,//成功更新n条数据
    FinishedLoadingMessageError//获取数据错误
} FinishedLoadingMessageType;

@protocol FZRefreshTableViewDelegate;

@interface FZRefreshTableView : UITableView<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    
    // 加载状态
    BOOL bLoading;
    
    //是否第一次加载数据
    BOOL bInitData;
    
    //表尾刷新状态
    UILabel *lblFooterRefreshState;
    //下拉刷新状态
    UILabel *lblRefreshState;
    
    UIView *vRefreshState;
   
    //下拉加载等待
    UIActivityIndicatorView *downRefreshactivityIndicator;
    
    //当前数据高度
    int iCurScrollSizeHeight;

}
@property (assign,nonatomic) id <FZRefreshTableViewDelegate> pullingDelegate;
@property (assign) BOOL bNotShowMessageInUpRefreshing;//标记是否显示上拉时数据更新结果


//初始化
- (id)initWithFrame:(CGRect)frame pullingDelegate:(id<FZRefreshTableViewDelegate>)aPullingDelegate UITableViewStyle:(UITableViewStyle)pUITableViewStyle;

//首次加载时刷新数据
-(void)InitRefreshData;

//刷新数据
-(void)RefreshData;

//是否处于数据加载中
-(BOOL)isLoadingData;

//用于外部scroll的Didscroll事件
- (void)tableViewDidScroll:(UIScrollView *)scrollView;

//用于外部scroll的DidEndDragging事件
- (void)tableViewDidEndDragging:(UIScrollView *)scrollView;

@end

//回调
@protocol FZRefreshTableViewDelegate <NSObject>

/**
 *  定义一个返回数据的block
 *
 *  @param FinishedLoadingMessageType     错误信息 的枚举
 *  @param iHasUpdateDataNum 已经更新的数据数量
 */
typedef void (^refreshingReBlock) (FinishedLoadingMessageType finishedLoadingMessageType,NSInteger iHasUpdateDataNum,NSString *sCustomErrMsg);

@required
//下拉刷新
- (void)pullingDownRefreshing:(refreshingReBlock) pBlock;

//上拉刷新
- (void)pullingUpLoading:(refreshingReBlock) pBlock;

@end

