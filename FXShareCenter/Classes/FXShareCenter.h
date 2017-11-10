//
//  FXShareCentre.h
//  FBSnapshotTestCase
//
//  Created by huangwei on 2017/11/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FXShare;
@interface FXShareCentre : NSObject
/**分享类型目前就一种*/
typedef NS_ENUM(NSInteger,ShareContentType)
{
    ShareContentType_Usual = 1 //默认类型分享网页
};

/** 分享源数据*/
@property(nonatomic,strong) FXShare * shareModel;
/** 分享平台 数组*/
@property(nonatomic,strong) NSMutableArray * plats;

+(instancetype) defaultCenter;
/** h5分享调取*/
/**
 *  @param JSContent 分享内容json数据转换为FXShareModel
 *  @param webview 当前的webview
 *  @param completion   回调
 */
- (void)webShareWithJSContent:(NSString*)JSContent
               currentWebview:(UIWebView*)webview
                   completion:(void (^)(id data, NSError *error))completion;

/** 原生分享*/
/**
 *  @param JSContent 分享内容json数据转换为FXShareModel
 *  @param viewController 当前控制器
 *  @param completion   回调
 */
- (void)shareWithJSContent:(NSString*)JSContent
     currentViewController:(UIViewController*)viewController
                completion:(void (^)(id data, NSError *error))completion;

/**
 *  @param dic 分享源数据转换为FXShareModel
 *  @param viewController 当前控制器
 *  @param completion   回调
 */
- (void)shareWithDictionary:(NSDictionary*)dic
      currentViewController:(UIViewController*)viewController
                 completion:(void (^)(id data, NSError *error))completion;
/**
 *  @param model 分享源数据FXShareModel
 *  @param viewController 当前控制器
 *  @param completion   回调
 */
- (void)shareUsualTypeWithModel:(FXShare*)model
          currentViewController:(UIViewController*)viewController
                     completion:(void (^)(id data, NSError *error))completion;

@end

@interface FXShare : NSObject

- (instancetype)initWithJSContent:(NSString*)JSContent;

/**
 *  @param url 分享链接
 *  @param describe 副标题
 *  @param title 标题
 *  @param iconUrl 缩略图地址
 *  @param platforms 格式如“1,2,3”，对应平台参考对照参数
 */
- (instancetype)initWithJURL:(NSString*)url
                    describe:(NSString * )describe
                       title:(NSString * )title
                     iconUrl:(NSString * )iconUrl
                   platforms:(NSString*)platforms;
/**
 *  @param url 分享链接
 *  @param describe 副标题
 *  @param title 标题
 *  @param image 缩略图
 *  @param platforms 格式如“1,2,3”，对应平台参考对照参数
 */
- (instancetype)initWithJURL:(NSString*)url
                    describe:(NSString * )describe
                       title:(NSString * )title
                       image:(UIImage * )image
                   platforms:(NSString*)platforms;

/** 分享形式 默认为 ShareContentsType_Usual = 1 */
@property(nonatomic,copy) NSString * shareFlag;
/** 地址 */
@property(nonatomic,copy) NSString * url;
/** 副标题 */
@property(nonatomic,copy) NSString * des;
/** 标题 */
@property(nonatomic,copy) NSString * title;
/** 图片地址 */
@property(nonatomic,copy) NSString * iconUrl;
/** 图片 */
@property(nonatomic,strong) UIImage * image;
/** 分享平台数字用逗号”,”隔开，格式如“1,2,3”，对应平台参考对照参数 */
@property(nonatomic,copy) NSString * sharePlatform;

/** 是否需要web页面处理回调 true则由h5处理分享后的逻辑，false则由原生处理，原生默认将当前页面刷新一次   默认false*/
@property(nonatomic,copy) NSString * h5Handle;
/** 是否回调true则通过交互方法shareEndCallBack(String  msg)通知h5页面分享结束，false则不通知  默认false*/
@property(nonatomic,copy) NSString * needCallback;
@end

