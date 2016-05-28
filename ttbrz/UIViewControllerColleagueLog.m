//
//  UIViewControllerColleagueLog.m
//  ttbrz
//
//  Created by apple on 16/2/20.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerColleagueLog.h"
#define  KTbHeaderHeight  40
#define  KImageCorrorTag  100

#define KPerDataNum        5


@interface UIViewControllerColleagueLog ()<DownMenuViewDelegate,UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *_tbDepartmentView;
    NSArray *_arrayDepartment;
    NSMutableArray *_arrayUser;
    NSMutableArray *_arryExpand;
    float _fUserDetailRowHeight;
}

@end

@implementation UIViewControllerColleagueLog

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super initNavigationWithTabBarIndex:KTabBarIndexLog menuItemTitle:KTitleLog_ColleagueLog];
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellColleague" bundle:nil];
    [_tbDepartmentView registerNib:nibCell forCellReuseIdentifier:@"TbCellColleague"];
    
    TbCellColleague *colleagueLogCell=[_tbDepartmentView dequeueReusableCellWithIdentifier:@"TbCellColleague"];
    _fUserDetailRowHeight=CGRectGetHeight(colleagueLogCell.frame);
    
    //等待加载数据
    [self performSelector:@selector(loadingData) withObject:self afterDelay:0.1];
}

#pragma mark 加载初始数据
- (void)loadingData{
    
    _arrayDepartment=[[NSArray alloc] init];
    _arrayUser=[[NSMutableArray alloc] init];
    _arryExpand=[[NSMutableArray alloc] init];
    
    [ClassLog getDepartmentAndUserDataWithID:[SystemPlist GetUserID] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            _arrayDepartment=returnArray;
            
            if (_arrayDepartment.count>0) {
                for (int i=0; i<=_arrayDepartment.count-1; i++) {
                    ClassLog *cClassLogObject=[_arrayDepartment objectAtIndex:i];
                    [_arrayUser addObject:cClassLogObject.arrayUsers];
                    
                    NSDictionary *curDict=[[NSDictionary alloc] initWithObjectsAndKeys:@"no",@"expanded", nil];
                    [_arryExpand addObject:curDict];
                }
            }else{
                _tbDepartmentView.dataSource=nil;
                _tbDepartmentView.delegate=nil;
            }
        }else{
            _tbDepartmentView.dataSource=nil;
            _tbDepartmentView.delegate=nil;
        }
        
        [_tbDepartmentView reloadData];
    }];

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
    NSInteger iImageSize=15;
    NSInteger iGap=10;
    UIImageView *imageCorror=[[UIImageView alloc] initWithFrame:CGRectMake(iGap,(CGRectGetHeight(viewHeader.frame)-iImageSize)/2, iImageSize, iImageSize)];
    imageCorror.tag=KImageCorrorTag+section;
    [viewHeader addSubview:imageCorror];
    
    if ([[[_arryExpand objectAtIndex:section] objectForKey:@"expanded"] isEqualToString:@"yes"] ) {
        //展开
       imageCorror.image=[UIImage imageNamed:@"colleagueLog_down_corror.png"];
    }else{
        //缩回
        imageCorror.image=[UIImage imageNamed:@"colleagueLog_right_corror.png"];
    }

    
    UIButton* btnHeader = [[UIButton alloc] initWithFrame:CGRectMake(iGap+iImageSize, 0, CGRectGetWidth(viewHeader.frame), CGRectGetHeight(viewHeader.frame))];
    [btnHeader addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnHeader.tag = section;
    btnHeader.accessibilityLabel=@"nocheck";
    btnHeader.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //设置按钮显示颜色
    ClassLog *cClassLogObject=[_arrayDepartment objectAtIndex:section];
    btnHeader.backgroundColor = [UIColor clearColor];
    [btnHeader setTitle:cClassLogObject.sDeptName forState:UIControlStateNormal];
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
    [_tbDepartmentView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取对应同事日志数据
    
    //今天日期
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //userId
     NSArray *arrayRow=[_arrayUser objectAtIndex:indexPath.section];
    NSDictionary *dictData=[arrayRow objectAtIndex:indexPath.row];

    
    [ClassLog getLogDataWithDate:[dateFormatter stringFromDate:nowDate] dayNum:KPerDataNum iType:-1 userID:[dictData objectForKey:@"UserID"] companyID:[SystemPlist GetCompanyID] fatherObject:self returnBlock:^(BOOL bReturn, NSArray *returnArray) {
        if (bReturn) {
            UIViewControllerColleagueDetailLog *colleagueDetailLogView=[self.storyboard instantiateViewControllerWithIdentifier:@"UIViewControllerColleagueDetailLog"];
            colleagueDetailLogView.arrayMemberData=[_arrayUser objectAtIndex:indexPath.section];
           
            colleagueDetailLogView.sGetSelectedMemberName=[dictData objectForKey:@"UserName"];
            colleagueDetailLogView.sGetSelectedMemberID=[dictData objectForKey:@"UserID"];
            colleagueDetailLogView.arrayGetLogData=[returnArray mutableCopy];
            UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
            [self.tabBarController.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:colleagueDetailLogView animated:YES];

        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *curArrayUser=[_arrayUser objectAtIndex:indexPath.section];
    NSDictionary *dictData=[curArrayUser objectAtIndex:indexPath.row];
    TbCellColleague *colleagueLogCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellColleague"];
  
    //头像，如果头像为空，就用名字的最后一个字符代替
    NSString *sMemberName=[dictData objectForKey:@"UserName"];
    NSString *sUserPhoto=[dictData objectForKey:@"vchrPhoto"];
    
    if ([sUserPhoto isEqualToString:@""]) {
        colleagueLogCell.lblMemberMark.text=[sMemberName substringFromIndex:sMemberName.length-1];
        colleagueLogCell.lblMemberMark.hidden=NO;
        
        colleagueLogCell.imageMemberIcon.hidden=YES;
        colleagueLogCell.imageMemberIcon.image=nil;
    }else{
        colleagueLogCell.lblMemberMark.hidden=YES;
        
        NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sUserPhoto options:0];
        colleagueLogCell.imageMemberIcon.hidden=NO;
        colleagueLogCell.imageMemberIcon.image=[UIImage imageWithData:photoData];
    }


    colleagueLogCell.lblTeamMemberName.text=[NSString stringWithFormat:@"%@(%@)",sMemberName,[dictData objectForKey:@"Dept"]];
   
    [colleagueLogCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return colleagueLogCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_arrayDepartment count];
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


@end
