//
//  FXShareCenter.m
//  FXShareCenter
//
//  Created by huangwei on 2017/11/9.
//

#import "FXShareCenter.h"
#import "UIView+Toast.h"
//友盟分享头文件
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>
#import "MJExtension.h"
@implementation FXShareCentre
static FXShareCentre* _instance = nil;
+(instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc] init];
        _instance.plats  = [NSMutableArray arrayWithCapacity:0];
    });
    
    return _instance;
}

/**分析分享数据*/
- (void)handelShareContentWithJSContent:(NSString*)JSContent{
    self.shareModel =  [[FXShare alloc]initWithJSContent:JSContent];
}
/**分析分享数据*/
- (void)handelShareContentWithDictionary:(NSDictionary*)dic{
    self.shareModel = [FXShare mj_objectWithKeyValues:dic] ;
}
/**设置分享平台*/
- (void)handelShareContentWithShareModle:(FXShare*)model{
    NSArray * palts =  [model.sharePlatform componentsSeparatedByString:@","];
    NSAssert( palts.count != 0, @"palts不能为空！");
    [palts enumerateObjectsUsingBlock:^(NSString * plat, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isPureInt:plat]) {
            [self.plats addObject:@(plat.integerValue)];
        }
    }];
    //设置分享平台
    [UMSocialUIManager setPreDefinePlatforms:self.plats];
}

/**配置分享内容*/
- (UMSocialMessageObject*)configureUMSocialMessageObjectUsualTypeWithModel:(FXShare*)model{
    // 根据获取的platformType确定所选平台进行下一步操作
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:model.title descr:model.des thumImage:model.image];
    //设置网页地址
    //            shareObject.webpageUrl =@"https://www.fosun-pay.com/";
    shareObject.webpageUrl =model.url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    return messageObject;
}

- (void)webShareWithJSContent:(NSString*)JSContent
               currentWebview:(UIWebView*)webview
                   completion:(void (^)(id data, NSError *error))completion{
    [self handelShareContentWithJSContent:JSContent];
    if (self.shareModel.shareFlag.integerValue == ShareContentType_Usual) {
        [self webShareUsualTypeWithModel:self.shareModel currentWebview:webview
                              completion:completion];
    }
}
- (void)webShareUsualTypeWithModel:(FXShare*)model
                    currentWebview:(UIWebView*)webview
                        completion:(void (^)(id data, NSError *error))completion{
    [self handelShareContentWithShareModle:model];
    //从服务器获取分享图片
    if (model.iconUrl.length>0 && model.image == nil) {
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL  URLWithString:model.iconUrl]];
        model.image = [UIImage imageWithData:imageData];
    }
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        UMSocialMessageObject * messageObject = [self configureUMSocialMessageObjectUsualTypeWithModel:model];
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            NSString * msg;
            if (error) {
                NSLog(@"************Share fail with error %@*********",error);
                if (error.code == UMSocialPlatformErrorType_Cancel) {
                    msg = @"2";
                    [[UIApplication sharedApplication].delegate.window makeToast:@"取消分享"];
                }else{
                    msg = @"3";
                    [[UIApplication sharedApplication].delegate.window makeToast:@"分享失败"];
                }
                
                if ([model.needCallback isEqualToString:@"true"]) {
                    [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",@"shareEndCallBack",msg]];
                }
            }else{
                NSLog(@"response data is %@",data);
                if ([model.needCallback isEqualToString:@"true"]){
                    [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",@"shareEndCallBack",@"1"]];
                    [[UIApplication sharedApplication].delegate.window makeToast:@"分享成功"];
                }
            }
            if (![model.h5Handle isEqualToString:@"true"]) {
                if (completion) {
                    completion( data, error);
                }else{
                    [webview reload];
                }
            }
        }];
    }];
}
- (void)shareWithJSContent:(NSString*)JSContent
     currentViewController:(UIViewController*)viewController
                completion:(void (^)(id data, NSError *error))completion{
    NSLog(@"JSContent  is %@",JSContent);
    [self handelShareContentWithJSContent:JSContent];
    if (self.shareModel.shareFlag.integerValue == ShareContentType_Usual){
        [self shareUsualTypeWithModel:self.shareModel currentViewController:viewController completion:completion];
    }
    
}
- (void)shareWithDictionary:(NSDictionary*)dic
      currentViewController:(UIViewController*)viewController
                 completion:(void (^)(id data, NSError *error))completion{
    [self handelShareContentWithDictionary:dic];
    if (self.shareModel.shareFlag.integerValue == ShareContentType_Usual){
        [self shareUsualTypeWithModel:self.shareModel currentViewController:viewController completion:completion];
    }
}

- (void)shareUsualTypeWithModel:(FXShare*)model
          currentViewController:(UIViewController*)viewController
                     completion:(void (^)(id data, NSError *error))completion{
    if (model.iconUrl.length>0 && model.image == nil) {
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL  URLWithString:model.iconUrl]];
        model.image = [UIImage imageWithData:imageData];
    }
    [self handelShareContentWithShareModle:model];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        UMSocialMessageObject * messageObject = [self configureUMSocialMessageObjectUsualTypeWithModel:model];
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
            if (error) {
                NSLog(@"************Share fail with error %@*********",error);
                if (error.code == UMSocialPlatformErrorType_Cancel) {
                    [[UIApplication sharedApplication].delegate.window makeToast:@"取消分享"];
                }else{
                    [[UIApplication sharedApplication].delegate.window makeToast:@"分享失败"];
                }
            }else{
                NSLog(@"response data is %@",data);
                [[UIApplication sharedApplication].delegate.window makeToast:@"分享成功"];
            }
            
        }];
    }];
}
//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

@end

@implementation FXShare

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"iconUrl":@"icon",
             @"des":@"describe",
             };
}
- (instancetype)initWithJSContent:(NSString*)JSContent{
    self = [super init];
    if (self) {
        self = [[self class] mj_objectWithKeyValues:JSContent];
    }
    return self;
}

- (instancetype)initWithJURL:(NSString *)url describe:(NSString *)describe title:(NSString *)title image:(UIImage *)image{
    self = [super init];
    if (self) {
        self.url = url;
        self.des = describe;
        self.title = title;
        self.image = image;
        self.shareFlag = @"1";
        self.needCallback = @"false";
        self.h5Handle = @"false";
    }
    return self;
}
- (instancetype)initWithJURL:(NSString *)url describe:(NSString *)describe title:(NSString *)title iconUrl:(NSString *)iconUrl{
    self = [super init];
    if (self) {
        self.url = url;
        self.des = describe;
        self.title = title;
        self.iconUrl = iconUrl;
        self.shareFlag = @"1";
        self.needCallback = @"false";
        self.h5Handle = @"false";
    }
    return self;
}

@end

