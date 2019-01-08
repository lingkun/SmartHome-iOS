//
//  FRDFaceInfoViewModel.m
//  FaceRecognition
//
//  Created by ZJ on 2018/9/17.
//  Copyright © 2018年 iCatch Technology Inc. All rights reserved.
//

#import "FRDFaceInfoViewModel.h"
#import "SVProgressHUD.h"
#import "SHNetworkManager+SHFaceHandle.h"
#import "FRDCommonHeader.h"

@interface FRDFaceInfoViewModel ()

@property (nonatomic, strong) NSArray<FRDFaceInfo *> *facesInfoArray;

@end

@implementation FRDFaceInfoViewModel

- (void)loadFacesInfoWithCompletion:(FaceInfoViewModelCompletion _Nullable)completion {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    WEAK_SELF(self);
    [[SHNetworkManager sharedNetworkManager] getFacesInfoWithName:nil finished:^(id  _Nullable result, ZJRequestError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.error];
                [SVProgressHUD dismissWithDelay:2.0];
            } else {
                NSArray *faceInfoArray = (NSArray *)result;
                
                NSMutableArray *faceInfoModelMArray = [NSMutableArray arrayWithCapacity:faceInfoArray.count];
                [faceInfoArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    FRDFaceInfo *faceInfo = [FRDFaceInfo faceInfoWithDict:obj];
                    [faceInfoModelMArray addObject:faceInfo];
                }];
                
                weakself.facesInfoArray = faceInfoModelMArray.copy;
                
//                [weakself.tableView reloadData];
                
                [weakself saveFacesInfoToLocal:result];
                
                if (completion) {
                    completion();
                }
            }
        });
    }];
}

- (void)saveFacesInfoToLocal:(NSArray *)faces {
    [[NSUserDefaults standardUserDefaults] setObject:faces forKey:kLocalFacesInfo];
}

@end