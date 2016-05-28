//
//  UIViewControllerFirstAd.m
//  ttbrz
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 Fabius's Studio. All rights reserved.
//

#import "UIViewControllerFirstAd.h"

#define KCurrentPageIndicatorTintColor [UIColor colorWithRed:1.0f/255.0f green:159.0f/255.0f blue:210.0f/255.0f alpha:1.0]
#define KPageIndicatorTintColor        [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0]

@interface UIViewControllerFirstAd ()<UIScrollViewDelegate>{

    int _iScrlW,_iScrlH;
    BOOL _bDidLayoutSubviews;
    NSArray *_adAarray;
    IBOutlet UIScrollView *_scrollViewAdImage;
    IBOutlet UIPageControl *_adPageControl;
}

@end

@implementation UIViewControllerFirstAd

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _adAarray=[[NSArray alloc] initWithObjects:@"ad1",@"ad2",@"ad3",@"ad4", nil];
    
    
    _scrollViewAdImage.bounces=NO;
    _scrollViewAdImage.scrollEnabled=YES;
    _scrollViewAdImage.pagingEnabled=YES;
    _scrollViewAdImage.showsHorizontalScrollIndicator=NO;
    _scrollViewAdImage.showsVerticalScrollIndicator=NO;
    _scrollViewAdImage.delegate=self;
   
    _adPageControl.numberOfPages=_adAarray.count;
    _adPageControl.currentPageIndicatorTintColor = KCurrentPageIndicatorTintColor;
    _adPageControl.pageIndicatorTintColor =KPageIndicatorTintColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    
    if (!_bDidLayoutSubviews) {
        _bDidLayoutSubviews=YES;
        
        _iScrlW=CGRectGetWidth(_scrollViewAdImage.frame);
        _iScrlH=CGRectGetHeight(_scrollViewAdImage.frame);
        _scrollViewAdImage.contentSize=CGSizeMake(_adAarray.count*_iScrlW, _iScrlH);
        
        for (int i=0; i<=_adAarray.count-1; i++) {
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(_iScrlW*i, 0,_iScrlW, _iScrlH)];
            img.image=[UIImage imageNamed:[_adAarray objectAtIndex:i]];
            img.contentMode=UIViewContentModeScaleAspectFill;
            [_scrollViewAdImage addSubview:img];
            
            //完成按钮
            if (i==_adAarray.count-1) {
                //完成按钮
                NSInteger btnFinishW,btnFinishH,btnFinishBottomH;
                btnFinishW=150;
                btnFinishH=35;
                btnFinishBottomH=80;
                UIButton *btnFinish=[[UIButton alloc] initWithFrame:CGRectMake(_iScrlW*i+(_iScrlW-btnFinishW)/2, _iScrlH-btnFinishH-btnFinishBottomH, btnFinishW,btnFinishH)];
                [btnFinish setTitle:@"立即体验" forState:UIControlStateNormal];
                [btnFinish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnFinish addTarget:self action:@selector(didFinishAd) forControlEvents:UIControlEventTouchUpInside];
                btnFinish.titleLabel.font=[UIFont systemFontOfSize:18];
                btnFinish.backgroundColor=KCurrentPageIndicatorTintColor;
                btnFinish.layer.cornerRadius =5.0;
                [_scrollViewAdImage addSubview:btnFinish];
            }
        }
    }
}

//Scrol划动事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新UIPageControl的当前页
    [_adPageControl setCurrentPage:scrollView.contentOffset.x/_iScrlW];
}

- (void)didFinishAd{
    if (self.bFromAbout) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.delegate didFirstAdFinished];
    }
}

@end
