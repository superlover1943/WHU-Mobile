//
//  WHUWLAN.h
//  testProject
//
//  Created by 黄 嘉恒 on 2/26/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WHUWLANDelegate <NSObject>

- (void)handleWLANLoginResponse:(NSString *)response;

@end

@interface WHUWLAN : NSObject <NSURLConnectionDelegate>
@property (nonatomic)id<WHUWLANDelegate> delegate;

- (void)loginUsingUsername:(NSString *)username
               andPassword:(NSString *)password;
- (void)loadCookie;
- (void)logOff;
- (void)checkWhetherLogged;

//Designed initializer. DO NOT USE init!
- (id)initWithDelegate:(id)delegate;

@end

