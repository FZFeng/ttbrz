
#import "UIViewControllerTask.h"
#define KStartDataIndex    1
#define KPerDataNum        5
#define KTbCellRowHeight  40

@interface UIViewControllerTask ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{

    IBOutlet UITableView *_tbView;
    
    NSInteger _iCurDataIndex;//当前任务数据的页数
    NSInteger _iCurLookBoardTypeIndex;
    
    UILabel *_lblFileTbFooter;
    //NSInteger _iCurFileDataIndex;//当前数据的页数
    BOOL _bHasMoreFileData;//标记是否还能加载更多数据
    UIActivityIndicatorView *_fileTbFooterAcIndicator;//加载等待
}

@end

@implementation UIViewControllerTask

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _iCurDataIndex=1;
    _iCurLookBoardTypeIndex=0;
    
    _bHasMoreFileData=YES;

    [super initNavigationWithTabBarIndex:KTabBarIndexTask menuItemTitle:KTitleTask_Task];
    
    //默认先不显示分割线
    _tbView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //去掉左边的空白
    if ([_tbView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tbView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([_tbView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tbView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    //等待加载数据
    [self performSelector:@selector(loadingTaskData) withObject:self afterDelay:0.1];
}

//加载数据
- (void)loadingTaskData{
    [ClassTask getNormalClassifyKanbanDataWithGuidCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] Page:KStartDataIndex Rows:KPerDataNum  fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            
            _tbView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            
            _bHasMoreFileData=YES;
            
            NSInteger taskTbFooterLabelW=100;
            NSInteger iViewTbFooterH=30;
            NSInteger iViewW=CGRectGetWidth(self.view.frame);
            UIView *viewTbFooter=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iViewW, iViewTbFooterH)];
            
            _lblFileTbFooter=[[UILabel alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2, 0, taskTbFooterLabelW, iViewTbFooterH)];
            _lblFileTbFooter.textAlignment=NSTextAlignmentCenter;
            _lblFileTbFooter.font=[UIFont systemFontOfSize:13];
            _lblFileTbFooter.textColor=[UIColor lightGrayColor];
            [viewTbFooter addSubview:_lblFileTbFooter];
            
            NSInteger taskTbFooterAcIndicatorSize=30;
            _fileTbFooterAcIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((iViewW-taskTbFooterLabelW)/2-taskTbFooterAcIndicatorSize, 0,taskTbFooterAcIndicatorSize,taskTbFooterAcIndicatorSize)];
            [_fileTbFooterAcIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            _fileTbFooterAcIndicator.hidden=YES;
            [viewTbFooter addSubview:_fileTbFooterAcIndicator];

            
            if (returnArray.count>0) {
                self.arrayLookBoardData=[returnArray mutableCopy];
                
                _tbView.dataSource=self;
                _tbView.delegate=self;
                _tbView.rowHeight=KTbCellRowHeight;
                
                 _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                
            }else{
                _tbView.dataSource=nil;
                _tbView.delegate=nil;
                
                 _lblFileTbFooter.text=@"暂无数据";
            }
            
            _tbView.tableFooterView=viewTbFooter;
             [_tbView reloadData];
            
            if (returnArray.count==KPerDataNum) {
                _iCurDataIndex=2;
            }
        }
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 增加任务
- (void)addNewTask{
    UIViewControllerEditNewKanbanClass *addNewKanbanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerAddNewKanban"];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:addNewKanbanView animated:YES];
}



#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //要划到底部才加载数据
    CGFloat scrolHeight=CGRectGetHeight(scrollView.frame);
    CGFloat contentY=scrollView.contentOffset.y;
    CGFloat distanceFromBottom=scrollView.contentSize.height-contentY;
    
    if (distanceFromBottom<=scrolHeight) {
        
        if(!_bHasMoreFileData){
            return;
        }
        //加载数据
        _lblFileTbFooter.text=@"正在加载中...";
        _fileTbFooterAcIndicator.hidden=NO;
        [_fileTbFooterAcIndicator startAnimating];
        
        [ClassTask getNormalClassifyKanbanDataNoHUDWithGuidCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] Page:_iCurDataIndex Rows:KPerDataNum returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                _lblFileTbFooter.text=@"滑动加载更多 \u25BE";
                if (bReturn) {
                    if (!returnArray || returnArray.count==0) {
                        _lblFileTbFooter.text=@"已全部加载完毕";
                        _bHasMoreFileData=NO;
                    }else{
                        //任务数据不足5条数据时 为数据的第一页
                        if (_iCurDataIndex==1 ) {
                            //先清除进入页面时初始化的数据
                            [self.arrayLookBoardData removeAllObjects];
                            
                            self.arrayLookBoardData=[returnArray mutableCopy];
                            if (returnArray.count==KPerDataNum) {
                                _iCurDataIndex=2;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                        }else{
                            if (returnArray.count==KPerDataNum) {
                                _iCurDataIndex++;
                            }else{
                                _bHasMoreFileData=NO;
                                _lblFileTbFooter.text=@"已全部加载完毕";
                            }
                            //插入数据
                            for (NSDictionary *dictData in returnArray) {
                                [self.arrayLookBoardData addObject:dictData];
                            }
                            [_tbView reloadData];
                        }
                    }
                }
                _fileTbFooterAcIndicator.hidden=YES;
                [_fileTbFooterAcIndicator stopAnimating];
            }
        }];
    }
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClassTask *cClassTaskData=[self.arrayLookBoardData objectAtIndex:indexPath.row];
    
    NSString *reuseIdentifier = @"myCell";
    
    UITableViewCell *myCell;
    if (myCell == nil) {
        myCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    NSInteger iLeftGap=15;
    NSInteger iIconSize=20;
    //图标
    UIImageView *imageFileIcon=[[UIImageView alloc] initWithFrame:CGRectMake(iLeftGap,(KTbCellRowHeight-iIconSize)/2, iIconSize, iIconSize)];
    imageFileIcon.image=[UIImage imageNamed:@"classlyTypekanpan.png"];
    [myCell.contentView addSubview:imageFileIcon];
    //标题
    UILabel *lblDownloadFileName=[[UILabel alloc] initWithFrame:CGRectMake(iLeftGap*2+iIconSize, 0, CGRectGetWidth(self.view.frame)-iLeftGap*2-iIconSize, KTbCellRowHeight)];
    lblDownloadFileName.text=cClassTaskData.sLookBoardTypeName;
    lblDownloadFileName.font=[UIFont systemFontOfSize:15];
    [myCell.contentView addSubview:lblDownloadFileName];
    
    //箭头
    NSInteger iIconCorrorW=10;
    NSInteger iIconCorrorH=15;
    UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-iLeftGap-iIconCorrorW,(KTbCellRowHeight-iIconCorrorH)/2, iIconCorrorW, iIconCorrorH)];
    imageCorror.image=[UIImage imageNamed:@"list_arrowright_grey.png"];
    [myCell.contentView addSubview:imageCorror];
    
    //长按事件
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds  设置响应时间
    lpgr.delegate = self;
    lpgr.accessibilityLabel=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [myCell addGestureRecognizer:lpgr]; //启用长按事件
    
    return myCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayLookBoardData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClassTask *cClassTaskData=[self.arrayLookBoardData objectAtIndex:indexPath.row];
    [ClassTask GetLookBoardAndTaskDataWithCompanyID:[SystemPlist GetCompanyID] userID:[SystemPlist GetUserID] strLookBoardTypeID:cClassTaskData.sPK_LookBoardTypeID Page:1 Rows:KPerDataNum fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            UIViewControllerKanbanInfo *kanbanInfoView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerKanbanInfo"];
            kanbanInfoView.arrayInitData=[returnArray mutableCopy];
            kanbanInfoView.sGetTitle=cClassTaskData.sLookBoardTypeName;
            kanbanInfoView.sGetLookBoardTypeID=cClassTaskData.sPK_LookBoardTypeID;
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:kanbanInfoView animated:YES];
        }
    }];
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

//长按事件
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //长按响应函数
{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        UILongPressGestureRecognizer *cObj=gestureRecognizer;
        _iCurLookBoardTypeIndex=[cObj.accessibilityLabel integerValue];
        __block ClassTask *cClassTaskData=[self.arrayLookBoardData objectAtIndex:_iCurLookBoardTypeIndex];
        
        //检测权限
        //判断是否分类创建人
        if (![cClassTaskData.sFK_guidCreateUserID isEqualToString:[SystemPlist GetUserID]]) {
            
            NSArray *arrayAuthorityManagementInfo=cClassTaskData.arrayAuthorityManagementInfo;
            if (arrayAuthorityManagementInfo.count>0) {
                BOOL bHasRoot=NO;
                //不是创建人的，就看下AuthorityManagementInfo中是否包含当前人
                for (NSDictionary *dictData in cClassTaskData.arrayAuthorityManagementInfo) {
                    NSString *sCurUserID=[dictData objectForKey:@"AuthorityUserID"];
                    if ([sCurUserID isEqualToString:[SystemPlist GetUserID]]) {
                        bHasRoot=YES;
                        break;
                    }
                }
                if (!bHasRoot) {
                    [PublicFunc ShowSimpleMsg:@"您没有操作权限"];
                    return;
                }
            }
        }
        
        UIAlertController *alertSelect=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"编缉分类" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIViewControllerEditNewKanbanClass *editNewKanbanView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerAddNewKanban"];
            editNewKanbanView.bEditKanban=YES;
            editNewKanbanView.cClassTaskData=[self.arrayLookBoardData objectAtIndex:_iCurLookBoardTypeIndex];
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:editNewKanbanView animated:YES];
            
        }];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"归档分类" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            cClassTaskData=[self.arrayLookBoardData objectAtIndex:_iCurLookBoardTypeIndex];
            [ClassTask editKanbanClassificationWithName:cClassTaskData.sLookBoardTypeName ShowIndex:[cClassTaskData.sShowIndex integerValue] State:1 KanBanTypeId:cClassTaskData.sPK_LookBoardTypeID AuthorityType:@"" AuthorityIds:@"" UserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
                if (bReturn) {
                    [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                    //删除,归档数据后刷新数据
                    [self performSelector:@selector(loadingTaskData) withObject:nil afterDelay:1.5];
                }
            }];
        }];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除分类" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作提示" message:@"确定要删除吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [alert show];
        }];
        
        [alertSelect addAction:cancelAction];
        [alertSelect addAction:editAction];
        [alertSelect addAction:saveAction];
        [alertSelect addAction:deleteAction];
        
        [self presentViewController:alertSelect animated:YES completion:nil];
    }
}

#pragma mark 删除看板
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        ClassTask *cClassTaskData=[self.arrayLookBoardData objectAtIndex:_iCurLookBoardTypeIndex];
        [ClassTask DeleteKanbanClassificationWithKanbanTypeId:cClassTaskData.sPK_LookBoardTypeID UserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
            if (bReturn) {
                 [PublicFunc ShowSuccessHUD:@"操作成功" view:self.view];
                //删除,归档数据后刷新数据
                [self performSelector:@selector(loadingTaskData) withObject:nil afterDelay:1.5];
            }
        }];
    }
}


@end
