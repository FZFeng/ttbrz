//
//  PublicFunc.m
//  iSaleApp
//
//  Created by apple on 14-5-14.
//  Copyright (c) 2014年 Fabius-Studio. All rights reserved.
//

#import "PublicFunc.h"

@implementation PublicFunc

#define plistName  @"SystemInfo.plist"
#define sSuccess             @"操作成功"
#define sFailed              @"操作失败"

#define kCompressionQuality 0.4
#define kSmallCompressionQuality 0.1
#define iNewSize 1024
#define iSmallSize 512
#define iSmallImageMaxSize 30

+(PublicFunc*)shared{
    static dispatch_once_t once = 0;
	static PublicFunc *PublicFuncObj;
	dispatch_once(&once, ^{ PublicFuncObj = [[PublicFunc alloc] init]; });
	return PublicFuncObj;
}


#pragma-mark UIAlertController
//简单提示框
+(void)ShowSimpleMsg:(NSString *)pMsg{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:pMsg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma-mark MBProgressHUD简单提示框

//简单MBProgressHUD提示
+(void)ShowSimpleHUD:(NSString*)pMsg view:(UIView*)pView{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:pView animated:YES];
    hud.minSize=CGSizeMake(200, 35);
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = pMsg;
    hud.margin = 15.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

//成功MBProgressHUD提示
+(void)ShowSuccessHUD:(NSString*)pMsg view:(UIView*)pView{
    
[[PublicFunc shared] ShowHUD:showHUDSuccess sMsg:pMsg view:pView];}

//错误MBProgressHUD提示
+(void)ShowErrorHUD:(NSString*)pMsg view:(UIView*)pView{

   [[PublicFunc shared] ShowHUD:showHUDError sMsg:pMsg view:pView];
}

//注意MBProgressHUD提示
+(void)ShowNoticeHUD:(NSString*)pMsg view:(UIView*)pView{
    [[PublicFunc shared] ShowHUD:showHUDNotice sMsg:pMsg view:pView];
}

//等待提示,并返回hud 对象用于关闭
+(id)ShowWaittingHUD:(NSString*)pMsg view:(UIView*)pView{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:pView animated:YES];
    MBSpinningCircle *_activityIndicator = [MBSpinningCircle circleWithSize:NSSpinningCircleSizeLarge color:[UIColor colorWithRed:50.0/255.0 green:155.0/255.0 blue:255.0/255.0 alpha:1.0]];
    CGRect circleRect = _activityIndicator.frame;
    circleRect.origin = CGPointMake(pView.bounds.size.width/2.0 - circleRect.size.width/2.0, -5);
    circleRect.origin = CGPointMake(30,30);
    
    _activityIndicator.circleSize = NSSpinningCircleSizeLarge;
    _activityIndicator.hasGlow = YES;
    _activityIndicator.isAnimating = YES;
    _activityIndicator.speed = 0.35;
    
    hud.customView=_activityIndicator;
    
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = pMsg;
    hud.margin = 15.f;
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}


/**
 *  根据itype显示hub
 *
 *  @param iType 1:成功 2:失败 3:注意
 *  @param pMsg  提示内容
 *  @param pView 父view对像
 */
-(void)ShowHUD:(enum showHUDType)iType sMsg:(NSString*)pMsg view:(UIView*)pView{
    
    NSString *sImageName=@"";
    NSString *sDefaultMsg=@"";
    
    switch (iType) {
        case showHUDSuccess:{
            sImageName=@"success.png";
            sDefaultMsg=sSuccess;
            break;
        }case showHUDError:{
            sImageName=@"error.png";
            sDefaultMsg=sFailed;
            break;
        }case showHUDNotice:{
            sImageName=@"notice.png";
            break;
        }
        default:
            break;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:pView animated:YES];
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:sImageName]];
    [image setFrame:CGRectMake(0, 0, 30, 30)];
    hud.customView = image;
    [hud hide:YES afterDelay:1.5];
   
    // Set custom view mode
    hud.mode = MBProgressHUDModeCustomView;
    
    if (pMsg.length>0) {
        hud.labelText=pMsg;
    }else{
        hud.labelText=sDefaultMsg;
    }
    
    hud.margin = 15.f;
    hud.removeFromSuperViewOnHide = YES;
}
+(void)HideHUD:(id)pHUD{
    MBProgressHUD *objectId=pHUD;
    [objectId hide:YES];
}

#pragma-mark清除图片缓存
+(void)ClearImgCache{
    
    //确定图片的缓存地址
    NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *docDir=[path objectAtIndex:0];
    NSString *tmpPath=[docDir stringByAppendingPathComponent:@"AsynImage"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:tmpPath error:nil];
}

#pragma-mark 根据给出的开始日期,返回未来iDateNum天的日期,包括今日期 格式(2014-05-29 星期四)
+(NSMutableArray*)ReturnDate:(NSString*)sStartDate iDateNum:(int)piDateNum{
    NSMutableArray *arryResult=[[NSMutableArray alloc] init];
    
    for (int i=0; i<=piDateNum; i++) {
        NSString *curDate;
        //将nsstring的日期转成nsdate的日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *startDate=[formatter dateFromString:sStartDate];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];//时区
        NSInteger interval = [zone secondsFromGMTForDate: startDate];
        startDate=[startDate dateByAddingTimeInterval:interval];
        
        NSTimeInterval secondsPerDay = (24*60*60)*i;
        NSDate *tomorrow = [NSDate dateWithTimeInterval:secondsPerDay sinceDate:startDate];
        
        curDate=[formatter stringFromDate:tomorrow];
        curDate=[curDate stringByAppendingString:[NSString stringWithFormat:@" %@",[[self shared] ReturnWeek:curDate]]];
        
        [arryResult addObject:curDate];
    }
    return arryResult;
}

#pragma mark 返回指定日期的星期
+ (NSString*)returnWeekDateWithDate:(NSString*)sDate{
    return [[self shared] ReturnWeek:sDate];
}

//根据日期返回周期几
-(NSString*)ReturnWeek:(NSString*)sDate{
    NSString *weekStr;
    
    //时间格式 2014-06-01
    NSArray *arryDate=[sDate componentsSeparatedByString:@"-"];
    int iYear=[[arryDate objectAtIndex:0] intValue];
    int iMonth=[[arryDate objectAtIndex:1] intValue];
    int iDay=[[arryDate objectAtIndex:2] intValue];
    
    int week=[self getWeekWithYear:iYear andMonth:iMonth andDay:iDay];
    
    if(week==1)
    {
        weekStr=@"周一";
    }else if(week==2){
        weekStr=@"周二";
        
    }else if(week==3){
        weekStr=@"周三";
        
    }else if(week==4){
        weekStr=@"周四";
        
    }else if(week==5){
        weekStr=@"周五";
        
    }else if(week==6){
        weekStr=@"周六";
        
    }else if(week==0){
        weekStr=@"周日";
    }
    else {
        NSLog(@"error!");
    }
    
    return weekStr;
}


-(int)getWeekWithYear:(int)year andMonth:(int)month andDay:(int)day{
    int week = 0;
    int (*arr)[] = [self getNewMonth:month andYear:year];
    week = day+2*(*arr)[0]+3*((*arr)[0]+1)/5+(*arr)[1]+(*arr)[1]/4-(*arr)[1]/100+(*arr)[1]/400+1;
    free(*arr);
    return abs(week)%7;
}

-(int(*)[])getNewMonth:(int)mon andYear:(int)ye{
    int newmon = 0;
    int newyear = ye;
    if (mon>=3 && mon<=12) {
        newmon = mon;
    }else if(mon == 1){
        newmon = 13;
        newyear = ye-1;
    }else if(mon == 2){
        newmon = 14;
        newyear = ye-1;
    }
    int (*parr)[] = (int (*)[])malloc(2*sizeof(int));
    (*parr)[0] = newmon;
    (*parr)[1] = newyear;
    return parr;
}

//返回报餐数据(显示的格式)
//例: 第一行数据为 date:{5月5日 星期三} info:{[食堂1:早餐,中餐],[食堂2:晚餐] canteen:{食堂1,食堂2}
+(NSMutableArray*)ReturnDailyMealFormatData:(NSArray *)pArryDailyMealDate arryResDate:(NSArray *)pArryResDate arryCanteen:(NSArray *)pArryCanteen arryMealTime:(NSArray *)pArryMealTime{
    
    NSMutableArray *arryDisplay=[[NSMutableArray alloc] init];
    for (NSString * curDate in pArryResDate) {
        
        BOOL bFlag=NO;
        NSString *sDate=[[curDate componentsSeparatedByString:@" "] objectAtIndex:0];
        
        NSMutableDictionary *dictInfo=[[NSMutableDictionary alloc] init];
        NSString *sCanteen=@"";
        
        for (NSDictionary *dictDetail in pArryDailyMealDate) {
            //日期
            NSString *sDetailDate=[dictDetail objectForKey:@"dReportDate"];
            //饭堂名称
            NSString *sDetailCanteen;
            for (NSDictionary *curDictCanteen in pArryCanteen) {
                NSString *curShop_c=[curDictCanteen objectForKey:@"sshop_c"];
                if ([curShop_c isEqualToString:[dictDetail objectForKey:@"sShop_c"]]) {
                    sDetailCanteen=[curDictCanteen objectForKey:@"sshop_n"];
                    break;
                }
            }
            //餐次信息
            NSString *sDetailResult=[dictDetail objectForKey:@"sReportResult"];
            
            if ([sDetailDate isEqualToString:sDate]) {
                bFlag=YES;
                
                //饭堂
                if ([sCanteen isEqualToString:@""]) {
                    sCanteen=sDetailCanteen;
                }else{
                    sCanteen=[NSString stringWithFormat:@"%@,%@",sCanteen,sDetailCanteen];
                }
                
                //餐次
                NSString *sInfo=@"";
                for (int i=0; i<=sDetailResult.length-1; i++) {
                    NSString *str=[sDetailResult substringWithRange:NSMakeRange(i, 1)];
                    if ([str isEqualToString:@"1"]) {
                        //餐次
                        NSDictionary *dictMealTime=[pArryMealTime objectAtIndex:i];
                        NSString *sTrade_n=[dictMealTime objectForKey:@"sTrade_n"];
                        
                        if ([sInfo isEqualToString:@""]) {
                            sInfo=sTrade_n;
                        }else{
                            sInfo=[NSString stringWithFormat:@"%@,%@",sInfo,sTrade_n];
                        }
                    }
                }
                [dictInfo setObject:sInfo forKey:sDetailCanteen];
                
            }
        }
        
        if (bFlag) {
            NSMutableDictionary *dictDisplay=[[NSMutableDictionary alloc] init];
            //date
            [dictDisplay setObject:curDate forKey:@"date"];
            //info
            [dictDisplay setObject:dictInfo forKey:@"info"];
            //canteen
            [dictDisplay setObject:sCanteen forKey:@"canteen"];
            
            [arryDisplay addObject:dictDisplay];
        }
    }
    return arryDisplay;

}

//通过键值获取沙箱plist文件中的值
//pID:键值
+(NSString*)GetPlistValue:(NSString*)pID{
    
    NSMutableDictionary *dictionaryPlist;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *realPlistPath=[documentPath stringByAppendingPathComponent:plistName];
    dictionaryPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:realPlistPath];

    return [dictionaryPlist objectForKey:pID];
}

//通过键值设置沙箱plist文件中的值
//pID:键值 pValue 值
+(void)SetPlistValue:(NSString*)pID value:(NSString*)pValue{
    
    //设置密码
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *realPlistPath=[documentPath stringByAppendingPathComponent:plistName];
    NSMutableDictionary *dictionaryPlist;
    dictionaryPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:realPlistPath];
    
    [dictionaryPlist setObject:pValue forKey:pID];
    
    //保存
    [dictionaryPlist writeToFile:realPlistPath atomically:YES];
}

//获取沙箱地址
+(NSString*)GetSandBoxPathWithType:(SandBoxPathType)SandBoxPathType{

    NSString *sPath=@"";
    switch (SandBoxPathType) {
        case SandBoxPathTypeDocuments:{
            sPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            sPath=[sPath stringByAppendingString:@"/"];
            break;
        }case SandBoxPathTypeTemp:{
            sPath=NSTemporaryDirectory();
            break;
        }case SandBoxPathLibrary:{
            sPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            sPath=[sPath stringByAppendingString:@"/"];
            break;
        }
        default:
            break;
    }
    return sPath;
}

//指定日期与当前日期比较 结果大于0 表示指定日期还在未来时间中
+(float)intervalSinceNow:(NSString *)theDate
{
    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:00:00"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    
    
    NSTimeInterval cha=late-now;
    
    return cha;
    /*
     NSString *timeString=@"";
     if (cha/3600<1) {
     timeString = [NSString stringWithFormat:@"%f", cha/60];
     timeString = [timeString substringToIndex:timeString.length-7];
     timeString=[NSString stringWithFormat:@"剩余%@分", timeString];
     
     }
     if (cha/3600>1&&cha/86400<1) {
     timeString = [NSString stringWithFormat:@"%f", cha/3600];
     timeString = [timeString substringToIndex:timeString.length-7];
     timeString=[NSString stringWithFormat:@"剩余%@小时", timeString];
     }
     if (cha/86400>1)
     {
     timeString = [NSString stringWithFormat:@"%f", cha/86400];
     timeString = [timeString substringToIndex:timeString.length-7];
     timeString=[NSString stringWithFormat:@"剩余%@天", timeString];
     
     }
     
     return timeString;
     */
}

#pragma mark 调整图片的大小(分辨率和大小)
//先调整分辨率，分辨率可以自己设定一个值，大于的就缩小到这分辨率，小余的就保持原本分辨率。然后在根据最终大小来设置压缩比，比如传入maxSize = 100k，最终计算大概这个大小的压缩比。基本上最终出来的图片数据根据当前分辨率能保持差不多的大小同时不至于太模糊，跟微信，微博最终效果应该是差不多的，代码仍然有待优化！

+(NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / iNewSize;
    CGFloat tempWidth = newSize.width / iNewSize;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,kCompressionQuality);
        return finallImageData;
    }
    
    return imageData;
}

+(NSData *)resetSizeOfImageData:(UIImage *)source_image newSourceImageSize:(NSInteger)newSourceImageSize maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / newSourceImageSize;
    CGFloat tempWidth = newSize.width / newSourceImageSize;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,kCompressionQuality);
        return finallImageData;
    }
    
    return imageData;
}

//缩成小图片
+(NSData *)resetSmallImageWithImage:(UIImage *)source_image
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / iSmallSize;
    CGFloat tempWidth = newSize.width / iSmallSize;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > iSmallImageMaxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,kSmallCompressionQuality);
        return finallImageData;
    }
    
    return imageData;
}

#pragma mark 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString*) telNumber
{
    NSString*pattern =@"^1+[3578]+\\d{9}";
    NSPredicate*pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}

#pragma mark 正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark 计算字体高度
+ (float) heightForString:(NSString *)value font:(UIFont*)stringFont andWidth:(float)width
{
    //换行
    //value = [value stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    
    NSDictionary *attribute = @{NSFontAttributeName: stringFont};
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return sizeToFit.height;
}

#pragma mark 计算字体宽度
+ (float) widthForString:(NSString *)value font:(UIFont*)stringFont andWidth:(float)width{

    //换行
    //value = [value stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    
    NSDictionary *attribute = @{NSFontAttributeName: stringFont};
    CGSize sizeToFit = [value boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return sizeToFit.width;
}

#pragma mark 生成GUID值
+ (NSString *)getRandomGUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

+(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}



#pragma mark 字符串日期转日期
+ (NSDate *)dateFromString:(NSString *)dateString dateFormatterType:(DateFromStringType)dateFormatterType{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *sDateFormatter;
    switch (dateFormatterType) {
        case DateFromStringTypeDefault:{
            sDateFormatter=@"yyyy-MM-dd HH:mm:ss";
            break;
        }case DateFromStringTypeYMD:{
            sDateFormatter=@"yyyy-MM-dd";
            break;
        }case DateFromStringTypeOther:{
            break;
        }
    }
    [dateFormatter setDateFormat:sDateFormatter];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    if (dateFormatterType!=DateFromStringTypeDefault) {
        //时区转换，取得系统时区，取得格林威治时间差秒
        NSTimeInterval  timeZoneOffset=[[NSTimeZone systemTimeZone] secondsFromGMT];
        destDate = [destDate dateByAddingTimeInterval:timeZoneOffset];

    }
    
    return destDate;
}

#pragma mark 日期转字符串日期
+ (NSString *)stringFromDate:(NSDate *)date dateFormatterType:(DateFromStringType)dateFormatterType{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *sDateFormatter;
    switch (dateFormatterType) {
        case DateFromStringTypeDefault:{
            sDateFormatter=@"yyyy-MM-dd HH:mm:ss";
            break;
        }case DateFromStringTypeYMD:{
            sDateFormatter=@"yyyy-MM-dd";
            break;
        }case DateFromStringTypeOther:{
            break;
        }
    }

    [dateFormatter setDateFormat:sDateFormatter];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

#pragma mark 去除html的标记
+ (NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    
    return html;
}



@end
