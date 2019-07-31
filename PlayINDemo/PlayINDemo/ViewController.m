//
//  ViewController.m
//  PlayINDemo
//
//  Created by lijunge on 2019/5/7.
//  Copyright © 2019 lijunge. All rights reserved.
//

#import "ViewController.h"
#import "PlayIn.h"

@interface ViewController ()<PlayInDelegate>
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *playNowButton;
@property (nonatomic, strong) PlayIn *playIn;
@property (nonatomic, assign) BOOL isAvailable;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat btnHeight = 50;
    CGFloat btnWidth = 160;
    CGFloat margin = 50;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBounds.size;
    
    CGFloat btnX = screenSize.width/2.0 - btnWidth/2.0;
    
    CGRect btn0Rect = CGRectMake(btnX, margin+100, btnWidth, btnHeight);
    UIButton *checkButton = [[UIButton alloc] initWithFrame:btn0Rect];
    checkButton.backgroundColor = [UIColor colorWithRed:116/255.0 green:179/255.0 blue:240/255.0 alpha:1];
    checkButton.layer.masksToBounds = YES;
    checkButton.layer.cornerRadius = 8.0f;
    checkButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkButton setTitle:@"Check Availability" forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
    
    CGRect btn1Rect = CGRectMake(btnX, CGRectGetMaxY(btn0Rect) + margin, btnWidth, btnHeight);
    UIButton *playNowButton = [[UIButton alloc] initWithFrame:btn1Rect];
    playNowButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:160/255.0 blue:20/255.0 alpha:1];
    playNowButton.layer.masksToBounds = YES;
    playNowButton.layer.cornerRadius = 8.0f;
    playNowButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [playNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [playNowButton setTitle:@"Play Now" forState:UIControlStateNormal];
    [playNowButton addTarget:self action:@selector(playNowButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    playNowButton.hidden = YES;
    [self.view addSubview:playNowButton];
    self.playNowButton = playNowButton;
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

// 1.PlayIn init
// 2.PlayIn check available
- (void)checkButtonTapped:(UIButton *)sender {
    
    self.playIn = [PlayIn sharedInstance];
    self.playIn.delegate = self;
    __weak typeof(self) weakself = self;
    NSString *sdkKey = @"XXXX";//请与PlayIn官方联系获取
    NSString *adid = @"XXXX";//请与PlayIn官方联系获取
    [self.playIn configureWithKey:sdkKey completionHandler:^(BOOL success, NSString *error) {
        if (success) {
            NSLog(@"[ViewController] playin configureWithKey success");
            [weakself.playIn checkAvailabilityWithAdid:adid completionHandler:^(BOOL result) {
                weakself.isAvailable = result;
                weakself.playNowButton.hidden = !result;
            }];
        } else {
            NSLog(@"[ViewController] playin configureWithKey error: %@", error);
        }
    }];
}

// 3.PlayIn start
- (void)playNowButtonTapped:(UIButton *)sender {
    
    if (self.isAvailable) {
        
        __weak typeof(self) weakself = self;
        [UIView transitionWithView:self.view duration:1.4 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
            
        } completion:^(BOOL finished) {
            
        }];
        CGPoint originPoint = CGPointMake(0, 0);
        NSInteger duration = 120;
        NSInteger times = 2;
        [self.playIn playWithOriginPoint:originPoint duration:duration times:times completionHandler:^(NSDictionary *result) {
            PIError err = [[result valueForKey:@"code"] integerValue];
            id info = [result valueForKey:@"info"];
            if (err == PIErrorNone && [info isKindOfClass:[NSDictionary class]]) {
                [weakself.view addSubview:self.playIn.playInView];
                weakself.playNowButton.hidden = YES;
            } else {
                NSString *errorString = [NSString stringWithFormat:@"%@",info];
                NSLog(@"[ViewController] playWithOriginPoint error %@", errorString);
            }
        }];
    }
}
// 4. destroy playin
- (void)destroyPlayIn {
    
    [self.playIn.playInView removeFromSuperview];
    self.playIn.playInView = nil;
}

#pragma mark - PlayIn Delegate

- (void)onPlayInTerminate {
    
    NSLog(@"[ViewController] playin terminate");
    [self destroyPlayIn];
}

- (void)onPlayInError:(NSString *)error {
    
    NSLog(@"[ViewController] playin error: %@", error);
    [self destroyPlayIn];
}

- (void)onPlayInCloseAction {
    
    NSLog(@"[ViewController] playin close action");
    [self destroyPlayIn];
}

- (void)onPlayInInstallAction {
    
    NSLog(@"[ViewController] playin install action");
    [self destroyPlayIn];
    
    NSString *appUrl = @"https://itunes.apple.com/us/app/word-cookies/id1153883316?mt=8";
    NSURL *appURL = [NSURL URLWithString:appUrl];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        //app store
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:appURL];
        }
    }
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end
