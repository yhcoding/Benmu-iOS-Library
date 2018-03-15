//
//  BMDebugWindow.m
//  BM-JYT
//
//  Created by 窦静轩 on 2017/3/10.
//  Copyright © 2017年 XHY. All rights reserved.
//

#ifdef DEBUG
#import "BMDebugManager.h"
#import "BMDragButton+Debug.h"
#import "UIWindow+Util.h"
#import "BMHotRefreshWebScoket.h"
#import "BMResourceManager.h"
#import "BMBaseViewController.h"


@interface BMDebugManager ()
{
    BMDragButton * _debugButton;
}

@property (nonatomic, strong) BMHotRefreshWebScoket *hotRefreshWS; /**< 热刷新WS */

@end


@implementation BMDebugManager


+ (instancetype)shareInstance
{
    static BMDebugManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[BMDebugManager alloc] init];
        [_instance hotRefreshWebSocketConnect];
    });
    return _instance;
}

- (void)hotRefreshWebSocketConnect
{
    if (!BM_InterceptorOn()) {
        [self.hotRefreshWS connect];
    } else {
        [self.hotRefreshWS close];
    }
}


- (BMHotRefreshWebScoket *)hotRefreshWS
{
    if (!_hotRefreshWS) {
        _hotRefreshWS = [[BMHotRefreshWebScoket alloc] init];
    }
    return _hotRefreshWS;
}

// 显示
- (void)show
{
    UIWindow *window = [UIWindow findVisibleWindow];
    if (nil == _debugButton) {
        _debugButton = [BMDragButton debugButton];
    }
    
    NSArray * views = [window subviews];
    if (NO == [views containsObject:_debugButton]) {
        [window addSubview:_debugButton];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [window bringSubviewToFront:_debugButton];
    });
    
}
// 消失
- (void)dismiss
{
    [_debugButton removeFromSuperview];
}

- (void)refreshWeex
{
    //刷新widgetJs
    [BMResourceManager sharedInstance].bmWidgetJs = nil;
    
    //检查js中介者是否加载成功
    [[BMMediatorManager shareInstance] loadJSMediator:NO];
    
    UIViewController* controller =  [[BMMediatorManager shareInstance] currentViewController];
    if ([controller isKindOfClass:[BMBaseViewController class]]) {
        [(BMBaseViewController*)controller refreshWeex];
    }
}

@end
#endif
