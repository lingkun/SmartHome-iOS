//
//  SHFilesCell.m
//  FileCenter
//
//  Created by ZJ on 2019/10/16.
//  Copyright © 2019 iCatch Technology Inc. All rights reserved.
//

#import "SHFilesCell.h"
#import "SHENetworkManagerCommon.h"

@interface SHFilesCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recodTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *recodTypeLabel;

@end

@implementation SHFilesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self addGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPress];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(longPressGestureHandleWithCell:)]) {
        [self.delegate longPressGestureHandleWithCell:self];
    }
}

- (void)setDateFileInfo:(SHDateFileInfo *)dateFileInfo {
    _dateFileInfo = dateFileInfo;
    
//    self.deviceNameLabel.text = dateFileInfo.dateString;
    _deviceNameLabel.text = [[SHCameraManager sharedCameraManger] getCameraObjectWithDeviceID:dateFileInfo.deviceID].camera.cameraName;
}

- (void)setFileInfo:(SHS3FileInfo *)fileInfo {
    _fileInfo = fileInfo;
    
    _recodTimeLabel.text = fileInfo.datetime;
    _lengthLabel.text = [NSString translateSecsToString1:fileInfo.duration.integerValue];
    _recodTypeLabel.text = [self translateMonitorType:fileInfo.monitor.intValue];
    _thumbnailImgView.image = [fileInfo.thumbnail ic_cornerImageWithSize:_thumbnailImgView.bounds.size radius:kImageCornerRadius];
    _selectImgView.image = fileInfo.selected ? [UIImage imageNamed:@"ic_done_red_24dp"] : [UIImage imageNamed:@"ic_done_gray_24dp"];
    self.backgroundColor = fileInfo.selected ? [UIColor ic_colorWithHex:kBackgroundThemeColor] : self.superview.backgroundColor;
}

- (void)setEditState:(BOOL)editState {
    _selectImgView.hidden = !editState;
}

- (NSString *)translateMonitorType:(int)type {
    NSString *str = nil;
    
    switch (type) {
        case ICH_FILE_MONITOR_TYPE_ALL:
            str = @"All";
            break;
        case ICH_FILE_MONITOR_TYPE_AUDIO:
            str = @"Audio";
            break;
        case ICH_FILE_MONITOR_TYPE_MANUALLY:
            str = NSLocalizedString(@"kMonitorTypeManually", nil);
            break;
        case ICH_FILE_MONITOR_TYPE_PIR:
            str = NSLocalizedString(@"kMonitorTypePir", nil);
            break;
        case ICH_FILE_MONITOR_TYPE_RING:
            str = NSLocalizedString(@"kMonitorTypeRing", nil);
            break;
        case ICH_FILE_MONITOR_TYPE_UNKNOWN:
            str = @"Unknown";
            break;
            
        default:
            break;
    }
    
    return str;
}

@end
