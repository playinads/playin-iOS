//
//  PlayIn.h
//  PlayIN
//
//  Created by A on 2019/2/5.
//  Copyright © 2019 PlayIN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    PIErrorNone = 0,        // no error
    PIErrorInner = 1,       // inner error
    PIErrorParams = 2,      // parameter assigned to sdk invalid
    PIErrorNetwork = 3,     // network error
    PIErrorResource = 4,    // no available playin resource
    PIErrorDuplicate = 5,   // duplicate play
    PIErrorUnknown = -1,    // unknown error
} PIError;


// the following callbacks happend on init or start
typedef void(^PlayInConfigureCompletion)(BOOL success, NSString *error);
typedef void(^PlayInPlayCompletion)(NSDictionary *result);

@protocol PlayInDelegate <NSObject>

// the following callbacks are dispatched in main_queue and be calling during the playing
- (void)onPlayInTerminate;
- (void)onPlayInCloseAction;
- (void)onPlayInInstallAction;
- (void)onPlayInError:(NSString *)error;
@end

@interface PlayIn : NSObject

@property (nonatomic, strong) UIView *playInView;
@property (nonatomic, weak) id<PlayInDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)configureWithKey:(NSString *)key completionHandler:(PlayInConfigureCompletion)completion;

- (void)checkAvailabilityWithAdid:(NSString *)adid completionHandler:(void(^)(BOOL result))avaliable;

- (void)playWithOriginPoint:(CGPoint)origin
                   duration:(NSInteger)duration
                      times:(NSInteger)times
          completionHandler:(PlayInPlayCompletion)completion;

- (void)stopPlay;

- (id)init __attribute__((unavailable("Use sharedInstance instead of alloc-init pattern.")));

+ (instancetype)initialize NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
