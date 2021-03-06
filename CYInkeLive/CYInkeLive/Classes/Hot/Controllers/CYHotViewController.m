//
//  CYHotViewController.m
//  CYInkeLive
//
//  Created by Cyrill on 2017/4/11.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYHotViewController.h"
#import "CYHotTableViewCell.h"
#import "CYNetworkManager.h"
#import <MJExtension.h>
#import "CYLiveModel.h"
#import "CYCreatorModel.h"
#import "CYLiveViewController.h"
#import "CYMainRefrashGifHeader.h"
#import "YKConst.h"
#import "UIView+CYDisplay.h"

@interface CYHotViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;

/** 上次选中的索引(或者控制器) */
@property (nonatomic, assign) NSInteger lastSelectedIndex;

@end

@implementation CYHotViewController {
    BOOL end;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    CYMainRefrashGifHeader *header = [CYMainRefrashGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    [header beginRefreshing];
    self.tableView.mj_header = header;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarSelect) name:CYTabBarDidSelectNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    end = YES;
}

- (void)loadData {
    end = YES;
    [[CYNetworkManager defaultManager] hotListWithParameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.dataArray removeAllObjects];
        NSDictionary *appDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        self.dataArray = [CYLiveModel mj_objectArrayWithKeyValuesArray:appDic[@"lives"]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self myRunLoop];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)myRunLoop {
    [NSThread detachNewThreadSelector:@selector(newThreadFunc) toTarget:self withObject:nil];
}

- (void)newThreadFunc {
    @autoreleasepool {
        end = NO;
        NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
        CFRunLoopObserverContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
        if (observer) {
            CFRunLoopRef cfRunloop = [myRunLoop getCFRunLoop];
            CFRunLoopAddObserver(cfRunloop, observer, kCFRunLoopDefaultMode);
        }
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerprocess) userInfo:nil repeats:YES];
        while (!end) {
            [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
        }
    }
}

- (void)timerprocess {
    [[CYNetworkManager defaultManager] hotListWithParameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.dataArray removeAllObjects];
        NSDictionary *appDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        self.dataArray = [CYLiveModel mj_objectArrayWithKeyValuesArray:appDic[@"lives"]];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

void myRunLoopObserver(CFRunLoopObserverRef observer,CFRunLoopActivity activity,void* info)
{
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before times");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
        default:
            break;
    }
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CYHotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CYHotTableViewCell class])];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CYLiveViewController *liveVc = [[CYLiveViewController alloc] init];
    liveVc.model = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:liveVc animated:YES];
}

- (void)tabBarSelect {
    
    // 判断window是否在窗口上
    if (self.view.window == nil) return;
    // 判断当前的view是否与窗口重合
    if (![self.view cy_intersectsWithAnotherView:nil]) return;
    
    // 如果是连续点击2次，直接刷新
    if (self.lastSelectedIndex == self.tabBarController.selectedIndex && self.tabBarController.selectedViewController == self.navigationController) {
        
        [self.tableView.mj_header beginRefreshing];
    }
    
    // 记录这一次选中的索引
    self.lastSelectedIndex = self.tabBarController.selectedIndex;
}

#pragma mark - lazy
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat navH = statusHeight+navigationHeight;
        CGFloat tabbarHeight = self.tabBarController.tabBar.frame.size.height;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-tabbarHeight-navH) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = [UIScreen mainScreen].bounds.size.width * 1.3 + 1;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[CYHotTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CYHotTableViewCell class])];
    }
    return _tableView;
}

// 最后做内存过高 dealloc 方法
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
