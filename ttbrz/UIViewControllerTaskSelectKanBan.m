//
//  UIViewControllerTaskSelectKanBan.m
//  ttbrz
//
//  Created by apple on 16/4/13.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerTaskSelectKanBan.h"

#define  KTbHeaderHeight  40
#define  KImageCorrorTag  100

@interface UIViewControllerTaskSelectKanBan ()<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *_tbView;

    NSMutableArray *_arryExpand;
    NSMutableArray *_arrayLookBoard;
    float _fRowHeight;
}

@end

@implementation UIViewControllerTaskSelectKanBan

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"请选择看板";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellTaskKanBan" bundle:nil];
    [_tbView registerNib:nibCell forCellReuseIdentifier:@"TbCellTaskKanBan"];
    
    TbCellTaskKanBan *cCell=[_tbView dequeueReusableCellWithIdentifier:@"TbCellTaskKanBan"];
    _fRowHeight=CGRectGetHeight(cCell.frame);
    
    
    _tbView.delegate=self;
    _tbView.dataSource=self;
    
    _arryExpand=[[NSMutableArray alloc] init];
    _arrayLookBoard=[[NSMutableArray alloc] init];
    
    if (self.arrayData.count>0) {
        for (int i=0; i<=self.arrayData.count-1; i++) {
            ClassTask *cClassObject=[self.arrayData objectAtIndex:i];
            [_arrayLookBoard addObject:cClassObject.arrayLookBoardList];
            
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
        return _fRowHeight;
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
    [btnHeader setTitle:cClassObject.sLookBoardTypeName forState:UIControlStateNormal];
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

    ClassTask *cClassLookBoardTypeData=[self.arrayData objectAtIndex:indexPath.section];
    NSArray *curArrayUser=[_arrayLookBoard objectAtIndex:indexPath.section];
    NSDictionary *dictData=[curArrayUser objectAtIndex:indexPath.row];
    
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
    NSString *sSelectKanBan=[NSString stringWithFormat:@"%@>%@",cClassLookBoardTypeData.sLookBoardTypeName,[dictData objectForKey:@"LookBoardName"]];
    
    [createTaskInKanBanView displaySelectedLookBoard:[dictData objectForKey:@"LookBoardID"] sLookBoardName:sSelectKanBan];
    [self.navigationController popToViewController:createTaskInKanBanView animated:YES];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *curArrayUser=[_arrayLookBoard objectAtIndex:indexPath.section];
    NSDictionary *dictData=[curArrayUser objectAtIndex:indexPath.row];
    TbCellTaskKanBan *cCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellTaskKanBan"];
    
    NSString *sLookBoardName=[dictData objectForKey:@"LookBoardName"];

    cCell.lblKanBanName.text=sLookBoardName;
    
    [cCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cCell;
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
        NSArray *arrayRow=[_arrayLookBoard objectAtIndex:section];
        return arrayRow.count;
    }
}

@end
