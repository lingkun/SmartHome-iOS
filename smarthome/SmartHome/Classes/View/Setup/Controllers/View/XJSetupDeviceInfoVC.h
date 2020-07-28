// XJSetupDeviceInfoVC.h

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
 
 // Created by zj on 2018/5/21 下午5:37.
    

#import <UIKit/UIKit.h>

@interface XJSetupDeviceInfoVC : UIViewController

@property (nonatomic, copy) NSString *wifiSSID;
@property (nonatomic, copy) NSString *wifiPWD;
@property (nonatomic, assign) BOOL useQRCodeSetup;
@property (nonatomic, assign, getter=isAutoWay) BOOL autoWay;

@end
