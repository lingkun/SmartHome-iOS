// BasicFileInfo.h

/**************************************************************************
 *
 *       Copyright (c) 2014-2018年 by iCatch Technology, Inc.
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
 
 // Created by sa on 2018/4/18 上午10:55.
    

#import <Foundation/Foundation.h>

@interface BasicFileInfo : NSObject

@property(nonatomic, readonly) NSString * _Nonnull index;
@property(nonatomic, readonly) NSString * _Nonnull name;
@property(nonatomic, readonly) NSString *time;             //option

@property(nonatomic, readonly) NSString *videoPath;         //option
@property(nonatomic, readonly) NSString *thumbnailPath;     //option
@property(nonatomic, readonly) NSInteger videoSize;         //option
@property(nonatomic, readonly) NSInteger thumbnailSize;     //option

@property(nonatomic, readonly) NSInteger type;
@property(nonatomic, readonly) NSInteger duration;    //option
@property(nonatomic, readonly) NSInteger favorite;    //option

-(instancetype)initWithData:(NSDictionary *)dict;
+(instancetype)basicFileInfoInitWithData:(NSDictionary *)dict;
@end
