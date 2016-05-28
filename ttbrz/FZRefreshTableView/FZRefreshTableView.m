#import "FZRefreshTableView.h"

#define txtUpMoreData      @"上拉显示更多数据"
#define txtDownMoreData    @"下拉显示更多数据"
#define txtPrepareData     @"放开加载数据"
#define txtLoadingData     @"数据加载中..."
//#define txtInit            @"初始化中..."
#define txtNoDataForUpdate @"暂无数据可更新"
#define txtGetDataError    @"获取数据出错"
#define txtReloadMoreData  @"点击重新加载数据"

#define fexcursion  0.03
#define fAnimationDuration .18f
#define iUpdateGap 35
#define fDelayTime 1.0
#define fAlpha 0.8

#define KDefaultColor [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:236.0f/255.0f alpha:1.0]

@implementation FZRefreshTableView

#pragma mark 初始化
- (id)initWithFrame:(CGRect)frame pullingDelegate:(id<FZRefreshTableViewDelegate>)aPullingDelegate UITableViewStyle:(UITableViewStyle)pUITableViewStyle{
    self = [self initWithFrame:frame style:pUITableViewStyle];

    if (self) {
        self.pullingDelegate = aPullingDelegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        
        //增加背景View 做为下拉刷新时显示的状态
        vRefreshState=[[UIView alloc] initWithFrame:CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height)];
        vRefreshState.backgroundColor=[UIColor groupTableViewBackgroundColor];
        
        lblRefreshState=[[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-40, frame.size.width, 40)];
        lblRefreshState.text=txtDownMoreData;
        lblRefreshState.textAlignment=NSTextAlignmentCenter;
        lblRefreshState.backgroundColor=[UIColor clearColor];
        lblRefreshState.textColor=KDefaultColor;
        lblRefreshState.font=[UIFont systemFontOfSize:14];
        vRefreshState.alpha=fAlpha;
        [vRefreshState addSubview:lblRefreshState];
        
        //加载等待
        downRefreshactivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(75.0f,frame.size.height-30, 20.0f, 20.0f)];
        [downRefreshactivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        downRefreshactivityIndicator.hidden=YES;
        [vRefreshState addSubview:downRefreshactivityIndicator];
        [self addSubview:vRefreshState];
        //tableview 尾部
        [self createTableFooter];
        //改变刷新显示状态
        //[lblFooterRefreshState setText:txtInit];
        [lblFooterRefreshState setText:@""];
        self.backgroundColor=[UIColor whiteColor];
        
    }
    return self;
}

// 创建表格底部
- (void) createTableFooter
{
    self.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.bounds.size.width, 40.0f)];
    tableFooterView.backgroundColor=[UIColor clearColor];
    lblFooterRefreshState = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 120,40.0f)];
    lblFooterRefreshState.textColor=KDefaultColor;
    lblFooterRefreshState.textAlignment=NSTextAlignmentCenter;
    [lblFooterRefreshState setCenter:tableFooterView.center];
    [lblFooterRefreshState setFont:[UIFont systemFontOfSize:14]];
    [lblFooterRefreshState setText:txtUpMoreData];
    [tableFooterView addSubview:lblFooterRefreshState];
   
    //添加单击事件
    UITapGestureRecognizer *singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ReloadMoreDataClick)];
    [singletap setNumberOfTapsRequired:1];
    [tableFooterView addGestureRecognizer:singletap];
    self.tableFooterView = tableFooterView;
}

#pragma mark 首次获取数据失败后点击重新加载数据
-(void)ReloadMoreDataClick{
    if (bInitData && !bLoading) {
        self.scrollEnabled=YES;
        //[lblFooterRefreshState setText:txtInit];
        [lblFooterRefreshState setText:@""];
        [self RefreshData];
    }
}

#pragma mark 首次加载时刷新数据
-(void)InitRefreshData{
    self.backgroundColor=[UIColor whiteColor];
    //afterdelay实现动画效果
    bInitData=YES;
    [self performSelector:@selector(RefreshData) withObject:nil afterDelay:0.5];
}

#pragma mark 刷新数据
-(void)RefreshData{
    //动画处理一个下拉过程
    if (bInitData) {
        [UIView animateWithDuration:fAnimationDuration animations:^{
            self.contentInset=UIEdgeInsetsMake(iUpdateGap, 0, 0, 0);
        } completion:^(BOOL finished) {
            //下拉刷新
            [self downLoadDataBegin];
        }];
    }else{
        if (!bLoading) {
            [UIView animateWithDuration:fAnimationDuration animations:^{
                [self setContentOffset:CGPointMake(0, -iUpdateGap)];
            } completion:^(BOOL finished) {
                //下拉刷新
                [self downLoadDataBegin];
            }];
        }
    }
}

#pragma mark 是否处于加载状态
-(BOOL)isLoadingData{
    return bLoading;
}

#pragma mark 上,下拉过程
// 用于外部scroll的Didscroll事件
- (void)tableViewDidScroll:(UIScrollView *)scrollView{
    [self scrollViewDidScroll:scrollView];
}

//用于外部scroll的DidEndDragging事件
- (void)tableViewDidEndDragging:(UIScrollView *)scrollView{
    [self scrollViewDidEndDragging:scrollView willDecelerate:YES];
}

//正在拉的状态
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (bInitData)return;
    
    if (bLoading)return;
    
    //上拉刷新***********************
    float height = scrollView.contentSize.height > self.frame.size.height ? self.frame.size.height : scrollView.contentSize.height;
    
    
    //还没拉到指定更新新数据位置的状态
    if( scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        [lblFooterRefreshState setText:txtUpMoreData];
    }
    
    //拉到指定更新新数据位置的状态
    if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > fexcursion) {
        [lblFooterRefreshState setText:txtPrepareData];
    }
    
    //下拉刷新************************
    if (scrollView.contentOffset.y <0.0) {
        // 调用下拉刷新方法
        lblRefreshState.text=txtDownMoreData;
    }
    
    if (scrollView.contentOffset.y <-iUpdateGap) {
        // 调用下拉刷新方法
        lblRefreshState.text=txtPrepareData;
    }
}


//拉完后的状态
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (bLoading)return;
    
    float height = scrollView.contentSize.height > self.frame.size.height ? self.frame.size.height : scrollView.contentSize.height;
    
    //上拉刷新************************
    if (((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > fexcursion)) {
        [self UpLoadDataBegin];
        
        //计算上拉无数据或错误时提示label的位置
        if (scrollView.contentSize.height > self.frame.size.height) {
            if (scrollView.contentSize.height - self.frame.size.height==20) {
                iCurScrollSizeHeight=scrollView.contentSize.height-20;
            }else{
                iCurScrollSizeHeight=scrollView.contentSize.height-iUpdateGap;
            }
        }else{
            iCurScrollSizeHeight=self.frame.size.height;
        }
    }
    
    //下拉刷新************************
    if (scrollView.contentOffset.y <-iUpdateGap) {
        [self downLoadDataBegin];
    }
}

// 开始下拉加载数据
- (void) downLoadDataBegin
{
    if (bLoading == NO)
    {
        bLoading = YES;
        lblRefreshState.text=txtLoadingData;
        
        //加载等待
        downRefreshactivityIndicator.hidden=NO;
        [downRefreshactivityIndicator startAnimating];
        
        __block FinishedLoadingMessageType getFinishedLoadingMessageType;
        __block NSInteger iGetUpdateDataNum=0;
        __block NSString *sGetCustomErrMsg;
        
        if (bInitData) {
            //等待外部加载数据
            if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingDownRefreshing:)]) {
                [_pullingDelegate pullingDownRefreshing:^(FinishedLoadingMessageType finishedLoadingMessageType, NSInteger iHasUpdateDataNum,NSString *sCustomErrMsg) {
                    getFinishedLoadingMessageType=finishedLoadingMessageType;
                    iGetUpdateDataNum=iHasUpdateDataNum;
                    sGetCustomErrMsg=sCustomErrMsg;
                    
                    //sleep实现动画效果
                    sleep(fDelayTime);
                    
                    //HUD 显示内容 在主线程中处理结果
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [UIView animateWithDuration:fAnimationDuration*2 animations:^{
                            self.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
                        } completion:^(BOOL finished) {
                            [self LoadDataEnd:YES pType:getFinishedLoadingMessageType iHasUpdateDataNum:iGetUpdateDataNum sCustomErrMsg:sGetCustomErrMsg];
                        }];
                    }];
                }];
            }
        }else{
            [UIView animateWithDuration:fAnimationDuration animations:^{
                self.contentInset=UIEdgeInsetsMake(iUpdateGap, 0, 0, 0);
            } completion:^(BOOL finished) {
                //外部加载数据
                if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingDownRefreshing:)]) {
                    [_pullingDelegate pullingDownRefreshing:^(FinishedLoadingMessageType finishedLoadingMessageType, NSInteger iHasUpdateDataNum,NSString *sCustomErrMsg) {
                        getFinishedLoadingMessageType=finishedLoadingMessageType;
                        iGetUpdateDataNum=iHasUpdateDataNum;
                        sGetCustomErrMsg=sCustomErrMsg;
                        //sleep实现动画效果
                        sleep(fDelayTime);
                        //HUD 显示内容 在主线程中处理结果
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [UIView animateWithDuration:fAnimationDuration*2 animations:^{
                                self.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
                            } completion:^(BOOL finished) {
                                [self LoadDataEnd:YES pType:getFinishedLoadingMessageType iHasUpdateDataNum:iGetUpdateDataNum sCustomErrMsg:sGetCustomErrMsg];
                            }];
                        }];
                        
                        
                    }];
                }
            }];
        }
    }
}

// 开始上拉加载数据
- (void) UpLoadDataBegin
{
    if (bLoading==NO)
    {
        bLoading=YES;
        
        [lblFooterRefreshState setText:txtLoadingData];
        
        __block FinishedLoadingMessageType getFinishedLoadingMessageType;
        __block NSInteger iGetUpdateDataNum=0;
        __block NSString *sGetCustomErrMsg;
        
        //加载等待
        UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(75.0f, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [tableFooterActivityIndicator startAnimating];
        [self.tableFooterView addSubview:tableFooterActivityIndicator];
        
        //外部加载数据
        if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingUpLoading:)]) {
            [_pullingDelegate pullingUpLoading:^(FinishedLoadingMessageType finishedLoadingMessageType, NSInteger iHasUpdateDataNum,NSString *sCustomErrMsg) {
                getFinishedLoadingMessageType=finishedLoadingMessageType;
                iGetUpdateDataNum=iHasUpdateDataNum;
                sGetCustomErrMsg=sCustomErrMsg;
                //sleep实现动画效果
                sleep(fDelayTime);
                
                //在主线程中跳转到指定View
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self LoadDataEnd:NO pType:getFinishedLoadingMessageType iHasUpdateDataNum:iGetUpdateDataNum sCustomErrMsg:sGetCustomErrMsg];
                }];
            }];
        }
    }
}



//加载数据完毕 bDownRefreshing 标记 上,下拉
- (void)LoadDataEnd:(BOOL)bDownRefreshing pType:(FinishedLoadingMessageType)pType iHasUpdateDataNum:(NSInteger)piHasUpdateDataNum sCustomErrMsg:(NSString *)sCustomErrMsg
{
    if (bDownRefreshing) {
        downRefreshactivityIndicator.hidden=YES;
        [downRefreshactivityIndicator stopAnimating];
    }else{
        [self createTableFooter];
    }
    self.backgroundColor=[UIColor groupTableViewBackgroundColor];
    //提示刷新结果
    switch (pType) {
        case FinishedLoadingNoDataUpdate:{
            if (bInitData) {
                self.scrollEnabled=NO;
                [lblFooterRefreshState setText:@""];
                self.backgroundColor=[UIColor whiteColor];
            }
            [self refreshResultMessage:FinishedLoadingNoDataUpdate iHasUpdateDataNum:0 pbDownRefreshing:bDownRefreshing sCustomErrMsg:nil];
            break;
        }case FinishedLoadingMessageHasUpdateNum:{
            bInitData=NO;
            if (piHasUpdateDataNum==0) {
                [self refreshResultMessage:FinishedLoadingNoDataUpdate iHasUpdateDataNum:0 pbDownRefreshing:bDownRefreshing sCustomErrMsg:nil];
            }else{
                //刷新数据
                [self reloadData];
                [self refreshResultMessage:FinishedLoadingMessageHasUpdateNum iHasUpdateDataNum:piHasUpdateDataNum  pbDownRefreshing:bDownRefreshing sCustomErrMsg:nil];
            }
            break;
        }case FinishedLoadingMessageError:{
            if (bInitData) {
                self.scrollEnabled=NO;
                [lblFooterRefreshState setText:@""];
                self.backgroundColor=[UIColor whiteColor];
            }
            [self refreshResultMessage:FinishedLoadingMessageError iHasUpdateDataNum:0  pbDownRefreshing:bDownRefreshing sCustomErrMsg:sCustomErrMsg];
            break;
        }
        default:
            break;
    }
    
}


#pragma mark 刷新完后显示对应信息
- (void)refreshResultMessage:(FinishedLoadingMessageType)pType iHasUpdateDataNum:(NSInteger)piHasUpdateDataNum pbDownRefreshing:(BOOL)pbDownRefreshing sCustomErrMsg:(NSString *)sCustomErrMsg{
    //Show message
    
    //刷新完后的结果显示
    UILabel *lblRefreshResult = [[UILabel alloc] init];
    lblRefreshResult.font = [UIFont systemFontOfSize:14.f];
    lblRefreshResult.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lblRefreshResult.backgroundColor = KDefaultColor;
    lblRefreshResult.textColor=[UIColor whiteColor];
    lblRefreshResult.alpha =fAlpha;
    lblRefreshResult.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblRefreshResult];
    
    NSString *sMessage=@"";
    switch (pType) {
        case FinishedLoadingNoDataUpdate:{
            sMessage=txtNoDataForUpdate;
            break;
        }
        case FinishedLoadingMessageHasUpdateNum:{
            sMessage=[NSString stringWithFormat:@"已更新 %ld 条记录",(long)piHasUpdateDataNum];
            break;
        }case FinishedLoadingMessageError:{
            if (sCustomErrMsg==nil || [sCustomErrMsg isEqualToString:@""]) {
                sMessage=txtGetDataError;
            }else{
                sMessage=sCustomErrMsg;
            }
            lblRefreshResult.backgroundColor = [UIColor redColor];
            lblRefreshResult.alpha=0.6;
            lblRefreshResult.textColor=[UIColor whiteColor];
            break;
        }
        default:
            break;
    }
    
    if (!sMessage) return;
    
    lblRefreshResult.text = sMessage;
    
    __block CGRect rect;
    
    if (pbDownRefreshing) {
        //下拉
        rect = CGRectMake(0, -iUpdateGap, self.bounds.size.width, iUpdateGap);
        lblRefreshResult.frame = rect;
        
        rect.origin.y += iUpdateGap;
        [UIView animateWithDuration:.4f animations:^{
            lblRefreshResult.frame = rect;
        } completion:^(BOOL finished){
            rect.origin.y -= iUpdateGap;
            [UIView animateWithDuration:.4f delay:1.2f options:UIViewAnimationOptionCurveLinear animations:^{
                lblRefreshResult.frame = rect;
            } completion:^(BOOL finished){
                [lblRefreshResult removeFromSuperview];
                bLoading = NO;
                //首次获取数据失败时
                if (bInitData) {
                    [lblFooterRefreshState setText:txtReloadMoreData];
                }
            }];
        }];

    }else{
        //上拉
        
        //标记是否显示上拉时数据更新结果
        if (self.bNotShowMessageInUpRefreshing && !pbDownRefreshing) {
            [lblRefreshResult removeFromSuperview];
            bLoading = NO;
        }else{
            rect = CGRectMake(0, iCurScrollSizeHeight, self.frame.size.width, iUpdateGap);
            lblRefreshResult.frame = rect;
            
            rect.origin.y -= iUpdateGap;
            [UIView animateWithDuration:.4f animations:^{
                lblRefreshResult.frame = rect;
            } completion:^(BOOL finished){
                rect.origin.y += iUpdateGap;
                [UIView animateWithDuration:.4f delay:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
                    lblRefreshResult.frame = rect;
                } completion:^(BOOL finished){
                    [lblRefreshResult removeFromSuperview];
                    bLoading = NO;
                }];
            }];
        }
    }
}
@end
