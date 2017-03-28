#import "FacebookProvider.h"
#import "ARAnalyticsProviders.h"
#import "FBSDKCoreKit.h"

@interface FacebookProvider ()

@end

@implementation FacebookProvider
#ifdef AR_FACEBOOK_EXISTS

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSAssert([FBSDKAppEvents class], @"FBSDKCoreKit Analytics SDK is not included");

    if ((self = [super init])) {
        [FBSDKAppEvents setLoggingOverrideAppID:identifier];
    }
#if !DEBUG
    [FBSDKAppEvents activateApp];
#endif
    return self;
}

-(void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email {
    if (userID) {
        [FBSDKAppEvents setUserID:userID];
    }
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
#if DEBUG
    return;
#endif
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:properties];
    if ([self.eventMappings objectForKey:event]) {
        event = [self.eventMappings objectForKey:event];
    }
    for(NSString *key in properties.allKeys) {
        NSString *nk = [self.customDimensionMappings objectForKey:key];
        if(nk) {
            [props setObject:[properties objectForKey:key] forKey:nk];
            [props removeObjectForKey:key];
        }
    }
    NSString * price = props[@"price"];
    if ([event isEqualToString:@"purchase"]) {
        NSString *currency = props[FBSDKAppEventParameterNameCurrency];
        [FBSDKAppEvents logPurchase:price.doubleValue currency:currency parameters:props];
        return;
    }
    if (!price) {
        [FBSDKAppEvents logEvent:event parameters:props];
    }else{
        [FBSDKAppEvents logEvent:event valueToSum:price.doubleValue parameters:props];
    }
}

#endif
@end
