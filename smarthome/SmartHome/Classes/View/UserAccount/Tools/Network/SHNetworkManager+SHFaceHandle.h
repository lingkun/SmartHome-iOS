// SHNetworkManager+SHFaceHandle.h

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
 
 // Created by zj on 2019/1/7 1:53 PM.
    

#import "SHNetworkManager.h"
#import "ZJRequestError.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const FACES_MANAGE_PATH = @"v1/users/facesmanage";
static NSString * const TOKEN_PATH = @"oauth2/token";
static NSString * const FACE_RECOGNITION_PATH = @"v1/devices/facerecognition";

typedef void (^ZJRequestCallBack)(_Nullable id result, ZJRequestError * _Nullable error);
typedef enum : NSUInteger {
    ZJRequestMethodGET,
    ZJRequestMethodPOST,
    ZJRequestMethodPUT,
    ZJRequestMethodDELETE,
} ZJRequestMethod;

typedef enum : NSUInteger {
    ZJOperationTypeFaces,
    ZJOperationTypeOAuth,
    ZJOperationTypeAccount,
    ZJOperationTypeDevice,
} ZJOperationType;

@interface SHNetworkManager (SHFaceHandle)

- (void)uploadFacePicture:(NSData *)data name:(NSString *)name finished:(_Nullable ZJRequestCallBack)finished;
- (void)deleteFacePictureWithName:(NSString *)name finished:(ZJRequestCallBack)finished;
- (void)getFacesInfoWithName:(NSString * _Nullable)name finished:(ZJRequestCallBack)finished;
- (void)replaceFacePicture:(NSData *)data name:(NSString *)name finished:(ZJRequestCallBack)finished;

- (void)faceRecognitionWithPicture:(NSData *)data deviceID:(NSString *)deviceID finished:(_Nullable ZJRequestCallBack)finished;

@end

NS_ASSUME_NONNULL_END