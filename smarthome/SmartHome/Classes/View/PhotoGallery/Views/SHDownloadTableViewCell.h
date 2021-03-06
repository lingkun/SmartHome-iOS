//
//  SHDownloadTableViewCell.h
//  SmartHome
//
//  Created by ZJ on 2017/6/8.
//  Copyright © 2017年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHDownloadProgressView.h"

@class SHDownloadTableViewCell;
@protocol SHDownloadTableViewCellDelegate <NSObject>

- (void)cancelDownloadHandler:(SHDownloadTableViewCell *)cell;

@end

@interface SHDownloadTableViewCell : UITableViewCell

@property (nonatomic) SHFile *file;
@property (nonatomic) SHCameraObject *shCamObj;
@property (nonatomic ,weak) SHDownloadProgressView *progressView;
@property (nonatomic) void (^downloadCompleteBlock)(SHDownloadTableViewCell *dcell);
@property (nonatomic, assign) int downloadInfo;
@property (nonatomic) void (^cancelDownloadSuccessBlock)(SHDownloadTableViewCell *dcell);
@property (nonatomic) void (^cancelDownloadFailedBlock)();
@property (nonatomic) void (^cancelDownloadPrepareBlock)();

@property (nonatomic, weak) id<SHDownloadTableViewCellDelegate> delegate;

- (void)updateProgress:(NSInteger)progress;

@end
