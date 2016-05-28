#import "UIViewControllerBase.h"

#define KStoryBoardID_MyLog        @"UIViewMyLog"
#define KStoryBoardID_TeamLog      @"UIViewTeamLog"
#define KStoryBoardID_ColleagueLog @"UIViewColleagueLog"
#define KStoryBoardID_LogAssess    @"UIViewLogAssess"

#define KStoryBoardID_Task         @"UIViewTask"
#define KStoryBoardID_TeamTask     @"UIViewTeamTask"
#define KStoryBoardID_MyTask       @"UIViewMyTask"

#define KStoryBoardID_MyIntegral   @"UIViewMyIntegral"
#define KStoryBoardID_TeamIntegral @"UIViewTeamIntegral"

#define KRightBarButtonSize 17.0
#define KFontSize15 [UIFont systemFontOfSize:15];

@interface UIViewControllerBase ()<DownMenuViewDelegate>{

    UIButton *_titleButton;
    DownMenuView *_downMenu;
    NSArray *_menuItemArray;
    
    NSInteger _selectedTabBarIndex;//当前选择的功能模块
    UILabel *lblMessage;
   
}

@end

NSString *KTitleLog_MyLog=@"我的日志";
NSString *KTitleLog_TeamLog=@"团队日志";
NSString *KTitleLog_ColleagueLog=@"同事日志";
NSString *KTitleLog_LogAssess=@"日志考评";

NSString *KTitleTask_Task=@"任务看板";
NSString *KTitleTask_TeamTask=@"团队任务";
NSString *KTitleTask_MyTask=@"我安排的";

NSString *KTitleIntegral_MyIntegral=@"我的积分";
NSString *KTitleIntegral_TeamIntegral=@"团队积分";

NSString *KTitleMy=@"我";

NSInteger  const KTabBarIndexLog=0;       //日志功能模块
NSInteger  const KTabBarIndexTask=1;      //任务功能模块
NSInteger  const KTabBarIndexIntegral=2;  //积分功能模块
NSInteger  const KTabBarIndexMy=3;        //我的功能模块

@implementation UIViewControllerBase

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 设置Nav的标题
- (void)initNavigationWithTabBarIndex:(NSInteger)tabBarIndex menuItemTitle:(NSString*)itemTitle{
    
    _selectedTabBarIndex=tabBarIndex;
    
    switch (tabBarIndex) {
        case KTabBarIndexLog:{
            _menuItemArray=[[NSArray alloc] initWithObjects:KTitleLog_MyLog,KTitleLog_TeamLog,KTitleLog_ColleagueLog,KTitleLog_LogAssess, nil];
            break;
        }case KTabBarIndexTask:{
            _menuItemArray=[[NSArray alloc] initWithObjects:KTitleTask_Task,KTitleTask_TeamTask,KTitleTask_MyTask, nil];
            break;
        }case KTabBarIndexIntegral:{
            _menuItemArray=[[NSArray alloc] initWithObjects:KTitleIntegral_MyIntegral,KTitleIntegral_TeamIntegral, nil];
            break;
        }case KTabBarIndexMy:{
            _menuItemArray=[[NSArray alloc] initWithObjects:KTitleMy, nil];
            break;
        }
    }
    //设置NavigationItem.title
    
    NSInteger iTitleViewW=100;
    NSInteger iTitleViewH=35;
    NSInteger iDownCorrorIconW=25;
    NSInteger iDownCorrorIconH=15;
    NSInteger iTitleButtonW=75;
    
    self.sUIViewIdenitfy=itemTitle;
    
    UIView *titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iTitleViewW, iTitleViewH)];
    
    _titleButton=[[UIButton alloc] initWithFrame:CGRectMake((iTitleViewW-iTitleButtonW)/2, 0, iTitleButtonW, iTitleViewH)];
    [_titleButton setTitle:itemTitle forState:UIControlStateNormal];
    [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _titleButton.titleLabel.font=[UIFont systemFontOfSize:16];
    if (tabBarIndex!=KTabBarIndexMy) {
        [_titleButton addTarget:self action:@selector(didTitleButton) forControlEvents:UIControlEventTouchUpInside];
    }
    [titleView addSubview:_titleButton];

    if (tabBarIndex!=KTabBarIndexMy) {
        UIImageView *imgTitleIcon=[[UIImageView alloc] initWithFrame:CGRectMake((iTitleViewW-iTitleButtonW)/2+iTitleButtonW,(iTitleViewH-iDownCorrorIconH)/2, iDownCorrorIconW, iDownCorrorIconH)];
        imgTitleIcon.image=[UIImage imageNamed:@"downcorror.png"];
        [titleView addSubview:imgTitleIcon];

    }
    if (tabBarIndex==KTabBarIndexLog) {
        //提示
        NSInteger ilblWaittingCheckNoticeSize=8;
        self.lblWaittingCheckNotice_Base=[[UILabel alloc]initWithFrame:CGRectMake(iTitleViewW, ilblWaittingCheckNoticeSize,ilblWaittingCheckNoticeSize,ilblWaittingCheckNoticeSize)];
        
        NSInteger iNum=[[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"ConfirmLogNum"] ] integerValue];
        if (iNum>0) {
            self.lblWaittingCheckNotice_Base.hidden=NO;
        }else{
            self.lblWaittingCheckNotice_Base.hidden=YES;
        }
        self.lblWaittingCheckNotice_Base.backgroundColor=[UIColor redColor];
        self.lblWaittingCheckNotice_Base.layer.masksToBounds=YES;
        self.lblWaittingCheckNotice_Base.layer.cornerRadius =self.lblWaittingCheckNotice_Base.frame.size.height/2;
        [titleView addSubview:self.lblWaittingCheckNotice_Base];
    }
   
    self.tabBarController.navigationItem.titleView=titleView;
    
    //设置NavigationItem 的left,rigth Button
    if (tabBarIndex==KTabBarIndexTask) {
        self.tabBarController.navigationItem.rightBarButtonItem=nil;
        self.tabBarController.navigationItem.rightBarButtonItems=nil;
        if (![itemTitle isEqualToString:KTitleTask_TeamTask]) {
            //增加任务
            self.tabBarController.navigationItem.rightBarButtonItems=nil;
            UIBarButtonItem *addNewTaskBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTask)];
            self.tabBarController.navigationItem.rightBarButtonItem=addNewTaskBarButtonItem;
        }
    }else{
        //搜索
        UIButton *searchButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,KRightBarButtonSize,KRightBarButtonSize)];
        searchButton.titleLabel.font=KFontSize15;
        [searchButton setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
        [searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchAll) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *searchBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:searchButton];
        
        //消息
        UIButton *messageButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,KRightBarButtonSize,KRightBarButtonSize)];
        messageButton.titleLabel.font=KFontSize15;
        [messageButton setBackgroundImage:[UIImage imageNamed:@"systemMessage.png"] forState:UIControlStateNormal];
        [messageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(showAllMessage) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *messageBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:messageButton];
        
        self.tabBarController.navigationItem.rightBarButtonItems=[[NSArray alloc] initWithObjects:messageBarButtonItem,searchBarButtonItem, nil];
    }
    
    //天天报标题
    UILabel *ttbLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,KRightBarButtonSize*3,KRightBarButtonSize*2)];
    ttbLable.text=@"天天报";
    ttbLable.textColor=[UIColor whiteColor];
    ttbLable.font=KFontSize15;
    UIBarButtonItem *leftButtonItem =[[UIBarButtonItem alloc] initWithCustomView:ttbLable];
    
    self.tabBarController.navigationItem.leftBarButtonItem=leftButtonItem;
    
    //设置 TabBarItem 选中时的图片及文字颜色
    UIImage *image = [self.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = image;
    
    /*
    //设置选中tabbaritem时字体的颜色,只是字体
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor redColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    //设置正常时tabbaritem时字体的颜色,只是字体
    [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor orangeColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
     */

}


#pragma mark 增加任务
- (void)addNewTask{
}

#pragma mark 搜索
- (void)searchAll{
    UIViewControllerSearchInfo *searchInfoView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerSearchInfo"];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:searchInfoView animated:YES];
}

#pragma mark 消息
- (void)showAllMessage{
    [ClassSearchAndMessage getMessageInfoHUDWithID:[SystemPlist GetUserID] strType:@"1" page:1 rows:5 fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            if (returnArray.count>0) {
                UIViewControllerMessageInfo *messageInfoView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerMessageInfo"];
                UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
                
                ClassSearchAndMessage *cObjectData=[returnArray firstObject];
                
                messageInfoView.arrayMessageInfo=[cObjectData.arrayMessageInfo mutableCopy];
                messageInfoView.iGetMessageAllCount=cObjectData.iMessageCount;
                [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
                [self.navigationController pushViewController:messageInfoView animated:YES];
            }else{
                [PublicFunc ShowSimpleHUD:@"暂无消息提醒" view:self.view];
            }
        }
    }];
}


#pragma mark 点击标题事件
- (void)didTitleButton{
    if (!_downMenu) {
        _downMenu=[[DownMenuView alloc] initWithReferView:self.view menuItems:_menuItemArray hasNavItem:YES];
        _downMenu.delegate=self;
    }
    if (!_downMenu.hasShow) {
        [_downMenu show];
        [_downMenu tbViewReloadData];
    }
}

#pragma mark DownMenuViewDelegate 回调
-(void)downMenuView:(UIView *)downMenuView didMenuItemIndex:(NSInteger)itemIndex{
    
    NSString *currentUIViewStoryBoardID=@"";
    NSString *currentMenuItem=[_menuItemArray objectAtIndex:itemIndex];
    
    [_titleButton setTitle:currentMenuItem forState:UIControlStateNormal];
    self.sUIViewIdenitfy=currentMenuItem;
    
    switch (_selectedTabBarIndex) {
        case KTabBarIndexLog:{
            if ([currentMenuItem isEqualToString:KTitleLog_MyLog]) {
                currentUIViewStoryBoardID=KStoryBoardID_MyLog;
            }else if ([currentMenuItem isEqualToString:KTitleLog_TeamLog]){
                currentUIViewStoryBoardID=KStoryBoardID_TeamLog;
            }else if ([currentMenuItem isEqualToString:KTitleLog_ColleagueLog]){
                currentUIViewStoryBoardID=KStoryBoardID_ColleagueLog;
            }else{
                currentUIViewStoryBoardID=KStoryBoardID_LogAssess;
            }
            break;
        }case KTabBarIndexTask:{
            _menuItemArray=[[NSArray alloc] initWithObjects:KTitleTask_Task,KTitleTask_TeamTask,KTitleTask_MyTask, nil];
            if ([currentMenuItem isEqualToString:KTitleTask_Task]) {
                currentUIViewStoryBoardID=KStoryBoardID_Task;
            }else if ([currentMenuItem isEqualToString:KTitleTask_TeamTask]){
                currentUIViewStoryBoardID=KStoryBoardID_TeamTask;
            }else{
                currentUIViewStoryBoardID=KStoryBoardID_MyTask;
            }
            break;
        }case KTabBarIndexIntegral:{
            
            if ([currentMenuItem isEqualToString:KTitleIntegral_MyIntegral]) {
                currentUIViewStoryBoardID=KStoryBoardID_MyIntegral;
            }else{
                currentUIViewStoryBoardID=KStoryBoardID_TeamIntegral;
            }
            break;
        }case KTabBarIndexMy:{
            break;
        }
    }

    NSMutableArray* newViewControllers = [NSMutableArray array];
    for (int i = 0; i < self.tabBarController.viewControllers.count; i++) {
        UIViewController* vc = [self.tabBarController.viewControllers objectAtIndex:i];
        if (i == _selectedTabBarIndex) {
            UIViewController *replacedViewController=[self.storyboard instantiateViewControllerWithIdentifier:currentUIViewStoryBoardID];
            [newViewControllers addObject:replacedViewController];
        }else{
            [newViewControllers addObject:vc];
        }
    }
    self.tabBarController.viewControllers = newViewControllers;
}


@end
