//
//  CYCameraView.m
//  CYInkeLive
//
//  Created by Cyrill on 2017/4/13.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import "CYCameraView.h"
#import <Masonry.h>

#define LiveWidth [UIScreen mainScreen].bounds.size.width/2 //button的宽高
#define LiveGetY [UIScreen mainScreen].bounds.size.height - 50 - [UIScreen mainScreen].bounds.size.width/2 //灰色区域高度


@interface CYCameraView ()

//直播
@property (nonatomic,strong) UIButton *liveButton;

//短视频
@property (nonatomic,strong) UIButton *videoButton;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UIView *bgView;


@end

@implementation CYCameraView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self creatUI];
    }
    return self;
}

- (void)creatUI{
    [self addSubview:self.bgView];
    [self addSubview:self.liveButton];
    [self addSubview:self.videoButton];
    [self addSubview:self.closeButton];
}

- (void)popShow {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

- (void)closeClick{
    [self removeFromSuperview];
}

- (UIButton *)liveButton{
    if (_liveButton == nil) {
        _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _liveButton.backgroundColor = [UIColor clearColor];
        [_liveButton setImage:[UIImage imageNamed:@"shortvideo_main_live"] forState:UIControlStateNormal];
        [_liveButton setTitle:@"直播" forState:UIControlStateNormal];
        [_liveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _liveButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, LiveWidth, LiveWidth);
//        [_liveButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
        _liveButton.tag = 50;
        [_liveButton addTarget:self action:@selector(liveClick:) forControlEvents:UIControlEventTouchUpInside];
        //关键帧  damp阻尼
        [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _liveButton.frame = CGRectMake(0, LiveGetY, LiveWidth, LiveWidth);
        } completion:^(BOOL finished) {
            
        }];
        
    }
    return _liveButton;
}

- (UIButton *)videoButton{
    if (_videoButton == nil) {
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoButton.backgroundColor = [UIColor clearColor];
        [_videoButton setImage:[UIImage imageNamed:@"shortvideo_main_video"] forState:UIControlStateNormal];
        [_videoButton setTitle:@"短视频" forState:UIControlStateNormal];
        [_videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _videoButton.frame = CGRectMake(LiveWidth, [UIScreen mainScreen].bounds.size.height, LiveWidth, LiveWidth);
        _videoButton.tag = 51;
        [_videoButton addTarget:self action:@selector(liveClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_videoButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5];
        //关键帧  damp阻尼
        [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _videoButton.frame = CGRectMake(LiveWidth, LiveGetY, LiveWidth, LiveWidth);
        } completion:^(BOOL finished) {
            
        }];
    }
    return _videoButton;
}

- (void)liveClick:(UIButton *)sender{
    if (self.buttonClick) {
        self.buttonClick(sender.tag);
    }
    [self closeClick];
    
}

// 点击上方灰色区域移除视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self];
    if ( point.y < LiveGetY) {
        [self removeFromSuperview];
    }
}

- (UIButton *)closeButton{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor whiteColor];
        [_closeButton setImage:[UIImage imageNamed:@"shortvideo_launch_close"] forState:UIControlStateNormal];
        _closeButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
        [_closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIView *)bgView{
    if (_bgView == nil) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50 - LiveWidth, [UIScreen mainScreen].bounds.size.width, LiveWidth)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

@end
