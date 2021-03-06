// serverUrl.h

/**************************************************************************
 *
 *       Copyright (c) 2014-2018 by iCatch Technology, Inc.
 *
 *  This software is copyrighted by and is the property of iCatch
 *  Technology, Inc.. All rights are reserved by iCatch Technology, Inc..
 *  This software may only be used in accordance with the corresponding
 *  license agreement. Any unauthorized use, duplication, distribution,
 *  or disclosure of this software is expressly forbidden.
 *
 *  This Copyright notice MUST not be removed or modified without prior
 *  written consent of iCatch Technology, Inc..
 *
 *  iCatch Technology, Inc. reserves the right to modify this software
 *  without notice.
 *
 *  iCatch Technology, Inc.
 *  19-1, Innovation First Road, Science-Based Industrial Park,
 *  Hsin-Chu, Taiwan, R.O.C.
 *
 **************************************************************************/
 
 // Created by qa on 2018/5/23 9:17 AM.
    

#import <Foundation/Foundation.h>

@interface ServerUrl : NSObject
+ (instancetype)sharedServerUrl;
@property (nonatomic,copy, setter=setBaseUrl:)  NSString *BaseUrl;
@property (nonatomic, readonly) BOOL useSSL ;

@property (nonatomic, copy, readonly) NSString *client_id;
@property (nonatomic, copy, readonly) NSString *client_secret;

- (void)configAccountServerWithClientID:(NSString *)client_id client_secret:(NSString *)client_secret;

@end
