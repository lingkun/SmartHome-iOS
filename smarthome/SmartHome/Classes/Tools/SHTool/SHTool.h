//
//  SHTool.h
//  SmartHome
//
//  Created by ZJ on 2017/4/26.
//  Copyright © 2017年 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskSpaceTool.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SHFileFilter) {
    SHFileFilterMonitorType,
    SHFileFilterFileType,
    SHFileFilterFavoriteType,
};

@interface SHTool : NSObject

+ (NSArray *)createMediaDirectoryWithPath:(NSString *)path;
+ (void)removeMediaDirectoryWithPath:(NSString *)path;
+ (void)cleanUpDownloadDirectoryWithPath:(NSString *)path;
+ (void)enableLogSdkAtDiretctory:(NSString *)directoryName enable:(BOOL)enable;
+ (NSArray *)registerDefaultsFromSHFileFilter;
+ (void)setLocalFilesFilter:(ICatchFileFilter *)filter;
+ (unsigned long long)calcFileSize:(vector<ICatchFile>)fileList;

+ (void)removeFileWithPath:(NSString *)path;
+ (NSString *)databasePathWithName:(NSString *)databaseName;
+ (NSString *)createDownloadComplete:(NSDictionary *)tempDict;
+ (NSString *)bitRateStringFromBits:(CGFloat)bitCount;
+ (void)configureAppThemeWithController:(UINavigationController *)nav;
+ (void)resetNavigationBarAttributes:(UINavigationController *)nav;
+ (NSString *)deviceInfo;
+ (void)setupCurrentFullScreen:(BOOL)fullscreen;

+ (BOOL)isValidDeviceName:(NSString *)deviceName;
+ (NSString *)localDBTimeStringFromServer:(NSString *)remoteTime;
+ (CGSize)stringSizeWithString:(NSString *)str font:(UIFont *)font;
+ (BOOL)isValidPassword:(NSString *)pwd;
+ (void)backToRootViewControllerWithCompletion: (void (^ __nullable)(void))completion;
+ (UIViewController *)appVisibleViewController;

+ (void)appToSystemSettings;
+ (BOOL)checkUserWhetherHaveOwnDevice;

+ (NSArray *)propertiesWithClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
