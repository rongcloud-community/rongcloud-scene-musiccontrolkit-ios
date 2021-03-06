//
//  RCMusicContainerViewController.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicContainerViewController.h"
#import "RCMusicToolBarItem.h"
#import "RCMusicToolBar.h"
#import "UIImage+RCMusicControl.h"
#import <Masonry/Masonry.h>
#import "RCMusicLocalViewController.h"
#import "RCMusicRemoteViewController.h"
#import "RCMusicControlViewController.h"
#import "RCMusicSoundEffectToolView.h"
#import "RCMusicDefine.h"
#import "RCMusicEngine.h"
#import "RCMusicEffectInfo.h"
#import "RCMusicToolBarAppearance.h"
#import "RCMusicControlKitConfig.h"
#import "RCMusicThemeAppearance.h"
#import "RCMusicSoundEffectAppearance.h"

#define rcm_Player [RCMusicEngine shareInstance].player
#define rcm_DataSource [RCMusicEngine shareInstance].dataSource

@interface RCMusicContainerViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) RCMusicToolBar *toolBar;
@property (nonatomic, strong) RCMusicToolBarAppearance *appearance;
@property (nonatomic, strong) RCMusicThemeAppearance *bgAppearance;
@property (nonatomic, strong) RCMusicSoundEffectAppearance *soundEffectAppearance;
@property (nonatomic, strong) RCMusicSoundEffectToolView *soundEffectView;
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) RCMusicPageType currentPageType;
@property (nonatomic, copy) NSArray<RCMusicEffectInfo> *effects;
@property (nonatomic, strong) UIView *container;
@end

@implementation RCMusicContainerViewController

- (void)dealloc {
    NSLog(@"RCMusicContainerViewController dealloc");
}

- (instancetype)init {
    if (self = [super init]) {
        //设置 present 模式 和动画
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    //默认展示本地收藏音乐页面
    self.currentPageType = RCMusicPageTypeLocalData;
    //获取音乐特效数据
    if ([rcm_DataSource respondsToSelector:@selector(fetchSoundEffectsWithCompletion:)]) {
        [rcm_DataSource fetchSoundEffectsWithCompletion:^(NSArray<RCMusicEffectInfo> * _Nullable effects) {
            self.effects = effects;
        }];
    }
}

#pragma mark - ITEM ACTIONS
//Tool Bar View Action
//切换到本地收藏页面
- (void)showLocalList {
    NSLog(@"show local list");
    self.currentPageType = RCMusicPageTypeLocalData;
}

//切换到在线音乐
- (void)showRemoteList {
    NSLog(@"show remote list");
    self.currentPageType = RCMusicPageTypeRemoteData;
}

//切换到音乐控制
- (void)showMusicControl {
    NSLog(@"show control");
    self.currentPageType = RCMusicPageTypeControl;
}

//弹出特效音乐 bar
- (void)soundEffectClick {
    NSLog(@"effect click");
    if (self.effects == nil || self.effects.count == 0) {
        return;
    }
    self.soundEffectView.hidden = !self.soundEffectView.hidden;
    if (!self.soundEffectView.hidden) {
        self.soundEffectView.items = self.effects;
    }
}

//点击空白区域取dismiss
- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Self Delegate
//跳转页面
- (void)jumpToViewControllerWithPageType:(RCMusicPageType)pageType {
    self.currentPageType = pageType;
}

#pragma mark LAYOUT SUBVIEWS

- (void)buildChildViewControllers {
    
    UIView *contentView = [[UIView alloc] init];
    
    [self.scrollView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.height.equalTo(self.scrollView);
    }];
    
    RCMusicLocalViewController *local = [[RCMusicLocalViewController alloc] init];
    local.delegate = self;
    
    RCMusicRemoteViewController *remote = [[RCMusicRemoteViewController alloc] init];
    
    NSArray *viewControllers;
    
    if (self.appearance.turnOnMusicControl) {
        RCMusicControlViewController *control = [[RCMusicControlViewController alloc] init];
        viewControllers = @[local,remote,control];
    } else {
        viewControllers = @[local,remote];
    }
    
    UIView *previousView =nil;
    
    for (int i = 0; i <viewControllers.count; i++) {
        
        UIViewController *vc = viewControllers[i];
        
        [self addChildViewController:vc];
        
        [contentView addSubview:vc.view];
        
        [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(contentView);
            make.width.equalTo(self.scrollView);
            if (previousView) {
                make.leading.mas_equalTo(previousView.mas_trailing);
            }
            else {
                make.leading.mas_equalTo(0);
            }
        }];
        
        previousView = vc.view;
        
        [vc didMoveToParentViewController:self];
    }
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(previousView.mas_trailing);
    }];
}

- (void)addTapView {
    UIView *tapView = [[UIView alloc] init];
    tapView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)];
    [tapView addGestureRecognizer:tap];
    [self.view addSubview:tapView];
    [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)buildLayout {
    
    [self addTapView];
    
    [self.view addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.width.mas_equalTo(self.bgAppearance.size.width);
        make.height.mas_equalTo(self.bgAppearance.size.height + 100);
    }];
    
    [self.container addSubview:self.soundEffectView];
    [self.soundEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container);
        make.leading.equalTo(self.container).offset(4);
        make.trailing.equalTo(self.container).offset(-4);
        make.height.mas_equalTo(self.soundEffectAppearance.size.height);
    }];
    
    [self.container addSubview:self.toolBar];
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.soundEffectView.mas_bottom).offset(4);
        make.leading.trailing.equalTo(self.container);
        make.height.mas_equalTo(50);
    }];
    
    [self.container addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.container);
        make.top.equalTo(self.toolBar.mas_bottom);
    }];
    
    [self.container addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBar.mas_bottom);
        make.leading.bottom.trailing.equalTo(self.container);
        make.width.equalTo(self.container);
    }];
    
    [self buildChildViewControllers];
}

#pragma mark -GETTER

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)container {
    if (_container == nil) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
    }
    return _container;
}
//初始化 tool bar items
- (RCMusicToolBar *)toolBar {
    if (_toolBar == nil) {
        RCMusicToolBarItem *item1 = [self createItemWithItem:self.appearance.items[0] record:YES selector:@selector(showLocalList)];
        RCMusicToolBarItem *item2 = [self createItemWithItem:self.appearance.items[1] record:YES selector:@selector(showRemoteList)];
        RCMusicToolBarItem *item3 = [self createItemWithItem:self.appearance.items[2] record:YES selector:@selector(showMusicControl)];
        RCMusicToolBarItem *item4 = [self createItemWithItem:self.appearance.items[3] record:NO selector:@selector(soundEffectClick)];
        NSMutableArray *leftItems = [@[item1,item2] mutableCopy];
        NSMutableArray *rightItems = [@[] mutableCopy];
        if (self.appearance.turnOnMusicControl) {
            [leftItems addObject:item3];
        }
        if (self.appearance.turnOnSoundEffect && [rcm_DataSource respondsToSelector:@selector(fetchSoundEffectsWithCompletion:)]) {
            [rightItems addObject:item4];
        }
        _toolBar = [[RCMusicToolBar alloc] initWithLeftItems:[leftItems copy] rightItems:[rightItems copy]];
    }
    return _toolBar;
}

- (RCMusicToolBarItem *)createItemWithItem:(NSDictionary<NSString*,NSString*> *)itemData record:(BOOL)record selector:(SEL)selector {
    RCMusicToolBarItem *item = [[RCMusicToolBarItem alloc] initWithNormalImagePath:itemData[kNormalLocalKey] normalImageUrl:itemData[kNormalRemoteKey] selectedImagePath:itemData[kSelectedLocalKey] selectedImageUrl:itemData[kSelectedRemoteKey] record:record target:self action:selector];
    return item;
}

- (UIVisualEffectView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        _backgroundView.alpha = 0.90;
        _backgroundView.backgroundColor = self.bgAppearance.backgroundColor;
    }
    return _backgroundView;
}

- (RCMusicSoundEffectToolView *)soundEffectView {
    if (_soundEffectView == nil) {
        _soundEffectView = [[RCMusicSoundEffectToolView alloc] init];
        _soundEffectView.layer.masksToBounds = YES;
        _soundEffectView.layer.cornerRadius = self.soundEffectAppearance.radius ?: 6;
        _soundEffectView.hidden = YES;
        [_soundEffectView setItemClick:^(id<RCMusicEffectInfo>  _Nonnull info) {
            if (info.filePath) {
                [rcm_Player playEffect:info.soundId filePath:info.filePath];
            }
        }];
    }
    return _soundEffectView;
}

- (RCMusicToolBarAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicToolBarAppearance alloc] init];
    }
    return _appearance;
}

- (RCMusicThemeAppearance *)bgAppearance {
    if (_bgAppearance == nil) {
        _bgAppearance = [[RCMusicThemeAppearance alloc] init];
    }
    return _bgAppearance;
}

- (RCMusicSoundEffectAppearance *)soundEffectAppearance {
    if (_soundEffectAppearance == nil) {
        _soundEffectAppearance = [[RCMusicSoundEffectAppearance alloc] init];
    }
    return _soundEffectAppearance;
}
#pragma mark - SETTER

- (void)setCurrentPageType:(RCMusicPageType)currentPageType {
    _currentPageType = currentPageType;
    for (int i = 0; i < self.toolBar.leftItems.count; i++) {
        if (currentPageType == i) {
            RCMusicToolBarItem *item = self.toolBar.leftItems[i];
            item.selected = YES;
            break;
        }
    }
    CGFloat  width = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:.3f animations:^{
        [self.scrollView setContentOffset:CGPointMake(width*currentPageType, 0)];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPageType = scrollView.contentOffset.x/self.scrollView.bounds.size.width;
}
@end
