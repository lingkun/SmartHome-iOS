//
//  SHAppInfoVC.m
//  SmartHome
//
//  Created by ZJ on 2018/1/31.
//  Copyright © 2018年 iCatch Technology Inc. All rights reserved.
//

#import "SHAppInfoVC.h"

static const CGFloat kLogoBottomCons_Default = 30;

@interface SHAppInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *appVersionLab;
@property (weak, nonatomic) IBOutlet UILabel *buildNumberLab;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLab;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLab;
@property (weak, nonatomic) IBOutlet UILabel *appNameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoBottomCons;

@end

@implementation SHAppInfoVC

+ (instancetype)appInfoVC {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kUserAccountStoryboardName bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"AppInfoVCID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupGUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupGUI {
    NSString *appVersion = [NSString stringWithFormat:@"APP Version %@(%@)", APP_VERSION, APP_BUILDNUMBER];
    
    SDKInfo *sdkInfo = SDKInfo::getInstance();
    string sdkVString = sdkInfo->getSDKVersion();
    NSString *sdkVersion = [NSString stringWithFormat:@"SDK Version %s", sdkVString.c_str()];
    _appVersionLab.text = [NSString stringWithFormat:@"%@ \n %@", appVersion, sdkVersion];
    NSUInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]];
    _copyrightLab.text = [NSString stringWithFormat:@"Copyright © 2017-%lu年 iCatch Technology Inc. All rights reserved.", (unsigned long)year];
    _appVersionLab.textColor = [UIColor ic_colorWithHex:kTextThemeColor];
    _copyrightLab.textColor = [UIColor ic_colorWithHex:kTextThemeColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil fontSize:16.0 image:[UIImage imageNamed:@"nav-btn-cancel"] target:self action:@selector(close) isBack:NO];
    _logoBottomCons.constant = kLogoBottomCons_Default * kScreenHeightScale;
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
