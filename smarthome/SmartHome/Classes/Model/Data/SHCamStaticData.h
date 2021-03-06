//
//  WifiCamStaticData.h
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 14-6-24.
//  Copyright (c) 2014年 iCatchTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "type/ICatchError.h"

@interface SHCamStaticData : NSObject

+ (SHCamStaticData *)instance;

#pragma mark - Gloabl static table
@property(nonatomic, readonly) NSDictionary *tutkModeDict;
@property(nonatomic, readonly) NSDictionary *tutkErrorDict;
@property (nonatomic, readonly) NSDictionary *monthStringDict;
@property (nonatomic, readonly) NSArray *streamQualityArray;

- (BOOL)isBackToHome;
- (void)setBackToHomeState:(BOOL)state;

@end
