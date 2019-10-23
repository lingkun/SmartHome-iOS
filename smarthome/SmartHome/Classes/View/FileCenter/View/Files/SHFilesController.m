//
//  SHFilesController.m
//  FileCenter
//
//  Created by ZJ on 2019/10/16.
//  Copyright © 2019 iCatch Technology Inc. All rights reserved.
//

#import "SHFilesController.h"
#import "SHFilesCell.h"
#import "SHFilesViewModel.h"
#import "SVProgressHUD.h"

static void * SHFilesControllerContext = &SHFilesControllerContext;

@interface SHFilesController ()<SHFilesCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *selectNumButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (nonatomic, strong) NSArray<SHS3FileInfo *> *filesList;
@property (nonatomic, strong) SHFilesViewModel *filesViewModel;
@property (nonatomic, assign) BOOL editState;

@end

@implementation SHFilesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0];
    [self setupGUI];
    [self addObserver];
}

- (void)dealloc {
    [self removeObserver];
}

- (void)addObserver {
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(editState)) options:NSKeyValueObservingOptionNew context:SHFilesControllerContext];
    [self.filesViewModel addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedFiles)) options:NSKeyValueObservingOptionNew context:SHFilesControllerContext];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(editState)) context:SHFilesControllerContext];
    [self.filesViewModel removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedFiles)) context:SHFilesControllerContext];
}

#pragma mark - GUI
- (void)setupGUI {
    self.tableView.rowHeight = [SHFilesViewModel filesCellRowHeight];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setupFooterView];
    [self updateSelectNumber];
}

- (void)setupFooterView {
    self.footerView.alpha = self.editState ? 0.85 : 0;
    
    [self.tableView reloadData];
}

- (void)updateSelectNumber {
    [self.selectNumButton setTitle:@(self.filesViewModel.selectedFiles.count).stringValue forState:UIControlStateNormal];
    
    if (self.filesList.count != self.filesViewModel.selectedFiles.count) {
        [self.selectButton setImage:[UIImage imageNamed:@"ic_unselected_white_24dp"] forState:UIControlStateNormal];
        self.selectButton.tag = 0;
    } else {
        [self.selectButton setImage:[UIImage imageNamed:@"ic_select_all_white_24dp"] forState:UIControlStateNormal];
        self.selectButton.tag = 1;
    }
}

#pragma mark - Load Data
- (void)setDateFileInfo:(SHDateFileInfo *)dateFileInfo {
    _dateFileInfo = dateFileInfo;
    
    self.filesList = nil;
    
    [SVProgressHUD showWithStatus:nil];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    WEAK_SELF(self);
    [self.filesViewModel listFilesWithDeviceID:dateFileInfo.deviceID date:dateFileInfo.date completion:^(NSArray<SHS3FileInfo *> * _Nullable filesInfo) {
        [SVProgressHUD dismiss];
        
        weakself.filesList = filesInfo;
    }];
}

- (void)setFilesList:(NSArray<SHS3FileInfo *> *)filesList {
    _filesList = filesList;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SHFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"files" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.dateFileInfo = self.dateFileInfo;
    cell.fileInfo = self.filesList[indexPath.row];
    cell.delegate = self;
    cell.editState = self.editState;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SHS3FileInfo *fileInfo = self.filesList[indexPath.row];

    if (self.editState) {
        fileInfo.selected = !fileInfo.selected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.filesViewModel addSelectedFile:fileInfo];
    } else {
        if (self.didSelectBlock) {
            self.didSelectBlock(fileInfo);
        }
    }
}

#pragma mark - SHFilesCellDelegate
- (void)longPressGestureHandleWithCell:(SHFilesCell *)cell {
    SHLogInfo(SHLogTagAPP, @"longPressGestureHandleWithCell: %@", cell);
    
    if (self.editState == NO) {
        if (self.editStateBlock) {
            self.editStateBlock();
        }
    }
    
    self.editState = YES;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)cancelEditAction {
    self.editState = NO;

    [self clearSelection];
}

- (void)clearSelection {
    [self clearAllSelect];
    [self.filesViewModel clearSelectedFiles];
}

- (void)selectAllFiles {
    [self.filesList enumerateObjectsUsingBlock:^(SHS3FileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = YES;
    }];
}

- (void)clearAllSelect {
    [self.filesList enumerateObjectsUsingBlock:^(SHS3FileInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
}

#pragma mark - Edit Action
- (IBAction)downloadAction:(id)sender {
    
}

- (IBAction)deleteAction:(id)sender {
    
}

- (IBAction)selectAllAction:(UIButton *)sender {
    if (sender.tag == 0) {
        [self selectAllFiles];
        
        [self.filesViewModel clearSelectedFiles];
        [self.filesViewModel addSelectedFiles:self.filesList];
    } else {
        [self clearSelection];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Init
- (SHFilesViewModel *)filesViewModel {
    if (_filesViewModel == nil) {
        _filesViewModel = [[SHFilesViewModel alloc] init];
    }
    
    return _filesViewModel;
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == SHFilesControllerContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(editState))]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupFooterView];
            });
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedFiles))]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateSelectNumber];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
