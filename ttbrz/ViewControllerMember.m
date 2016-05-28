//
//  ViewControllerMember.m
//  ttbrz
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ViewControllerMember.h"


@interface ViewControllerMember ()<UITableViewDataSource,UITableViewDelegate>{

    IBOutlet UITableView *_tbMemberView;
    IBOutlet NSLayoutConstraint *_tbLayoutBottom;
    
    float _itbViewH;
    float _fRowDataH;
    BOOL _bDidLayoutSubviews;
}

@end

@implementation ViewControllerMember

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"其它人员";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    //注册cell
    UINib *nibCell=[UINib nibWithNibName:@"TbCellMember" bundle:nil];
    [_tbMemberView registerNib:nibCell forCellReuseIdentifier:@"TbCellMember"];
    
    TbCellMember*cell=[_tbMemberView dequeueReusableCellWithIdentifier:@"TbCellMember"];
    _tbMemberView.rowHeight=CGRectGetHeight(cell.frame);
    _fRowDataH=CGRectGetHeight(cell.frame);
    
    //去掉左边的空白
    if ([_tbMemberView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tbMemberView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    if ([_tbMemberView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tbMemberView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 动态改变tb的bottom约束
-(void)setTbBottomConstant{
    if (self.arrayMemberData.count>0) {
        int iCurTbHeight=self.arrayMemberData.count*_fRowDataH;
        if (iCurTbHeight>_itbViewH) {
            _tbLayoutBottom.constant=0.0;
            _tbMemberView.scrollEnabled=YES;
        }else{
            _tbLayoutBottom.constant=_itbViewH-iCurTbHeight;
            _tbMemberView.scrollEnabled=NO;
        }
    }
}

-(void)viewDidLayoutSubviews{
    //根据arryActionJoinor来计算tbview的高度
    if (!_bDidLayoutSubviews) {
        _bDidLayoutSubviews=YES;
        _itbViewH=CGRectGetHeight(_tbMemberView.frame);
        [self setTbBottomConstant];
    }
}

#pragma mark tableviewdelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictData=[self.arrayMemberData objectAtIndex:indexPath.row];
    
    TbCellMember *memberCell=[tableView dequeueReusableCellWithIdentifier:@"TbCellMember"];
    
    //头像，如果头像为空，就用名字的最后一个字符代替
    NSString *sMemberName=[dictData objectForKey:@"UserName"];
    NSString *sUserPhoto=[dictData objectForKey:@"vchrPhoto"];
    
    if ([sUserPhoto isEqualToString:@""]) {
        memberCell.lblMemberMark.text=[sMemberName substringFromIndex:sMemberName.length-1];
        memberCell.lblMemberMark.hidden=NO;
        
        memberCell.imageMemberIcon.hidden=YES;
        memberCell.imageMemberIcon.image=nil;
    }else{
        memberCell.lblMemberMark.hidden=YES;
        
        NSData *photoData = [[NSData alloc] initWithBase64EncodedString:sUserPhoto options:0];
        memberCell.imageMemberIcon.hidden=NO;
        memberCell.imageMemberIcon.image=[UIImage imageWithData:photoData];
    }

    
    memberCell.lblTeamMemberName.text=sMemberName;
    
    [memberCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return memberCell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayMemberData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIViewControllerColleagueDetailLog *colleagueDetailLogView =[self.navigationController.viewControllers objectAtIndex:1];
    
    NSDictionary *dictData=[self.arrayMemberData objectAtIndex:indexPath.row];
    [colleagueDetailLogView selectedMemberID:[dictData objectForKey:@"UserID"] sMemberName:[dictData objectForKey:@"UserName"]];
    
    [self.navigationController popToViewController:colleagueDetailLogView animated:YES];
    
}


//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    
}

@end
