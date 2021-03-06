// SHENetworkManager+DeviceAWSS3.h

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
 
 // Created by zj on 2019/9/24 7:26 PM.
    

#import "SHENetworkManager.h"
#import "SHS3FileInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kDeviceAWSAuth = @"v1/devices/awsauth";
static NSString * const kDeviceS3Path = @"v1/devices/s3path";

typedef void(^SHEListFilesCompletionBlock)(AWSS3ListObjectsV2Output * _Nullable result, NSError * _Nullable error);

@interface SHENetworkManager (DeviceAWSS3)

#pragma mark - Device IdentityInfo
- (SHIdentityInfo *)getDeviceIdentityInfoWithDeviceid:(NSString *)deviceid;
- (void)getDeviceIdentityInfoWithDeviceid:(NSString *)deviceid completion:(SHERequestCompletionBlock)completion;

#pragma mark - Device S3DirectoryInfo
- (void)getDeviceS3DirectoryInfoWithDeviceid:(NSString *)deviceid completion:(SHERequestCompletionBlock)completion;

#pragma mark - Device Resoure
- (void)getDeviceCoverWithDeviceID:(NSString *)deviceID completion:(SHERequestCompletionBlock)completion;
- (void)getStrangerFaceImageWithDeviceID:(NSString *)deviceID completion:(SHERequestCompletionBlock)completion;
- (void)getDeviceMessageFileWithDeviceID:(NSString *)deviceID fileName:(NSString *)fileName completion:(SHERequestCompletionBlock)completion;

#pragma mark - List Files
- (void)listFilesWithDeviceID:(NSString *)deviceID oneday:(NSDate * _Nullable)oneday completion:(SHEListFilesCompletionBlock)completion;
- (void)listFilesWithDeviceID:(NSString *)deviceID onemonth:(NSDate * _Nullable)onemonth completion:(void (^)(NSDictionary<NSString *, NSArray<AWSS3Object *> *> *files))completion;

- (void)listFilesWithDeviceID:(NSString *)deviceID startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(SHEListFilesCompletionBlock)completion;

#pragma mark - Get File
- (void)getFileWithDeviceID:(NSString *)deviceID filePath:(NSString *)filePath completion:(SHERequestCompletionBlock)completion;

#pragma mark - Files Ops
- (NSDictionary<NSString *, NSNumber *> *)getFilesStorageInfoWithDeviceID:(NSString *)deviceID queryDate:(NSDate *)queryDate days:(NSInteger)days;

- (void)listFilesWithDeviceID:(NSString *)deviceID queryDate:(NSDate *)queryDate startKey:(NSString * _Nullable)startKey number:(NSInteger)number completion:(void (^)(NSArray<SHS3FileInfo *> * _Nullable filesInfo))completion;

- (void)deleteFile:(SHS3FileInfo *)fileInfo completion:(SHEDeleteFileCompletionBlock)completion;
- (void)deleteFiles:(NSArray<SHS3FileInfo *> *)filesInfo completion:(void (^)(NSArray<SHS3FileInfo *> *deleteSuccess, NSArray<SHS3FileInfo *> *deleteFailed))completion;

@end

NS_ASSUME_NONNULL_END
