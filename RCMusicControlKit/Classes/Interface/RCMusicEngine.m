//
//  RCMusicEngine.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import "RCMusicEngine.h"
#import "RCMusicContainerViewController.h"
#import "RCMusicDefine.h"
#import "RCMusicInfoBubbleView.h"
NSString *const RCMusicLocalDataChangedNotification = @"RCMusicLocalDataChangedNotification";
@interface RCMusicEngine ()
@property (nonatomic, weak) UIViewController *targetViewController;
@end

@implementation RCMusicEngine

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static RCMusicEngine *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicEngine alloc] init];
    });
    return instance;
}

- (void)setPlayer:(id<RCMusicPlayer>)player {
    _player = player;
    if (player && [player respondsToSelector:@selector(playerInitialized)]) {
        [player playerInitialized];
    }
}

- (void)setDelegate:(id<RCMusicEngineDelegate>)delegate {
    _delegate = delegate;
    if (delegate && [delegate respondsToSelector:@selector(delegateInitialized)]) {
        [delegate delegateInitialized];
    }
}

- (void)setDataSource:(id<RCMusicEngineDataSource>)dataSource {
    _dataSource = dataSource;
    if (dataSource && [dataSource respondsToSelector:@selector(dataSourceInitialized)]) {
        [dataSource dataSourceInitialized];
    }
}

- (void)showInViewController:(nonnull UIViewController *)viewController completion:(void (^)(void))completion {
    self.targetViewController = viewController;
    if (viewController != nil) {
        RCMusicContainerViewController *container = [[RCMusicContainerViewController alloc] init];
        [viewController presentViewController:container animated:YES completion:completion];
    }
}

- (void)asyncMixingState:(RCMusicMixingState)state {
    NSDictionary *info;
    if (self.player.currentPlayingMusic) {
        info = @{@"state":@(state),@"musicInfo":self.player.currentPlayingMusic};
    } else {
        info = @{@"state":@(state)};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RCMusicAsyncMixStateNotification object:info];
}

- (void)setOpenEarMonitoring:(BOOL)openEarMonitoring {
    _openEarMonitoring = openEarMonitoring;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:RCMusicAsyncEarMonitoringNotification object:nil];
    });
}

+ (RCMusicInfoBubbleView *)musicInfoBubbleView {
    RCMusicInfoBubbleView *bubble = [[RCMusicInfoBubbleView alloc] init];
    return bubble;
}
@end
