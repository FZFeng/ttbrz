//
//  UIViewControllerSelectMemberOrKanban.m
//  ttbrz
//
//  Created by apple on 16/4/1.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTaskSelectMember.h"

#define  KTbHeaderHeight  40
#define  KImageCorrorTag  100

#define KPerDataNum        5

@interface UIViewControllerTaskSelectMember ()<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *_tbView;
    IBOutlet UIButton *_btnConfirm;
    NSMutableArray *_arryExpand;
    NSMutableArray *_arrayUser;
    float _fUserDetailRowHeight;
}

@end

@implementation UIViewControllerTaskSelectMember

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    if (self.bSelectVisibleMember) {
        lblTitle.text=@"选择可见人员";
    }else{
        lblTitle.text=@"选择执行人";
    }
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTaskMember" bundle:nil];
    [_tbView registerNib:nibCell forCellReuseIdentifier:@"TbCellTaskMember"];
    
    TbCellTaskMember *colleagueLogCell=[_tbView dequeueReusableCellWithIdentifier:@"TbCellTaskMember"];
    _fUserDetailRowHeight=CGRectGetHeight(colleagueLogCell.frame);

    
    _tbView.delegate=self;
    _tbView.dataSource=self;
    
    if (!self.arraySelectedUser) {
        self.arraySelectedUser=[[NSMutableArray alloc] init];
    }
    _arryExpand=[[NSMutableArray alloc] init];
    _arrayUser=[[NSMutableArray alloc] init];
    
    if (self.arrayData.count>0) {
        for (int i=0; i<=self.arrayData.count-1; i++) {
            ClassTask *cClassObject=[self.arrayData objectAtIndex:i];
            [_arrayUser addObject:cClassObject.arrayUsers];
            
            NSDictionary *curDict=[[NSDictionary alloc] initWithObjectsAndKeys:@"no",@"expanded", nil];
            [_arryExpand addObject:curDict];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableview delegate
// 设置header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return KTbHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[_arryExpand objectAtIndex:indexPath.section] objectForKey:@"expanded"] isEqualToString:@"no"] ) {
        //缩回
        return KTbHeaderHeight;
    }else{
        //展开
        return _fUserDetailRowHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *viewHeader=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), KTbHeaderHeight)];
    viewHeader.backgroundColor=[UIColor whiteColor];
    NSInteger iImageSize=25;
    NSInteger iGap=10;
    UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(iGap,(CGRectGetHeight(viewHeader.frame)-iImageSize)/2, iImageSize, iImageSize)];
    imageCorror.tag=KImageCorrorTag+section;
    [viewHeader addSubview:imageCorror];
    
    if ([[[_arryExpand objectAtIndex:section] objectForKey:@"expanded"] isEqualToString:@"yes"] ) {
        //展开
        imageCorror.image=[UIImage imageNamed:@"taskSelectMemberDown.png"];
    }else{
        //缩回
        imageCorror.image=[UIImage imageNamed:@"taskSelectMemberRight.png"];
    }
    
    UIButton* btnHeader = [[UIButton alloc] initWithFrame:CGRectMake(iGap+iImageSize, 0, CGRectGetWidth(viewHeader.frame), CGRectGetHeight(viewHeader.frame))];
    [btnHeader addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnHeader.tag = section;
    btnHeader.accessibilityLabel=@"nocheck";
    btnHeader.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //设置按钮显示颜色
    ClassTask *cClassObject=[self.arrayData objectAtIndex:section];
    btnHeader.backgroundColor = [UIColor clearColor];
    [btnHeader setTitle:cClassObject.sDeptName forState:UIControlStateNormal];
    [btnHeader setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnHeader.titleLabel.font=[UIFont systemFontOfSize:15];
    
    [viewHeader addSubview: btnHeader];
    
    return viewHeader;
}


//按钮被点击时触发
-(void)expandButtonClicked:(id)sender{
    
    UIButton* btnObj= (UIButton*)sender;
    NSInteger iSection=btnObj.tag;
    NSMutableDictionary* dictData=[_arryExpand objectAtIndex:iSection];
    //若本节model中的“expanded”属性不为空，则取出来
    if([[dictData objectForKey:@"expanded"] isEqualToString:@"no"]){
        [_arryExpand replaceObjectAtIndex:iSection withObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"yes",@"expanded", nil]];
    }else{
        [_arryExpand replaceObjectAtIndex:iSection withObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"no",@"expanded", nil]];
    }
    
    //刷新tableview
    [_tbView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *curIndexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    TbCellTaskMember *colleagueLogCell=[tableView cellForRowAtIndexPath:curIndexPath];
    
    UIButton *btnObj=colleagueLogCell.btnSelected;
    NSInteger iTag=btnObj.tag;
    NSInteger iRow=[btnObj.accessibilityIdentifier integerValue];
    NSString *sCheck=btnObj.accessibilityLabel;
    NSArray *curArrayUser=[_arrayUser objectAtIndex:iTag];
    NSDictionary *dictData=[curArrayUser objectAtIndex:iRow];
    
    if ([sCheck isEqualToString:@"no"]) {
        btnObj.accessibilityLabel=@"yes";
        [btnObj setBackgroundImage:[UIImage imageNamed:@"userRegister_checkOn"] forState:UIControlStateNormal];
        [self.arraySelectedUser addObject:dictData];
    }else{
        btnObj.accessibilityLabel=@"no";
        [btnObj setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
        for (int i=0; i<=self.arraySelectedUser.count-1; i++) {
            NSDictionary *curDict=[self.arraySelectedUser objectAtIndex:i];
            NSString *sCurID=[curDict objectForKey:@"UserID"];
            if ([sCurID isEqualToString:[dictData objectForKey:@"UserID"]]) {
                [self.arraySelectedUser removeObjectAtIndex:i];
                break;
            }
        }
    }

    
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *curArrayUser=[_arrayUser objectAtIndex:indexPath.section];
    NSDictionary *dictData=[curArrayUser objectAtIndex:indexPath.row];
    TbCellTaskMember *colleagueLogCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskMember"];
    
    colleagueLogCell.btnSelected.tag=indexPath.section;
    colleagueLogCell.btnSelected.accessibilityLabel=@"no";
    [colleagueLogCell.btnSelected setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
    colleagueLogCell.btnSelected.accessibilityIdentifier=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [colleagueLogCell.btnSelected addTarget:self action:@selector(didBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *sMemberName=[dictData objectForKey:@"UserName"];
    NSString *sMemberID=[dictData objectForKey:@"UserID"];
    colleagueLogCell.lblMemberName.text=sMemberName;
    
    //判断是否已选
    if (self.arraySelectedUser.count>0) {
        for (NSDictionary *curDict in self.arraySelectedUser) {
            if ([[curDict objectForKey:@"UserID"] isEqualToString:sMemberID]) {
                colleagueLogCell.btnSelected.accessibilityLabel=@"yes";
                [colleagueLogCell.btnSelected setBackgroundImage:[UIImage imageNamed:@"userRegister_checkOn"] forState:UIControlStateNormal];
                break;
            }
        }
    }
    
    
    [colleagueLogCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return colleagueLogCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.arrayData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    //对指定节进行“展开”判断
    if ([[[_arryExpand objectAtIndex:section] objectForKey:@"expanded"] isEqualToString:@"no"] ) {
        //缩回
        return 0;
    }else{
        //展开
        NSArray *arrayRow=[_arrayUser objectAtIndex:section];
        return arrayRow.count;
    }
}

//选中/不选中
- (void)didBtnSelect:(id)sender{

    UIButton *btnObj=sender;
    NSInteger iTag=btnObj.tag;
    NSInteger iRow=[btnObj.accessibilityIdentifier integerValue];
    NSString *sCheck=btnObj.accessibilityLabel;
    NSArray *curArrayUser=[_arrayUser objectAtIndex:iTag];
    NSDictionary *dictData=[curArrayUser objectAtIndex:iRow];
    
    if ([sCheck isEqualToString:@"no"]) {
        btnObj.accessibilityLabel=@"yes";
        [btnObj setBackgroundImage:[UIImage imageNamed:@"userRegister_checkOn"] forState:UIControlStateNormal];
        [self.arraySelectedUser addObject:dictData];
    }else{
        btnObj.accessibilityLabel=@"no";
        [btnObj setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
        for (int i=0; i<=self.arraySelectedUser.count-1; i++) {
            NSDictionary *curDict=[self.arraySelectedUser objectAtIndex:i];
            NSString *sCurID=[curDict objectForKey:@"UserID"];
            if ([sCurID isEqualToString:[dictData objectForKey:@"UserID"]]) {
                [self.arraySelectedUser removeObjectAtIndex:i];
                break;
            }
        }
    }
}

#pragma mark 保存
- (IBAction)didBtnConfirm:(id)sender {
    
    if (self.bSelectVisibleMember) {
        UIViewControllerEditNewKanbanClass *addNewKanbanView=[self.navigationController.viewControllers objectAtIndex:1];
        [addNewKanbanView displaySelectedMember:self.arraySelectedUser];
        [self.navigationController popToViewController:addNewKanbanView animated:YES];
    }else{
        
        NSInteger iIndex=0;
        for (UIViewController *uiview in self.navigationController.viewControllers) {
            
            if (![uiview isKindOfClass:[UITabBarController class]]) {
                if ([uiview.accessibilityLabel isEqualToString:@"UIViewControllerEditCreateTaskInKanBan"]) {
                    break;
                }
            }
            iIndex++;
        }
        
        UIViewControllerEditCreateTaskInKanBan *createTaskInKanBanView=[self.navigationController.viewControllers objectAtIndex:iIndex];
        [createTaskInKanBanView displaySelectedMember:self.arraySelectedUser];
        [self.navigationController popToViewController:createTaskInKanBanView animated:YES];
    }
}
@end
