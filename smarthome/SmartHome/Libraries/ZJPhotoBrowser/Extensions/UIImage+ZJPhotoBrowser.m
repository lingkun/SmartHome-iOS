//
//  UIImage+ZJPhotoBrowser.m
//  ZJPhotoBrowserTest
//
//  Created by ZJ on 2018/6/1.
//  Copyright © 2018年 iCatch Technology Inc. All rights reserved.
//

#import "UIImage+ZJPhotoBrowser.h"

@implementation UIImage (ZJPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
}

@end
