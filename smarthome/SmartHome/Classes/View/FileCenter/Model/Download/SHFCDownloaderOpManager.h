// SHFCDownloaderOpManager.h

/**************************************************************************
 *
 *       Copyright (c) 2014-2019 by iCatch Technology, Inc.
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
 
 // Created by zj on 2019/10/25 7:27 PM.
    

#import <Foundation/Foundation.h>
#import "SHS3FileInfo.h"
#import "SHDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kDownloadCompletionNotification = @"DownloadCompletionNotification";

@protocol SHFCDownloaderOpManagerDelegate <NSObject>

- (void)startDownloadWithFileInfo:(SHS3FileInfo *)fileInfo;
- (void)downloadCompletionWithFileInfo:(SHS3FileInfo *)fileInfo;

@end

@interface SHFCDownloaderOpManager : NSObject

+ (instancetype)sharedDownloader;
- (void)addDownloadFile:(SHS3FileInfo *)fileInfo;

- (void)cancelDownload:(SHS3FileInfo *)fileInfo;

- (void)startDownloadWithDeviceID:(NSString *)deviceID;

- (SHDownloadItem *)downloadItemWithDeviceID:(NSString *)deviceID;

@property (nonatomic, weak) id<SHFCDownloaderOpManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
