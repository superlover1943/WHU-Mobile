//
//  WMAppDelegate.h
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHUWLAN;

@interface WMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WHUWLAN *whuWlan;

@end
