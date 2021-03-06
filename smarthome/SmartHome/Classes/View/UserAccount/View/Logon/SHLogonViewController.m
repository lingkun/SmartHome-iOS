//
//  SHLogonVC.m
//  SHAccountsManagement
//
//  Created by ZJ on 2018/3/5.
//  Copyright © 2018年 iCatch Technology Inc. All rights reserved.
//

#import "SHLogonViewController.h"
#import "SHNetworkManagerHeader.h"
#import "SHLoginViewController.h"
#import "SHMainViewController.h"
#import "UnderLineTextField.h"

static const CGFloat kBottomDefaultValue = 70;
static const CGFloat kVerifycodeExpirydate = 300;
static const CGFloat kVerifycodeBtnDefaultFontSize = 12.0;
static const CGFloat kVerifycodeBtnDisableFontSize = 16.0;
static const CGFloat kPhoneVerifycodeExpirydate = 60;

@interface SHLogonViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pwdInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *logonButton;
@property (weak, nonatomic) IBOutlet UILabel *agreeDesLabel;
@property (weak, nonatomic) IBOutlet UIButton *userAgreementButton;
@property (weak, nonatomic) IBOutlet UIButton *pricacyPolicyButton;
@property (weak, nonatomic) IBOutlet UILabel *andLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupBtnBottomCons;

@property (weak, nonatomic) IBOutlet UnderLineTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UnderLineTextField *verifycodeTextField;
@property (weak, nonatomic) IBOutlet UnderLineTextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UnderLineTextField *surePWDTextField;
@property (weak, nonatomic) IBOutlet UIButton *getVerifycodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@property (nonatomic) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSTimer *verifycodeTimer;
@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation SHLogonViewController

+ (instancetype)logonViewController {
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:kUserAccountStoryboardName bundle:nil];
    return mainStory.instantiateInitialViewController;
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEnterAPMode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLocalizedString];

    [self initParameter];
    [self setupGUI];
    [self addGestureOperation];
    [self noNeedExitAppHandle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNeedExitAppHandle) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)noNeedExitAppHandle {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEnterAPMode];
}

- (void)initParameter {
    if (_resetPWD) {
        [_logonButton setTitle:NSLocalizedString(@"kResetPassword", nil) forState:UIControlStateNormal];
        [_logonButton setTitle:NSLocalizedString(@"kResetPassword", nil) forState:UIControlStateHighlighted];
        
        _agreeDesLabel.hidden = YES;
        _userAgreementButton.hidden = YES;
        _andLabel.hidden = YES;
        _signinButton.hidden = YES;
    }
    
    _emailTextField.text = _email;
    _totalTime = kVerifycodeExpirydate;
}

- (void)setupGUI {
    [_logonButton setCornerWithRadius:_logonButton.bounds.size.height * 0.25 masksToBounds:NO];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil target:self action:@selector(close) isBack:YES];
    
    _signupBtnBottomCons.constant = kBottomDefaultValue * kScreenHeightScale;
    
    [_getVerifycodeBtn setCornerWithRadius:_getVerifycodeBtn.bounds.size.height * 0.25 masksToBounds:NO];

    _emailTextField.delegate = self;
    _verifycodeTextField.delegate = self;
    _pwdTextField.delegate = self;
    _surePWDTextField.delegate = self;
    
    [_emailTextField addTarget:self action:@selector(updateVerifycodeBtnState) forControlEvents:UIControlEventEditingChanged];
    
    UIColor *color = [UIColor ic_colorWithHex:kButtonThemeColor];
    _emailTextField.lineColor = color;
    _verifycodeTextField.lineColor = color;
    _pwdTextField.lineColor = color;
    _surePWDTextField.lineColor = color;
    
    [self updateVerifycodeBtnState];
    
    self.navigationItem.titleView = [UIImageView imageViewWithImage:[[UIImage imageNamed:@"nav-logo"] imageWithTintColor:[UIColor whiteColor]] gradient:NO];
    [self addLineForTermsBtn];
    [self addLineForSigninBtn];
    
    _agreeDesLabel.textColor = [UIColor ic_colorWithHex:kTextThemeColor];
    _andLabel.textColor = [UIColor ic_colorWithHex:kTextThemeColor];
    [self setupSignupState];
}

- (void)setupLocalizedString {
    _emailTextField.placeholder = NSLocalizedString(@"kEmail", nil);
    _verifycodeTextField.placeholder = NSLocalizedString(@"kVerifycode", nil);
    [_getVerifycodeBtn setTitle:NSLocalizedString(@"kGetVerifycode", nil) forState:UIControlStateNormal];
    [_getVerifycodeBtn setTitle:NSLocalizedString(@"kGetVerifycode", nil) forState:UIControlStateHighlighted];
    _pwdTextField.placeholder = NSLocalizedString(@"kPassword", nil);
    _surePWDTextField.placeholder = NSLocalizedString(@"kEnterPasswordAgain", nil);
    [_logonButton setTitle:NSLocalizedString(@"kSignupWithEmail", nil) forState:UIControlStateNormal];
    [_logonButton setTitle:NSLocalizedString(@"kSignupWithEmail", nil) forState:UIControlStateHighlighted];
    [_userAgreementButton setTitle:NSLocalizedString(@"kTerms", nil) forState:UIControlStateNormal];
    [_userAgreementButton setTitle:NSLocalizedString(@"kTerms", nil) forState:UIControlStateHighlighted];
    [_signinButton setTitle:NSLocalizedString(@"kLogin", nil) forState:UIControlStateNormal];
    [_signinButton setTitle:NSLocalizedString(@"kLogin", nil) forState:UIControlStateHighlighted];
    _agreeDesLabel.text = NSLocalizedString(@"kAgreeTermsDes", nil);
    _andLabel.text = NSLocalizedString(@"kAlreadyHaveAnAccount", nil);
    
    [_userAgreementButton layoutIfNeeded];
    [_signinButton layoutIfNeeded];
    [_agreeDesLabel layoutIfNeeded];
    [_andLabel layoutIfNeeded];
}

- (void)addLineForTermsBtn {
    [_userAgreementButton setTintColor:[UIColor ic_colorWithHex:kTextThemeColor]];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _userAgreementButton.frame.size.height - 2, _userAgreementButton.frame.size.width, 1)];
    line.backgroundColor = _userAgreementButton.currentTitleColor;
    
    [_userAgreementButton addSubview:line];
}

- (void)addLineForSigninBtn {
    [_signinButton setTintColor:[UIColor ic_colorWithHex:kTextThemeColor]];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _signinButton.frame.size.height - 2, _signinButton.frame.size.width, 1)];
    line.backgroundColor = _signinButton.currentTitleColor;
    
    [_signinButton addSubview:line];
}

- (void)close {
    [_emailTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_surePWDTextField resignFirstResponder];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[ZJSlidingDrawerViewController sharedSlidingDrawerVC] popViewController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    [self releaseVerifycodeTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logonClick:(id)sender {
    NSString *notice = _resetPWD ? NSLocalizedString(@"kResetPasswording", nil) : NSLocalizedString(@"kSignuping", nil);
    
    [self accountHandleWithTipsTitle:notice];
}
- (void)showTipsWithInfo:(NSString *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hideProgressHUD:YES];
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:info preferredStyle:UIAlertControllerStyleAlert];
        [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertC animated:YES completion:nil];
    });
}

- (NSString *)accountRegularExpression {
    NSString *account = [NSString stringWithFormat:@"%@|%@", kPhoneRegularExpression, kEmailRegularExpression];
    
    return account;
}

- (void)accountHandleWithTipsTitle:(NSString *)tips {
    [_emailTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_surePWDTextField resignFirstResponder];
    [_verifycodeTextField resignFirstResponder];
    
    self.progressHUD.detailsLabelText = nil;
    [self.progressHUD showProgressHUDWithMessage:tips];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (![self isValidInput]) {
            SHLogWarn(SHLogTagAPP, @"Input content invalid.");
        } else {
            __block NSString *email = nil;
            __block NSString *password = nil;
            __block NSString *surePWD = nil;
            __block NSString *checkCode = nil;
            dispatch_sync(dispatch_get_main_queue(), ^{
                email = _emailTextField.text;
                password = _pwdTextField.text;
                surePWD = _surePWDTextField.text;
                checkCode = _verifycodeTextField.text;
            });
            
            if (![password isEqualToString:surePWD]) {
                [self showTipsWithInfo:NSLocalizedString(@"kEnterAccoutPasswordDisagree", nil)];
                return;

            }
            if (_resetPWD) {
                [self resetPasswordWithEmail:email password:password checkCode:checkCode failedNotice:NSLocalizedString(@"kResetPasswordFailed", nil)];
            } else {
                [self signupWithEmail:email password:password checkCode:checkCode failedNotice:NSLocalizedString(@"kSignupFailed", nil)];
            }
        }
    });
}

- (BOOL)isValidInput {
    __block BOOL valid = YES;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSRange emailRange = [_emailTextField.text rangeOfString:[self accountRegularExpression] options:NSRegularExpressionSearch];
        
        if (emailRange.location == NSNotFound) {
            [self showTipsWithInfo:[NSString stringWithFormat:NSLocalizedString(@"kInvalidEmailOrPassword", nil), kPasswordMinLength, kPasswordMaxLength]];
            
            valid = NO;
            SHLogError(SHLogTagAPP, @"Input email or phone-number invalid.");
            return;
        }
        
        NSInteger verifyLength = _verifycodeTextField.text.length;
        if (verifyLength != 6) {
            NSString *errInfo = NSLocalizedString(@"kInvalidVerifycode", nil);
            
            if (verifyLength == 0) {
                errInfo = NSLocalizedString(@"kEnterVerifycode", nil);
            }
            
            [self showTipsWithInfo:errInfo];
            
            valid = NO;
            SHLogError(SHLogTagAPP, @"Input verify code invalid.");
            return;
        }
        
        if (![SHTool isValidPassword:_pwdTextField.text]) {
            [self showTipsWithInfo:[NSString stringWithFormat:NSLocalizedString(@"kAccountPasswordDes", nil), kPasswordMinLength, kPasswordMaxLength]];
            
            valid = NO;
            SHLogError(SHLogTagAPP, @"Input password invalid.");
            return;
        }
        
        if (![SHTool isValidPassword:_surePWDTextField.text]) {
            [self showTipsWithInfo:[NSString stringWithFormat:NSLocalizedString(@"kAccountPasswordDes", nil), kPasswordMinLength, kPasswordMaxLength]];
            
            valid = NO;
            SHLogError(SHLogTagAPP, @"Input sure password invalid.");
            return;
        }
    });
    
    return valid;
}

- (void)signupWithEmail:(NSString *)email password:(NSString *)password checkCode:(NSString *)checkCode failedNotice:(NSString *)failedNotice {
    WEAK_SELF(self);
    [[SHNetworkManager sharedNetworkManager] logonWithUserName:email email:email password:password checkCode:checkCode completion:^(BOOL isSuccess, id result) {
        SHLogInfo(SHLogTagAPP, @"logon is success: %d", isSuccess);
        
        if (isSuccess) {
            [weakself loginHandle];
        } else {
            Error *error = result;
            
            weakself.progressHUD.detailsLabelText = [SHNetworkRequestErrorDes errorDescriptionWithCode:error.error_code]; //error.error_description;

            NSString *notice = failedNotice;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.progressHUD showProgressHUDNotice:notice showTime:2.0];
            });
            
            SHLogError(SHLogTagAPP, @"Signup failed: %@", error.error_description);
        }
    }];
}

- (void)resetPasswordWithEmail:(NSString *)email password:(NSString *)password checkCode:(NSString *)checkCode failedNotice:(NSString *)failedNotice {
    WEAK_SELF(self);
    [[SHNetworkManager sharedNetworkManager] resetPwdWithEmail:email andPassword:password andCode:checkCode completion:^(BOOL isSuccess, id  _Nonnull result) {
        SHLogInfo(SHLogTagAPP, @"resetPassword is success: %d", isSuccess);
        
        if (isSuccess) {
            [weakself loginHandle];
        } else {
            Error *error = result;
            
            weakself.progressHUD.detailsLabelText = [SHNetworkRequestErrorDes errorDescriptionWithCode:error.error_code]; //error.error_description;
            NSString *notice = failedNotice;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.progressHUD showProgressHUDNotice:notice showTime:2.0];
            });
            
            SHLogError(SHLogTagAPP, @"Reset passwrod failed: %@", error.error_description);
        }
    }];
}

- (void)loginHandle {
    self.progressHUD.detailsLabelText = nil;
    [self.progressHUD showProgressHUDWithMessage:NSLocalizedString(@"kLogining", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *email = nil;
        __block NSString *password = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            email = _emailTextField.text;
            password = _pwdTextField.text;
        });
        
        WEAK_SELF(self);
        [[SHNetworkManager sharedNetworkManager] loadAccessTokenByEmail:email password:password completion:^(BOOL isSuccess, id result) {
            SHLogInfo(SHLogTagAPP, @"load accessToken is success: %d", isSuccess);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    [weakself.progressHUD hideProgressHUD:YES];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"needSyncDataFromServer"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                    [[ZJSlidingDrawerViewController sharedSlidingDrawerVC] closeLoginFirstView];
                } else {
                    Error *error = result;
                    SHLogError(SHLogTagAPP, @"loadAccessTokenByEmail is failed, error: %@", error.error_description);
                    
                    weakself.progressHUD.detailsLabelText = [SHNetworkRequestErrorDes errorDescriptionWithCode:error.error_code]; //error.error_description;
                    NSString *notice = NSLocalizedString(@"kLoginFailed", nil);
                    [weakself.progressHUD showProgressHUDNotice:notice showTime:2.0];
                }
                
                [weakself close];
            });
        }];
    });
}

- (IBAction)userAgreeClick:(UIButton *)sender {
    sender.tag = !sender.tag;
    _logonButton.enabled = sender.tag;
    
    NSString *imageName = sender.tag ? @"ic_check_box_blue_400_24dp" : @"ic_check_box_outline_blank_blue_400_24dp";
    UIImage *image = [UIImage imageNamed:imageName];
    [sender setImage:image forState:UIControlStateNormal];
    [sender setImage:image forState:UIControlStateHighlighted];
    
    uint32_t colorValue = sender.tag ? kButtonThemeColor : kButtonDefaultColor;
    _logonButton.backgroundColor = [UIColor ic_colorWithHex:colorValue];
}

- (IBAction)signinClick {
    [self close];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ZJSlidingDrawerViewController sharedSlidingDrawerVC] signinAccountHandle];
    });
}

- (IBAction)getVerifycodeClick:(id)sender {
    [self sendCheckEmailValidCommand];
}

- (IBAction)showpasswordClick:(UIButton *)sender {
    UITextField *textField = !sender.tag ? _pwdTextField : _surePWDTextField;
    textField.secureTextEntry = !textField.secureTextEntry;
    
    NSString *imageName = textField.secureTextEntry ? @"ic_visibility_off_18dp" : @"ic_visibility_18dp";
    [sender setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

- (void)updateVerifycodeBtnState {
    uint32_t colorValue = ![_emailTextField.text isEqualToString:@""] ? kButtonThemeColor : kButtonDefaultColor;
    _getVerifycodeBtn.backgroundColor = [UIColor ic_colorWithHex:colorValue];
}

#pragma mark - Action Progress
- (MBProgressHUD *)progressHUD {
    if (_progressHUD == nil) {
        _progressHUD = [MBProgressHUD progressHUDWithView:self.view.window];
    }
    
    return _progressHUD;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.verifycodeTextField becomeFirstResponder];
    } else if (textField == self.verifycodeTextField) {
        [self.pwdTextField becomeFirstResponder];
    } else if (textField == self.pwdTextField) {
        [self.surePWDTextField becomeFirstResponder];
    } else if (textField == self.surePWDTextField) {
        [self logonClick:nil];
    }
    
    [textField resignFirstResponder];

    [self setupSignupState];
    
    return YES;
}

- (void)setupSignupState {
    _logonButton.enabled = ![_emailTextField.text isEqualToString:@""] && ![_verifycodeTextField.text isEqualToString:@""] && ![_pwdTextField.text isEqualToString:@""] && ![_surePWDTextField.text isEqualToString:@""];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - SHUserAccountCellProtocol
-(void)sendCheckEmailValidCommand
{
    //1 检测邮件的格式是否正确
 
    [_emailTextField resignFirstResponder];
    __block NSRange emailRange;
    
    self.progressHUD.detailsLabelText = nil;
    [self.progressHUD showProgressHUDWithMessage:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            emailRange = [_emailTextField.text rangeOfString:[self accountRegularExpression] options:NSRegularExpressionSearch];
        });
        
        if (emailRange.location == NSNotFound ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressHUD hideProgressHUD:YES];
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"kInvalidEmail", nil) preferredStyle:UIAlertControllerStyleAlert];
                [alertC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", nil) style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertC animated:YES completion:nil];
            });
        } else {
            __block NSString *email = nil;
           
            dispatch_sync(dispatch_get_main_queue(), ^{
                email = _emailTextField.text;
            });
            
            [self verifycodeHandle:email];
        }
    });
    //2 发送验证邮箱有效性的请求
}

- (void)verifycodeHandle:(NSString *)email {
    NSRange range = [email rangeOfString:kPhoneRegularExpression options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        _totalTime = kPhoneVerifycodeExpirydate;
    }
    
    _resetPWD ? [self resetPasswordGetVerifyCodeWithEmail:email] : [self getVerifyCodeWithEmail:email];
}

- (void)getVerifyCodeWithEmail:(NSString *)email {
    WEAK_SELF(self);
    [[SHNetworkManager sharedNetworkManager] getVerifyCodeWithEmail:email completion:^(BOOL isSuccess, id  _Nonnull result) {
        SHLogInfo(SHLogTagAPP, @"send check email valid is success: %d", isSuccess);
        
        [weakself getVerifycodeFailedTips:result isSuccess:isSuccess];
    }];
}

- (void)resetPasswordGetVerifyCodeWithEmail:(NSString *)email {
    WEAK_SELF(self);
    [[SHNetworkManager sharedNetworkManager] resetPwdGetVerifyCodeWithEmail:email completion:^(BOOL isSuccess, id  _Nonnull result) {
        SHLogInfo(SHLogTagAPP, @"send check email valid is success: %d", isSuccess);
        
        [weakself getVerifycodeFailedTips:result isSuccess:isSuccess];
    }];
}

- (void)getVerifycodeFailedTips:(id)result isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *notice = NSLocalizedString(@"Tips", nil);
        self.progressHUD.detailsLabelText = NSLocalizedString(@"kVerifycodeAlreadySend", nil);

        if (success) {
            _getVerifycodeBtn.enabled = NO;
            _getVerifycodeBtn.titleLabel.font = [UIFont systemFontOfSize:kVerifycodeBtnDisableFontSize];
            
            [self updateVerifycodeBtnTitle:[NSString stringWithFormat:@"%.0fs", _totalTime]];
            [self verifycodeTimer];
        } else {
            Error *error = result;
            
            self.progressHUD.detailsLabelText = [SHNetworkRequestErrorDes errorDescriptionWithCode:error.error_code]; //error.error_description;
            notice = NSLocalizedString(@"kVerifycodeSendFailed", nil);
            SHLogError(SHLogTagAPP, @"Get Verifycode Failed: %@", error.error_description);
        }
        
        [self.progressHUD showProgressHUDNotice:notice showTime:2.0];
    });
}

// MARK: - verifycodeTimer
- (NSTimer *)verifycodeTimer {
    if (_verifycodeTimer == nil) {
        _verifycodeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateVerifycodeTime) userInfo:nil repeats:YES];
    }
    
    return _verifycodeTimer;
}

- (void)releaseVerifycodeTimer {
    if (_verifycodeTimer.valid) {
        [_verifycodeTimer invalidate];
        _verifycodeTimer = nil;
    }
}

- (void)updateVerifycodeTime {
    _totalTime--;
    
    [self updateVerifycodeBtnTitle:[NSString stringWithFormat:@"%.0fs", _totalTime]];
    
    if (_totalTime == 0) {
        _getVerifycodeBtn.enabled = YES;
        _getVerifycodeBtn.titleLabel.font = [UIFont systemFontOfSize:kVerifycodeBtnDefaultFontSize];

        [self updateVerifycodeBtnTitle:NSLocalizedString(@"kGetVerifycode", nil)];
        
        [self releaseVerifycodeTimer];
        
        _totalTime = kVerifycodeExpirydate;
    }
}

- (void)updateVerifycodeBtnTitle:(NSString *)title {
    [_getVerifycodeBtn setTitle:title forState:UIControlStateNormal];
    [_getVerifycodeBtn setTitle:title forState:UIControlStateHighlighted];
}

- (void)addGestureOperation  {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)tapGestureHandle {
    [self.view endEditing:YES];
}

@end

