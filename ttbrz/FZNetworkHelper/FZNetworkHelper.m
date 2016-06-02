

#import "FZNetworkHelper.h"

#define sSuccess             @"操作成功"
#define sFailed              @"操作失败"
#define sWaiting             @"正在处理中..."
#define sError_Connection    @"网络连接错误"
#define sError_Timeout       @"网络连接超时"
#define sError_GetData       @"获取网络数据错误"
#define sError_upload        @"上传文件错误"
#define sError_download      @"下载文件错误"
#define sSSOLoadError        @"授权失败"
#define iTimeout             8.0
#define iTimeoutForPost      30.0

#define webServerURL         @"http://www.ttbrz.cn/"
#define serverURL            @"http://www.ttbrz.cn/"
#define boundary_ID          @"boundary_upLoad"

@implementation FZNetworkHelper

+(FZNetworkHelper*)shared{
    static dispatch_once_t once = 0;
	static FZNetworkHelper *ServerMethodObj;
	dispatch_once(&once, ^{ ServerMethodObj = [[FZNetworkHelper alloc] init]; });
	return ServerMethodObj;
}

#pragma mark 返回nsurlsession 对象
-(NSURLSession*)returnPublicSession:(requestMethodType)requestMethodType{
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    //post 方式的时间会长一点
    if (requestMethodType==requestMethodGet) {
        sessionConfig.timeoutIntervalForRequest=iTimeout;
        sessionConfig.timeoutIntervalForResource=iTimeout;
    }else if (requestMethodType==requestMethodPost){
        //sessionConfig.timeoutIntervalForRequest=iTimeoutForPost;
        //sessionConfig.timeoutIntervalForResource=iTimeoutForPost;
    }
    sessionConfig.allowsCellularAccess=YES;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig];
    
    return session;
}

#pragma-mark DataTask
#pragma-mark 简单Http 访问网络数据
/*
接口 使用http Get/Post 提交数据
http Get 使用这种形式 http://192.168.4.24:8080/Main/GetAppAddressByID?appAddressID=46456 GetAppAddressByID是接口名称  
 
http Post pCondition 参数对应的值为 GetAppAddressByID?userName=dbo&password=1234 以?为分段 前面为服务接口名称 后面为post 
 参数集合 被 setHTTPBody 使用
*/
+(void)dataTaskWithApiName:(NSString *)apiName arryPara:(NSArray*)arryPara requestMethodType:(requestMethodType)requestMethodType fatherObject:(id)fatherObject bShowSuccessMsg:(BOOL)bShowSuccessMsg sWaitingMsg:(NSString*)sWaitingMsg block:(returnBlock)block{
    
    UIViewController *fatherView=(UIViewController*)fatherObject;
    
    //定义返回数据集
   __block NSDictionary *dictReturn;
    
    //定义错误内容
   __block NSString *sErrMsg=@"";
    
    //等待提示
    id showHUD;
    if (sWaitingMsg) {
        showHUD=[PublicFunc ShowWaittingHUD:sWaitingMsg view:fatherView.view];
    }else{
        showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:fatherView.view];
    }
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
       
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        
        if (requestMethodType==requestMethodGet) {
            urlStr=[NSString stringWithFormat:@"%@%@?%@",webServerURL,apiName,sPara];
        }else if (requestMethodType==requestMethodPost){
            urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
        }
    }else{
        urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
    }

    
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //NSString 中包含中文字符时转换为NSURL
    //由于url支持26个英文字母、数字和少数几个特殊字符，因此，对于url中包含非标准url的字符时，就需要对其进行编码。iOS中提供了函数stringByAddingPercentEscapesUsingEncoding对中文和一些特殊字符进行编码，但是stringByAddingPercentEscapesUsingEncoding的功能并不完善，对一些较为特殊的字符无效。而对这些字符则可以使用CFURLCreateStringByteAddingPercentEscapes函数，
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    if (requestMethodType==requestMethodGet) {
        [request setHTTPMethod:@"Get"];
    }else if (requestMethodType==requestMethodPost){
        [request setHTTPMethod:@"POST"];
        //创建post参数
        //NSString *bodyDataStr=[NSString stringWithFormat:@"oper=add&appAddressID=%@",@"46456"];
        NSData *bodyData=[sPara dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodType];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        //HUD 显示内容 在主线程中处理结果
        //用[NSOperationQueue mainQueue]代替 performSelectorOnMainThread 可以在block中处理业务 在需要传大量参数时方便
        //还可以用 GCD 的dispatch_async(dispatch_get_main_queue(), ^{})
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //关闭等待提示
            [PublicFunc HideHUD:showHUD];
            if ([sErrMsg isEqualToString:@""]) {
                if (bShowSuccessMsg) {
                    //成功提示
                    [PublicFunc ShowSuccessHUD:sSuccess view:fatherView.view];
                }
                 block(dictReturn,YES);
            }else{
                //错误提示
                [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
                block(nil,NO);
            }
        }];
    }];
    
    //恢复线程，启动任务
    [dataTask resume];
}

+(void)dataTaskWithUrl:(NSString *)url arryPara:(NSArray*)arryPara requestMethodType:(requestMethodType)requestMethodType fatherObject:(id)fatherObject bShowSuccessMsg:(BOOL)bShowSuccessMsg block:(returnBlock) block{

    UIViewController *fatherView=(UIViewController*)fatherObject;
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //等待提示
    id showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:fatherView.view];
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        if (requestMethodType==requestMethodGet) {
            urlStr=[NSString stringWithFormat:@"%@?%@",url,sPara];
        }else if (requestMethodType==requestMethodPost){
            urlStr=url;
        }
    }else{
        urlStr=url;
    }
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //NSString 中包含中文字符时转换为NSURL
    //由于url支持26个英文字母、数字和少数几个特殊字符，因此，对于url中包含非标准url的字符时，就需要对其进行编码。iOS中提供了函数stringByAddingPercentEscapesUsingEncoding对中文和一些特殊字符进行编码，但是stringByAddingPercentEscapesUsingEncoding的功能并不完善，对一些较为特殊的字符无效。而对这些字符则可以使用CFURLCreateStringByteAddingPercentEscapes函数，
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    if (requestMethodType==requestMethodGet) {
        [request setHTTPMethod:@"Get"];
    }else if (requestMethodType==requestMethodPost){
        [request setHTTPMethod:@"POST"];
        //创建post参数
        NSData *bodyData=[sPara dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodType];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        //HUD 显示内容 在主线程中处理结果
        //用[NSOperationQueue mainQueue]代替 performSelectorOnMainThread 可以在block中处理业务 在需要传大量参数时方便
        //还可以用 GCD 的dispatch_async(dispatch_get_main_queue(), ^{})
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //关闭等待提示
            [PublicFunc HideHUD:showHUD];
            
            if ([sErrMsg isEqualToString:@""]) {
                if (bShowSuccessMsg) {
                    //成功提示
                    [PublicFunc ShowSuccessHUD:sSuccess view:fatherView.view];
                }
                block(dictReturn,YES);
            }else{
                //错误提示
                [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
                block(nil,NO);
            }
        }];
    }];
    
    //恢复线程，启动任务
    [dataTask resume];
}

#pragma-mark 简单Http 访问网络数据没有HUD
+(void)dataTaskWithApiNameNoHUD:(NSString *)apiName arryPara:(NSArray*)arryPara requestMethodType:(requestMethodType)requestMethodType block:(returnBlockNoHUD) block{
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        
        if (requestMethodType==requestMethodGet) {
            urlStr=[NSString stringWithFormat:@"%@%@?%@",webServerURL,apiName,sPara];
        }else if (requestMethodType==requestMethodPost){
            urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
        }
    }else{
        urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
    }
    
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //NSString 中包含中文字符时转换为NSURL
    //由于url支持26个英文字母、数字和少数几个特殊字符，因此，对于url中包含非标准url的字符时，就需要对其进行编码。iOS中提供了函数stringByAddingPercentEscapesUsingEncoding对中文和一些特殊字符进行编码，但是stringByAddingPercentEscapesUsingEncoding的功能并不完善，对一些较为特殊的字符无效。而对这些字符则可以使用CFURLCreateStringByteAddingPercentEscapes函数，
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    if (requestMethodType==requestMethodGet) {
        [request setHTTPMethod:@"Get"];
    }else if (requestMethodType==requestMethodPost){
        [request setHTTPMethod:@"POST"];
        //创建post参数
        NSData *bodyData=[sPara dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodType];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        if ([sErrMsg isEqualToString:@""]) {
            block(dictReturn,sErrMsg);
        }else{
            block(nil,sErrMsg);
        }
    }];
    
    //恢复线程，启动任务
    [dataTask resume];
}

+(void)dataTaskWithUrlNoHUD:(NSString *)url arryPara:(NSArray*)arryPara requestMethodType:(requestMethodType)requestMethodType  block:(returnBlockNoHUD)block{
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        
        if (requestMethodType==requestMethodGet) {
            urlStr=[NSString stringWithFormat:@"%@?%@",url,sPara];
        }else if (requestMethodType==requestMethodPost){
            urlStr=url;
        }
    }else{
        urlStr=url;
    }
    
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //NSString 中包含中文字符时转换为NSURL
    //由于url支持26个英文字母、数字和少数几个特殊字符，因此，对于url中包含非标准url的字符时，就需要对其进行编码。iOS中提供了函数stringByAddingPercentEscapesUsingEncoding对中文和一些特殊字符进行编码，但是stringByAddingPercentEscapesUsingEncoding的功能并不完善，对一些较为特殊的字符无效。而对这些字符则可以使用CFURLCreateStringByteAddingPercentEscapes函数，
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    if (requestMethodType==requestMethodGet) {
        [request setHTTPMethod:@"Get"];
    }else if (requestMethodType==requestMethodPost){
        [request setHTTPMethod:@"POST"];
        //创建post参数
        NSData *bodyData=[sPara dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];
    }
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodType];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([sErrMsg isEqualToString:@""]) {
                block(dictReturn,sErrMsg);
            }else{
                block(nil,sErrMsg);
            }
        }];
    }];
    
    //恢复线程，启动任务
    [dataTask resume];
}


#pragma-mark Soap webserver访问网络数据
+(void)dataTaskWithApiName_Soap:(NSString *)apiName soapMsg:(NSString*)soapMsg fatherObject:(id)fatherObject block:(returnBlock_Soap)block{
    UIViewController *fatherView=(UIViewController*)fatherObject;
    
    //定义返回数据集
    __block NSString *sReturnSoap=@"";
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //等待提示
    id showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:fatherView.view];
    
    //1.创建url
    NSString *urlStr=@"http://192.168.4.51/swtpropda/service.asmx";//测试使用的一个地址
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    //构造soap请求体
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *CallFunction=[@"http://tempuri.org/" stringByAppendingString:apiName];
    [request addValue:CallFunction  forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodPost];
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            
            //将data xml数据转成 string
            NSString *sXML =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //替换xmlns为xmlnsA，因为kissxml 有xmlns会查不到数据
            sXML=[sXML stringByReplacingOccurrencesOfString:@" xmlns=" withString:@" xmlnsA="];
            
            sReturnSoap=sXML;
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        //HUD 显示内容 在主线程中处理结果
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //关闭等待提示
            [PublicFunc HideHUD:showHUD];
            
            if ([sErrMsg isEqualToString:@""]) {
                block(sReturnSoap,YES);
            }else{
                //错误提示
                [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
                block(sReturnSoap,NO);
            }
        }];
    }];
    
    //恢复线程，启动任务
    [dataTask resume];
}

#pragma-mark Soap webserver访问网络数据没有HUD
+(void)dataTaskWithApiNameNoHUD_Soap:(NSString *)apiName soapMsg:(NSString*)soapMsg block:(returnBlock_Soap) block{
    //定义返回数据集
    __block NSString *sReturnSoap=@"";
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"http://192.168.4.51/swtpropda/service.asmx";//测试使用的一个地址
    //对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    //构造soap请求体
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *CallFunction=[@"http://tempuri.org/" stringByAppendingString:apiName];
    [request addValue:CallFunction  forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodPost];
    
    
    //从会话创建任务
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            
            //将data xml数据转成 string
            NSString *sXML =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //替换xmlns为xmlnsA，因为kissxml 有xmlns会查不到数据
            sXML=[sXML stringByReplacingOccurrencesOfString:@" xmlns=" withString:@" xmlnsA="];
            
            sReturnSoap=sXML;
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([sErrMsg isEqualToString:@""]) {
                block(sReturnSoap,YES);
            }else{
                block(sReturnSoap,NO);
            }
        }];
    }];
    
    //恢复线程，启动任务
    [dataTask resume];

}

#pragma-mark UploadTask
#pragma-mark 上传文件到服务器(等待线程)
/*
 在做WEB应用程序开发时，如果要上传一个文件往往会给form设置一个enctype=”multipart/form-data”的属性，不设置这个值在后台无法正常接收文件。在WEB开发过程中，form的这个属性其实本质就是指定请求头中Content-Type类型，当然使用GET方法提交就不用说了，必须使用URL编码。但是如果使用POST方法传递数据其实也是类似的，同样需要进行编码，具体编码方式其实就是通过enctype属性进行设置的。常用的属性值有：
 
 application/x-www-form-urlencoded：默认值，发送前对所有发送数据进行url编码，支持浏览器访问，通常文本内容提交常用这种方式。
 multipart/form-data：多部分表单数据，支持浏览器访问，不进行任何编码，通常用于文件传输（此时传递的是二进制数据） 。
 text/plain：普通文本数据类型，支持浏览器访问，发送前其中的空格替换为“+”，但是不对特殊字符编码。
 application/json：json数据类型，浏览器访问不支持 。
 text/xml：xml数据类型，浏览器访问不支持。
 要实现文件上传，必须采用POST上传，同时请求类型必须是multipart/form-data。在Web开发中，开发人员不必过多的考虑mutiparty/form-data更多的细节，一般使用file控件即可完成文件上传。但是在iOS中如果要实现文件上传，就没有那么简单了，我们必须了解这种数据类型的请求是如何工作的。
 */
+(void)upLoadTaskWithApiName:(NSString *)apiName arryPara:(NSArray*)arryPara fromDict:(NSDictionary*)fromDict fatherObject:(id)fatherObject updateFileType:(updateFileType)updateFileType sWaitingMsg:(NSString*)sWaitingMsg block:(returnBlock)block{
    
    UIViewController *fatherView=(UIViewController*)fatherObject;
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //等待提示
    id showHUD;
    if (sWaitingMsg) {
        showHUD=[PublicFunc ShowWaittingHUD:sWaitingMsg view:fatherView.view];
    }else{
        showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:fatherView.view];
    }
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        urlStr=[NSString stringWithFormat:@"%@%@?%@",webServerURL,apiName,sPara];
    }else{
        urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
    }
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
    
    request.HTTPMethod=@"POST";
    
    //获取发送的数据体
    NSData *dfromData;
    switch (updateFileType) {
        case updateFileTypeText:{
            break;
        }case updateFileTypeImage:{
            dfromData=[[FZNetworkHelper shared] getHttpBodyFromDictionaryImages:fromDict];
            break;
        }
        default:
            break;
    }
    //通过请求头设置
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)dfromData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary_ID] forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody=dfromData;
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodPost];
    NSURLSessionUploadTask *upLoadTask=[session uploadTaskWithRequest:request fromData:dfromData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        //HUD 显示内容 在主线程中处理结果
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //关闭等待提示
            [PublicFunc HideHUD:showHUD];
            if ([sErrMsg isEqualToString:@""]) {
                //成功提示
                [PublicFunc ShowSuccessHUD:sSuccess view:fatherView.view];
                block(dictReturn,YES);
            }else{
                //错误提示
                [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
                block(nil,NO);
            }
        }];
    }];
    
    //启动
    [upLoadTask resume];
}

//没有HUD的上传
+(void)upLoadTaskWithApiNameNoHUD:(NSString *)apiName arryPara:(NSArray*)arryPara fromDict:(NSDictionary*)fromDict updateFileType:(updateFileType)updateFileType  block:(returnBlockNoHUD) block{
    
    //定义返回数据集
    __block NSDictionary *dictReturn;
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        urlStr=[NSString stringWithFormat:@"%@%@?%@",webServerURL,apiName,sPara];
    }else{
        urlStr=[NSString stringWithFormat:@"%@%@",webServerURL,apiName];
    }
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建请求
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
    
    request.HTTPMethod=@"POST";
    
    //获取发送的数据体
    NSData *dfromData;
    switch (updateFileType) {
        case updateFileTypeText:{
            break;
        }case updateFileTypeImage:{
            dfromData=[[FZNetworkHelper shared] getHttpBodyFromDictionaryImages:fromDict];
            break;
        }
        default:
            break;
    }
    //通过请求头设置
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)dfromData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary_ID] forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody=dfromData;
    
    //3.创建会话（这里使用了一个全局会话）并且启动任务
    NSURLSession *session=[[FZNetworkHelper shared] returnPublicSession:requestMethodPost];
    NSURLSessionUploadTask *upLoadTask=[session uploadTaskWithRequest:request fromData:dfromData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            if (data==nil) {
                sErrMsg=sError_GetData;
            }
            //获取数据,用json解释数据
            dictReturn=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (dictReturn==nil) {
                sErrMsg=sError_GetData;
            }
            
        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        if ([sErrMsg isEqualToString:@""]) {
            block(dictReturn,sErrMsg);
        }else{
            block(nil,sErrMsg);
        }
    }];
    //启动
    [upLoadTask resume];
}

//取得mime types
-(NSString *)getMIMETypes:(NSString *)fileName{
    NSString *sReturn=@"";
    NSString *sExtension=[fileName pathExtension];
    sExtension=sExtension.lowercaseString;
    
    //图片类型
    if ([sExtension isEqualToString:@"png"] || [sExtension isEqualToString:@"jpg"] || [sExtension isEqualToString:@"jpeg"]) {
        sReturn=@"image/jpeg";
    }else if ([sExtension isEqualToString:@"txt"]){
        //文本类型
        sReturn=@"text/html";
    }else{
    //其它
        sReturn=@"application/zip";
    }
    return sReturn;
}

//返回上传图片文件的数据体 支持多文件
-(NSData*)getHttpBodyFromDictionaryImages:(NSDictionary*)dictImages{
    //分界线 --boundary_ID
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",boundary_ID];
    //结束符 boundary_ID--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    //UIImage *image;
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [dictImages allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",[[key componentsSeparatedByString:@"."] firstObject]];
        //添加字段的值
        [body appendFormat:@"%@\r\n",key];
    }
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //循环加入上传图片
    keys = [dictImages allKeys];
    
    NSMutableString *imgStr = [[NSMutableString alloc] init];
    
    for(int i = 0; i< [keys count] ; i++){
        //要上传的图片
        //image = [dictImages objectForKey:[keys objectAtIndex:i ]];
        //得到图片的data
        NSData* data =  [dictImages objectForKey:[keys objectAtIndex:i]];
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        //此处循环添加图片文件
        
        ////添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"File%d\"; filename=\"%@\"\r\n", i+1, [keys objectAtIndex:i]];
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
        
        //NSLog(@"上传的图片：%d  %@", i, [keys objectAtIndex:i]);
        
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [imgStr appendString:imgbody];
    }
    //声明结束符：--boundary_ID--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--boundary_ID--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    return myRequestData;
}

//取得数据体
-(NSData *)getHttpBody:(NSData*)pfromData{
    
    NSMutableData *dataM=[NSMutableData data];
    //NSString *strRequest;
    NSString *sFileName=@"";//[SystemPlist GetHeadLogoFileName];
    
    NSString *strTop=[NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"media\"; filename=\"%@\"\nContent-Type: %@\n\n",boundary_ID,sFileName,[self getMIMETypes:sFileName]];
    NSString *strMid=[NSString stringWithFormat:@"\n--%@\nContent-Disposition: form-data; name=\"filename\"\n\n",boundary_ID];
    NSString *strBottom=[NSString stringWithFormat:@"\n--%@--",boundary_ID];
    
    //strRequest=[NSString stringWithFormat:@"%@%@%@",strTop,strMid,strBottom];
    
    [dataM appendData:[strTop dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:pfromData];
    
    [dataM appendData:[strMid dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:[sFileName dataUsingEncoding:NSUTF8StringEncoding]];
    
    [dataM appendData:[strBottom dataUsingEncoding:NSUTF8StringEncoding]];
    return dataM;
}

#pragma-mark 上传文件到服务器(后台上传)
+(void)upLoadTaskWithCondition:(NSString *)condition arryFilePath:(NSArray*)arryFilePath fatherObject:(id)fatherObject{
    
    //UIViewController *fatherView=(UIViewController*)pFatherObject;
    
    //标记等待状态
    //BOOL bWaitting=YES;
    
    //定义错误内容
    //__block NSString *sErrMsg=@"";
    
    //等待提示
    //id showHUD=[PublicFunc ShowWaittingHUD:sWaitting view:fatherView.view];
    
    //1.创建url
    NSString *urlStr=[NSString stringWithFormat:@"http://192.168.4.51/swtpropda/UpLoadFile.aspx"];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    //2.创建后台会话
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"sessionUpLoadData"];
    sessionConfig.allowsCellularAccess=YES;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    
    [FZNetworkHelper shared].sessionUpLoadMultiFile=[NSURLSession sessionWithConfiguration:sessionConfig delegate:[FZNetworkHelper shared] delegateQueue:nil];
    
    
    
    for (NSString *curPath in arryFilePath) {
        //2.创建请求
        NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:url];
        request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
        
        request.HTTPMethod=@"POST";
        //获取发送的数据体
        NSData *data;//[[FZNetworkHelper shared] getHttpBody:curPath];
        NSLog(@"%@",curPath);
        
        //通过请求头设置
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary_ID] forHTTPHeaderField:@"Content-Type"];
        request.HTTPBody=data;
        
        [FZNetworkHelper shared].taskUpLoadMultiFile=[[FZNetworkHelper shared].sessionUpLoadMultiFile uploadTaskWithRequest:request fromData:data];
        
        //启动
        [[FZNetworkHelper shared].taskUpLoadMultiFile resume];
    }
    
    //等待网络的block处理完后在返回结果
//    while (bWaitting) {
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
    

    
    
//    NSURLSessionUploadTask *upLoadTask=[session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"%@",error.description);
//            sErrMsg=sError_upload;
//        }
//        
//        //HUD 显示内容 在主线程中处理结果
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            //关闭等待提示
//            [PublicFunc HideHUD:showHUD];
//            
//            if ([sErrMsg isEqualToString:@""]) {
//                pBlock(nil,YES);
//                //成功提示
//                [PublicFunc ShowSuccessHUD:sSuccess view:fatherView.view];
//            }else{
//                
//                pBlock(nil,NO);
//                //错误提示
//                [PublicFunc ShowErrorHUD:sErrMsg view:fatherView.view];
//            }
//        }];
//    }];
//    
//    //启动
//    [upLoadTask resume];
}

// 上传进度中 (会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{

    //bytesSent                 每次理论上传的数据
    //totalBytesSent            每次实际上传的数据
    //totalBytesExpectedToSend  每次要上传的总数据
    
    NSLog(@"\n%f / %f", (double)totalBytesSent,(double)totalBytesExpectedToSend);
    
    //在主线程中更新UI
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //self.pView.progress=(double)totalBytesSent / (double)totalBytesExpectedToSend;
    }];
    
}

// 上传完成，不管是否下载成功
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        [FZNetworkHelper shared].bTaskSuccess=NO;
        [FZNetworkHelper shared].bTaskWaitting=NO;
        
        [[FZNetworkHelper shared].taskUpLoadMultiFile cancel];
        
        NSLog(@"Error is:%@",error.localizedDescription);
    }
}

#pragma-mark DownloadTask
+ (void)downTaskInBackgroundWithUrl:(NSString *)url
                           arryPara:(NSArray*)arryPara
                           savePath:(NSString*)savePath
                              block:(returnBlockNoHUD)block{
    
    //定义错误内容
    __block NSString *sErrMsg=@"";
    
    //1.创建url
    NSString *urlStr=@"";
    NSString *sPara=@"";
    if (arryPara.count>0) {
        //生成参数串 categoryid=1&currentpage=1
        for (NSString *curPara in arryPara) {
            if ([sPara isEqualToString:@""]) {
                sPara=curPara;
            }else{
                sPara=[sPara stringByAppendingString:[NSString stringWithFormat:@"&%@",curPara]];
            }
        }
        urlStr=[NSString stringWithFormat:@"%@?%@",url,sPara];
    }else{
        urlStr=url;
    }
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];

    //创建会话（这里使用了一个全局会话）并且启动任务
    
    static NSURLSession *session;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];//[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.cmjstudio.URLSession"];
        
        sessionConfig.timeoutIntervalForRequest=iTimeout;//请求超时时间
        sessionConfig.discretionary=YES;//系统自动选择最佳网络下载
        sessionConfig.HTTPMaximumConnectionsPerHost=5;//限制每次最多一个连接
        //创建会话
        session=[NSURLSession sessionWithConfiguration:sessionConfig];
    });


    //从会话创建任务
    NSURLSessionDownloadTask *downloadTask=[session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (location==nil) {
                sErrMsg=sError_GetData;
            }
            //下载到指定地址
            NSError *error;
            NSFileManager *fileManager=[NSFileManager defaultManager];
            NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
            
            //删除旧文件
            [fileManager removeItemAtURL:saveUrl error:nil];
            
            [fileManager copyItemAtURL:location toURL:saveUrl error:&error];
            if (error) {
                NSLog(@"didFinishDownloadingToURL:Error is %@",error.localizedDescription);
                sErrMsg=sError_download;
            }

        }else{
            if (error.code==NSURLErrorTimedOut) {
                sErrMsg=sError_Timeout;
            }else{
                sErrMsg=sError_Connection;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([sErrMsg isEqualToString:@""]) {
                block(nil,sErrMsg);
            }else{
                block(nil,sErrMsg);
            }
        }];
        
        [downloadTask cancel];

    }];
    
    //恢复线程，启动任务
    [downloadTask resume];
}

#pragma-mark 下载数据(等待线程)
+(void)downTaskWithCondition:(NSString *)condition arryFilePath:(NSArray*)arryFilePath fatherObject:(id)fatherObject{
    
    //1.创建url
    NSString *urlStr=[NSString stringWithFormat:@"http://192.168.4.51/swtpropda/test/test.rar"];
    urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //2.创建后台会话
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"sessionUpLoadData"];
    sessionConfig.allowsCellularAccess=YES;                  //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:[FZNetworkHelper shared] delegateQueue:nil];
    
    [FZNetworkHelper shared].sessionDownLoad=[session downloadTaskWithRequest:request];
    
    
    [[FZNetworkHelper shared].sessionDownLoad resume];
    
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Other Operation....
    /*
    if (appDelegate.backgroundSessionCompletionHandler) {
        
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        
        appDelegate.backgroundSessionCompletionHandler = nil;
        
        completionHandler();
        
    }
     */
}



//下载任务代理
//下载中(会多次调用，可以记录下载进度)
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //    [NSThread sleepForTimeInterval:0.5];
    //NSLog(@"%.2f",(double)totalBytesWritten/totalBytesExpectedToWrite);
    
    //[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //NSLog(@"%.2f",(double)totalBytesWritten/totalBytesExpectedToWrite);
        //addActionViewController *addView=[[addActionViewController alloc] init];
        //addView.pView.progress=(double)totalBytesWritten/totalBytesExpectedToWrite;
    //}];
}

//下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSError *error;
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath=[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[NSDate date]]];
    NSLog(@"%@",savePath);
    NSURL *saveUrl=[NSURL fileURLWithPath:savePath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&error];
    if (error) {
        NSLog(@"didFinishDownloadingToURL:Error is %@",error.localizedDescription);
    }
}

//任务完成，不管是否下载成功
//-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    if (error) {
//        NSLog(@"DidCompleteWithError:Error is %@",error.localizedDescription);
//    }
//}


#pragma-mark 判断网络是否连通
+(BOOL)checkNetWork:(NSString *)serverUrl iTimeOutSeconds:(int)iTimeOutSeconds fatherObject:(id)fatherObject showErrorMsg:(BOOL)showErrorMsg{
    UIViewController *fatherView=(UIViewController*)fatherObject;
    //等待提示
    id showHUD=[PublicFunc ShowWaittingHUD:sWaiting view:fatherView.view];
    
    __block NSString *sErrorCheckNetwork=sError_Connection;
    __block BOOL bWaitting=YES;//等待sessiondatatask测试网络的处理结果
    __block BOOL bNetwork=YES; //测试网络是否边通结果
    
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForResource=iTimeOutSeconds;       //超时设置
    sessionConfig.allowsCellularAccess=YES;                          //是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.discretionary=YES;
    
    NSURLSession *sessionCheckNetwork=[NSURLSession sessionWithConfiguration:sessionConfig];
    
    //1.创建url
    NSString *urlStr=[serverUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    //2.创建请求
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //3.请求
    NSURLSessionDataTask *sessionDataTaskCheckNetwork=[sessionCheckNetwork dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%d",error.code);
        if (error) {
            bNetwork=NO;
            if (error.code==NSURLErrorTimedOut) {
                sErrorCheckNetwork=sError_Timeout;
            }
        }
        bWaitting=NO;
        
        //HUD 显示内容 在主线程中处理结果
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //关闭等待提示
            [PublicFunc HideHUD:showHUD];
        }];
    }];
    //4.开始任务
    [sessionDataTaskCheckNetwork resume];
    
    
    //等待网络的block处理完后在返回结果
    while (bWaitting) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    if (bNetwork==NO) {
        
        if (showErrorMsg) {
            //错误提示
            [PublicFunc ShowErrorHUD:sErrorCheckNetwork view:fatherView.view];
        }
        return NO;
    }
    sessionDataTaskCheckNetwork=nil;
    
    return YES;
}

#pragma-mark 返回服务器地址
+(NSString*)getServerUrl{
    return serverURL;
}

@end
