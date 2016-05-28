//
//  ViewControllerLogEvaluation.m
//  ttbrz
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "ViewControllerLogEvaluation.h"

#define KFontColor [UIColor darkGrayColor]
#define KDayTimeTag  100

#define KTxtDetailCommentTag 201
#define KTxtFreeCommentTag 202

@interface ViewControllerLogEvaluation ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate>{
    NSInteger iViewH,iViewW;
    float fScore;
    UILabel *scoreValueLabel;
    UITextField *txtScore;
    NSInteger iCurIndex;
    NSString *sCurValue;
    UIView *evaluationItemView;
    UITableView *tbView;
    UITextView *txtComment;
    NSString *sLogEvaluationItem;//考评审核的考评项
    BOOL bDetailEvaluation;//标记是明细考评还是自由考评
}

@end

@implementation ViewControllerLogEvaluation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    lblTitle.text=@"日志考评";
    lblTitle.textAlignment=NSTextAlignmentCenter;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=lblTitle;
    
    iViewW=CGRectGetWidth(self.view.frame);
    iViewH=CGRectGetHeight(self.view.frame);
    
    //保存
    UIButton *btnSaveEvaluation=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,45,35)];
    btnSaveEvaluation.titleLabel.font=[UIFont systemFontOfSize:16];
    btnSaveEvaluation.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [btnSaveEvaluation setTitle:@"保存" forState:UIControlStateNormal];
    [btnSaveEvaluation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSaveEvaluation addTarget:self action:@selector(didBtnSaveEvaluation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SaveEvaluationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSaveEvaluation];
    self.navigationItem.rightBarButtonItem=SaveEvaluationButtonItem;
    
    //点击空白处键盘消失
    /*
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disKeyboard)];
    singleTouch.delegate=self;
    [self.view addGestureRecognizer:singleTouch];
     */
    
    [self initDetailEvaluationView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma-mark 详细评分项
- (void)initDetailEvaluationView{
    
    bDetailEvaluation=YES;
    
    NSInteger iNavItemH=64;
    NSInteger iLeftOrRightTap=15;
    NSInteger iCurViewY=0;
    NSInteger iControlViewH=30;
    NSInteger iTitleLabelW=70;
    NSInteger iTop=20;
    NSInteger iRowGap=10;
    NSInteger iDownCorrorLabelSize=20;
    int i=0;

    if (self.arrayData.count>0) {
        for (NSDictionary *curDict in self.arrayData) {
            NSString *sTitle=[NSString stringWithFormat:@"%@ :",[curDict objectForKey:@"title"]];
            
            NSArray *arrayValue=[curDict objectForKey:@"value"];
            NSString *sValue;
             NSString *sItemTitle;
            if (i==0) {
                //上班时间默认为第二项
                sItemTitle=[[arrayValue objectAtIndex:1] objectForKey:@"title"];
                sValue=[[arrayValue objectAtIndex:1] objectForKey:@"value"];
            }else{
                sItemTitle=[[arrayValue firstObject] objectForKey:@"title"];
                sValue=[[arrayValue firstObject] objectForKey:@"value"];
            }
           
            //构建控件内容
             iCurViewY=iControlViewH*i+iTop+iNavItemH+iRowGap*i;
            //uiview
            UIView *controlView=[[UIView alloc] initWithFrame:CGRectMake(iLeftOrRightTap,iCurViewY, iViewW-iLeftOrRightTap*2, iControlViewH)];
            [self.view addSubview:controlView];
            
            //title label
            UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iTitleLabelW,iControlViewH)];
            titleLabel.text=sTitle;
            titleLabel.font=[UIFont systemFontOfSize:15];
            titleLabel.textColor=KFontColor;
            [controlView addSubview:titleLabel];
            
            //buttonuiview
            UIView *btnControlView=[[UIView alloc] initWithFrame:CGRectMake(iTitleLabelW,0, iViewW-iLeftOrRightTap*2-iTitleLabelW, iControlViewH)];
            btnControlView.backgroundColor=[UIColor groupTableViewBackgroundColor];
            [controlView addSubview:btnControlView];
            
            //点击event
            UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)];
            singleTouch.accessibilityLabel=[NSString stringWithFormat:@"%d",i];
            [btnControlView addGestureRecognizer:singleTouch];

            
            //downcorrorLable
            UILabel *downCorrorLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(btnControlView.frame)-iDownCorrorLabelSize, 0, iDownCorrorLabelSize,iControlViewH)];
            downCorrorLabel.text=@"\u25BE";
            downCorrorLabel.font=[UIFont systemFontOfSize:15];
            downCorrorLabel.textColor=KFontColor;
            [btnControlView addSubview:downCorrorLabel];
            
            //valueLabel
            UILabel *valueLabel=[[UILabel alloc] initWithFrame:CGRectMake(iLeftOrRightTap, 0, CGRectGetWidth(btnControlView.frame)-iDownCorrorLabelSize-iLeftOrRightTap,iControlViewH)];
            valueLabel.text=sItemTitle;
            valueLabel.accessibilityLabel=sValue;
            valueLabel.tag=KDayTimeTag+i;
            valueLabel.font=[UIFont systemFontOfSize:15];
            valueLabel.textColor=KFontColor;
            
            valueLabel.backgroundColor=[UIColor clearColor];
            [btnControlView addSubview:valueLabel];
            
            i++;
        }
        
        iCurViewY=iControlViewH+iCurViewY+iRowGap;
        NSInteger iScoreFreeScoreLabelW=65;
        NSInteger iScoreFreeScoreButtonSize=20;
        //考评积分
        //uiview
        UIView *scoreView=[[UIView alloc] initWithFrame:CGRectMake(iLeftOrRightTap,iCurViewY, iViewW-iLeftOrRightTap*2, iControlViewH)];
        [self.view addSubview:scoreView];
        
        UILabel *scoreTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iTitleLabelW,iControlViewH)];
        scoreTitleLabel.text=@"考评积分 :";
        scoreTitleLabel.font=[UIFont systemFontOfSize:15];
        scoreTitleLabel.textColor=KFontColor;
        [scoreView addSubview:scoreTitleLabel];
        
        //自由评分
        UILabel *scoreFreeScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(iViewW-iLeftOrRightTap*2-iScoreFreeScoreLabelW, 0, iScoreFreeScoreLabelW,iControlViewH)];
        scoreFreeScoreLabel.text=@"自由评分";
        scoreFreeScoreLabel.font=[UIFont systemFontOfSize:15];
        scoreFreeScoreLabel.textColor=KFontColor;
        [scoreView addSubview:scoreFreeScoreLabel];
        
        //切换自由评分 详细评分
        UIButton *btnScoreFree=[[UIButton alloc] initWithFrame:CGRectMake(iViewW-iLeftOrRightTap*2-iScoreFreeScoreLabelW-iScoreFreeScoreButtonSize, (iControlViewH-iScoreFreeScoreButtonSize)/2, iScoreFreeScoreButtonSize, iScoreFreeScoreButtonSize)];
        btnScoreFree.accessibilityLabel=@"detail";
        [btnScoreFree addTarget:self action:@selector(didBtnChangeFreeOrDetail:) forControlEvents:UIControlEventTouchUpInside];
        [scoreView addSubview:btnScoreFree];
        [btnScoreFree setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
        
        scoreValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(iTitleLabelW, 0, iViewW-iLeftOrRightTap*2-iTitleLabelW-iScoreFreeScoreButtonSize-iScoreFreeScoreLabelW,iControlViewH)];
        scoreValueLabel.font=[UIFont systemFontOfSize:15];
        scoreValueLabel.textColor=[UIColor redColor];
        [scoreView addSubview:scoreValueLabel];
        
        
        //填写评语
        iCurViewY=iControlViewH+iCurViewY+iRowGap;
        UILabel *lblCommentTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftOrRightTap, iCurViewY, iTitleLabelW,iControlViewH)];
        lblCommentTitle.text=@"填写评语 :";
        lblCommentTitle.font=[UIFont systemFontOfSize:15];
        lblCommentTitle.textColor=KFontColor;
        [self.view addSubview:lblCommentTitle];
        
        //评语内容
        iCurViewY=iControlViewH+iCurViewY;
        NSInteger iCommentTxtH=80;
        txtComment=[[UITextView alloc] initWithFrame:CGRectMake(iLeftOrRightTap,iCurViewY,iViewW-iLeftOrRightTap*2,iCommentTxtH)];
        txtComment.textColor=[UIColor lightGrayColor];
        txtComment.text=@"";
        txtComment.tag=KTxtDetailCommentTag;
        txtComment.font=[UIFont systemFontOfSize:15];
        txtComment.backgroundColor=[UIColor whiteColor];
        txtComment.layer.borderWidth=1.0;
        txtComment.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        txtComment.keyboardType=UIKeyboardTypeDefault;
        txtComment.delegate=self;
        [self.view addSubview:txtComment];
        
    }
    [self updateScore];

}

#pragma-mark 自由评分
- (void)initFreeEvaluationView{
    
    bDetailEvaluation=NO;
    
    NSInteger iNavItemH=64;
    NSInteger iLeftOrRightTap=15;
    NSInteger iCurViewY=0;
    NSInteger iControlViewH=30;
    NSInteger iTitleLabelW=70;
    NSInteger iRowGap=10;
    NSInteger iScoreFreeScoreLabelW=65;
    NSInteger iScoreFreeScoreButtonSize=20;
    
     iCurViewY=iNavItemH+iRowGap;
    
    //考评积分
    //uiview
    UIView *scoreView=[[UIView alloc] initWithFrame:CGRectMake(iLeftOrRightTap,iCurViewY, iViewW-iLeftOrRightTap*2, iControlViewH)];
    [self.view addSubview:scoreView];
    
    UILabel *scoreTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, iTitleLabelW,iControlViewH)];
    scoreTitleLabel.text=@"考评积分 :";
    scoreTitleLabel.font=[UIFont systemFontOfSize:15];
    scoreTitleLabel.textColor=KFontColor;
    [scoreView addSubview:scoreTitleLabel];
    
    //自由评分
    UILabel *scoreFreeScoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(iViewW-iLeftOrRightTap*2-iScoreFreeScoreLabelW, 0, iScoreFreeScoreLabelW,iControlViewH)];
    scoreFreeScoreLabel.text=@"分项评分";
    scoreFreeScoreLabel.font=[UIFont systemFontOfSize:15];
    scoreFreeScoreLabel.textColor=KFontColor;
    [scoreView addSubview:scoreFreeScoreLabel];
    
    //切换自由评分 详细评分
    UIButton *btnScoreFree=[[UIButton alloc] initWithFrame:CGRectMake(iViewW-iLeftOrRightTap*2-iScoreFreeScoreLabelW-iScoreFreeScoreButtonSize, (iControlViewH-iScoreFreeScoreButtonSize)/2, iScoreFreeScoreButtonSize, iScoreFreeScoreButtonSize)];
    btnScoreFree.accessibilityLabel=@"free";
    [btnScoreFree addTarget:self action:@selector(didBtnChangeFreeOrDetail:) forControlEvents:UIControlEventTouchUpInside];
    [scoreView addSubview:btnScoreFree];
    [btnScoreFree setBackgroundImage:[UIImage imageNamed:@"logAssess_unSelected.png"] forState:UIControlStateNormal];
    
    txtScore=[[UITextField alloc] initWithFrame:CGRectMake(iTitleLabelW, 0, iViewW-iLeftOrRightTap*2-iTitleLabelW-iScoreFreeScoreButtonSize-iScoreFreeScoreLabelW-iRowGap,iControlViewH)];
    txtScore.font=[UIFont systemFontOfSize:15];
    txtScore.layer.borderWidth=1.0;
    txtScore.keyboardType=UIKeyboardTypeNamePhonePad;
    txtScore.delegate=self;
    txtScore.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    txtScore.textColor=[UIColor redColor];
    [scoreView addSubview:txtScore];
    
    //填写评语
    iCurViewY=iControlViewH+iCurViewY+iRowGap;
    UILabel *lblCommentTitle=[[UILabel alloc] initWithFrame:CGRectMake(iLeftOrRightTap, iCurViewY, iTitleLabelW,iControlViewH)];
    lblCommentTitle.text=@"填写评语 :";
    lblCommentTitle.font=[UIFont systemFontOfSize:15];
    lblCommentTitle.textColor=KFontColor;
    [self.view addSubview:lblCommentTitle];
    
    //评语内容
    iCurViewY=iControlViewH+iCurViewY;
    NSInteger iCommentTxtH=iViewH-iControlViewH*3-iRowGap*2-iNavItemH;
    txtComment=[[UITextView alloc] initWithFrame:CGRectMake(iLeftOrRightTap,iCurViewY,iViewW-iLeftOrRightTap*2,iCommentTxtH)];
    txtComment.textColor=[UIColor lightGrayColor];
    txtComment.text=@"";
    txtComment.tag=KTxtFreeCommentTag;
    txtComment.font=[UIFont systemFontOfSize:15];
    txtComment.backgroundColor=[UIColor whiteColor];
    txtComment.layer.borderWidth=1.0;
    txtComment.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    txtComment.keyboardType=UIKeyboardTypeDefault;
    txtComment.delegate=self;
    [self.view addSubview:txtComment];

}

#pragma-mark 切换自由评分 详细评分
- (void)didBtnChangeFreeOrDetail:(id)sender{
    UIButton *btnObj=sender;
    
    //新除旧控
    for (UIView *subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    if ([btnObj.accessibilityLabel isEqualToString:@"detail"]) {
        [self initFreeEvaluationView];
        btnObj.accessibilityLabel=@"free";
    }else{
        [self initDetailEvaluationView];
        btnObj.accessibilityLabel=@"detail";
    
    }
}

#pragma-mark 保存考评
- (void)didBtnSaveEvaluation{
    
    if (bDetailEvaluation) {
        for (int i=0; i<=self.arrayData.count-1; i++) {
            NSString *sTitle=[[self.arrayData objectAtIndex:i] objectForKey:@"title"];
            NSString *sValue=((UILabel*)[self.view viewWithTag:KDayTimeTag+i]).text;
            
            if (i==0) {
                sLogEvaluationItem=[NSString stringWithFormat:@"%@:%@",sTitle,sValue];
            }else{
                sLogEvaluationItem=[NSString stringWithFormat:@"%@|%@:%@",sLogEvaluationItem,sTitle,sValue];
            }
        }
        //最后的考评积分
        sLogEvaluationItem=[NSString stringWithFormat:@"%@|%@%0.0f分",sLogEvaluationItem,@"考评积分:",fScore];
    }else{
        sLogEvaluationItem=@"";
        
        if ([txtScore.text isEqualToString:@""]) {
            [PublicFunc ShowNoticeHUD:@"请输入考评积分" view:self.view];
            return;
        }
    }
    
    [ClassLog checkEmployeesLogWithSelectType:self.getLogEvaluationType strSelectDate:self.sGetSelectDate LogID:self.sGetLogID UserID:[SystemPlist GetUserID] CompanyID:[SystemPlist GetCompanyID] Num:[NSString stringWithFormat:@"%0.0f",fScore] strYSPY:txtComment.text strLogEvaluationItem:sLogEvaluationItem fatherObject:self returnBlock:^(BOOL bReturn, NSDictionary *returnDictionary) {
        if (bReturn) {
            [PublicFunc ShowSuccessHUD:@"考评成功" view:self.view];
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.0];
        }
    }];
}

-(void)dismissView{
    UITabBarController *rootTabBarView =[self.navigationController.viewControllers firstObject];
    UIViewControllerLogAssess *logAssessView=[rootTabBarView.viewControllers objectAtIndex:0];
    [logAssessView updateConfirmNum];
    [logAssessView loadingData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma-mark Uitextfiled事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma-mark Uitextfiled事件
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    float fHeight=0.0;
    if (textView.tag==KTxtDetailCommentTag) {
        fHeight=-160;
    }else{
        fHeight=-10;
    }
    
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移100个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,fHeight,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}


//键盘消失事件
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//更新积分
- (void)updateScore{
    
    //上班时间 分数
    NSInteger  iDayTimeScore =[((UILabel*)[self.view viewWithTag:KDayTimeTag]).accessibilityLabel floatValue];
    NSInteger iEvaluationScore=0;
    
    for (int i=1; i<=self.arrayData.count-2; i++) {
        iEvaluationScore=iEvaluationScore+[((UILabel*)[self.view viewWithTag:KDayTimeTag+i]).accessibilityLabel integerValue];
    }
    //奖励分
    NSInteger iAwardScore=[((UILabel*)[self.view viewWithTag:KDayTimeTag+self.arrayData.count-1]).accessibilityLabel integerValue];;
    
    fScore=iDayTimeScore*(iEvaluationScore*0.01)+iAwardScore;
    
    NSString *sDayTimeScore=[NSString stringWithFormat:@"%ld",(long)iDayTimeScore];
    NSString *sEvaluationScore=[NSString stringWithFormat:@"%ld%%",(long)iEvaluationScore];
    NSString *sAwardScore=[NSString stringWithFormat:@"%ld",(long)iAwardScore];
    
    scoreValueLabel.text=[NSString stringWithFormat:@"%@×%@+%@=%1.1f",sDayTimeScore,sEvaluationScore,sAwardScore,fScore];
    //得分评语
    txtComment.text=@"";
    NSString *sComment;
    if (iEvaluationScore<60) {
        sComment=[[self.arrayCommentTemplate objectAtIndex:4] objectForKey:@"Comment"];
    }else if (iEvaluationScore<80 && iEvaluationScore>=61){
        sComment=[[self.arrayCommentTemplate objectAtIndex:3] objectForKey:@"Comment"];
    }else if (iEvaluationScore<90 && iEvaluationScore>=80){
        sComment=[[self.arrayCommentTemplate objectAtIndex:2] objectForKey:@"Comment"];
    }else if (iEvaluationScore<100 && iEvaluationScore>=90){
        sComment=[[self.arrayCommentTemplate objectAtIndex:1] objectForKey:@"Comment"];
    }else if (iEvaluationScore==100){
        sComment=[[self.arrayCommentTemplate objectAtIndex:0] objectForKey:@"Comment"];
    }
    txtComment.text=sComment;
    
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//
//    if([touch.view isKindOfClass:[UITableViewCell class]]){
//        return NO;
//    }else
//        return YES;
//}


#pragma mark 选中某项
- (void)didSelectView:(id)sender{
    
    UITapGestureRecognizer *curObject=sender;
    iCurIndex=[curObject.accessibilityLabel intValue];
    sCurValue=((UILabel*)[self.view viewWithTag:KDayTimeTag+iCurIndex]).accessibilityLabel;
    
    NSArray *arrayValue=[[self.arrayData objectAtIndex:iCurIndex] objectForKey:@"value"];
    evaluationItemView=[[UIView alloc] initWithFrame:self.view.frame];
    evaluationItemView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    [self.view addSubview:evaluationItemView];
    
    //点击空白关闭
    UIButton *bgButton=[[UIButton alloc] initWithFrame:self.view.frame];
    [bgButton addTarget:self action:@selector(hideEavluationItemView) forControlEvents:UIControlEventTouchUpInside];
    [evaluationItemView addSubview:bgButton];
    
    NSInteger iGap=15;
    NSInteger iRowHeight=35;
    NSInteger iTableViewHeight=iRowHeight*arrayValue.count;
    
    //主内容
    tbView= [[UITableView alloc] initWithFrame:CGRectMake(iGap, (CGRectGetHeight(evaluationItemView.frame)-iTableViewHeight)/2, CGRectGetWidth(evaluationItemView.frame)-iGap*2, iTableViewHeight) style:UITableViewStylePlain];
    tbView.delegate = self;
    tbView.dataSource = self;
    tbView.alwaysBounceHorizontal = NO;
    tbView.alwaysBounceVertical = NO;
    tbView.showsHorizontalScrollIndicator = NO;
    tbView.showsVerticalScrollIndicator = NO;
    tbView.scrollEnabled = NO;
    tbView.backgroundColor = [UIColor clearColor];
    tbView.rowHeight=iRowHeight;
    [evaluationItemView addSubview:tbView];
    
    //去掉左边的空白
    if ([tbView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tbView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([tbView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tbView setSeparatorInset:UIEdgeInsetsZero];
    }

    
    [self.view addSubview:evaluationItemView];
   
}

#pragma mark 关闭 EvaluationItemview
- (void)hideEavluationItemView{
    [evaluationItemView removeFromSuperview];
}


#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSArray *arrayValue=[[self.arrayData objectAtIndex:iCurIndex] objectForKey:@"value"];
    return arrayValue.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = @"cell";
     NSArray *arrayValue=[[self.arrayData objectAtIndex:iCurIndex] objectForKey:@"value"];
    NSDictionary *curDict=[arrayValue objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundView = [[UIView alloc] init];
    
     if ([curDict objectForKey:@"value"] ==sCurValue) {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [curDict objectForKey:@"title"];

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *arrayValue=[[self.arrayData objectAtIndex:iCurIndex] objectForKey:@"value"];
    NSDictionary *curDict=[arrayValue objectAtIndex:indexPath.row];
    ((UILabel*)[self.view viewWithTag:KDayTimeTag+iCurIndex]).text=[curDict objectForKey:@"title"];
    ((UILabel*)[self.view viewWithTag:KDayTimeTag+iCurIndex]).accessibilityLabel=[curDict objectForKey:@"value"];
    
    [self hideEavluationItemView];
    [self updateScore];
}

//去掉左边的空白
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark 所有txtfield的键盘消失
-(void)disKeyboard{
    [txtComment resignFirstResponder];
    [txtScore resignFirstResponder];
}


@end
