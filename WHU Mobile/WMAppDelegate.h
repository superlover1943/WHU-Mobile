//
//  WMAppDelegate.h
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kAppKey             @"your app_key"
#define kAppSecret          @"your app_secret"
#define kAppRedirectURI     @"your app_rederict_uri"

@class SinaWeibo;
@class SocialController;

@interface WMAppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, nonatomic) SinaWeibo *sinaweibo;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SocialController *socialController;

@end
