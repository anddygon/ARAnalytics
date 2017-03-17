#import "AppsFlyerProvider.h"
#import <DumplingsTracker/DumplingsTracker.h>

@implementation DumplingsProvider
#ifdef AR_APPSFLYER_EXISTS

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSLog(@"Use -[DumplingsProvider initWithAppID:devKey:] instead of %s", __PRETTY_FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithPID:(NSString *)pid IDFA:(NSString *)idfa {
    self = [super init];
    if (!self) return nil;

    DumplingsTracker.sharedTracker.pid = pid;
    DumplingsTracker.sharedTracker.idfa = idfa;

    // [DumplingsTracker.sharedTracker trackAppLaunch];

    return self;
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
    if (event) {
        NSString *value = properties[ARAppsFlyerEventPropertyValue] ?: @"";
        [DumplingsTracker eventWithName:event parameters:value];
    }
}

#endif
@end
