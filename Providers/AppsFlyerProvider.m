#import "AppsFlyerProvider.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>

const NSString * ARAppsFlyerEventPropertyCurrencyCode = @"af_currency";
const NSString * ARAppsFlyerEventPropertyValue = @"value";

@implementation AppsFlyerProvider
#ifdef AR_APPSFLYER_EXISTS

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSLog(@"Use -[AppsFlyerProvider initWithAppID:devKey:] instead of %s", __PRETTY_FUNCTION__);
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithAppID:(NSString *)appID devKey:(NSString *)devKey {
    self = [super init];
    if (!self) return nil;

    AppsFlyerTracker.sharedTracker.appsFlyerDevKey = devKey;
    AppsFlyerTracker.sharedTracker.appleAppID = appID;

    [AppsFlyerTracker.sharedTracker trackAppLaunch];

    return self;
}

- (void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email {
    if (userID) {
        AppsFlyerTracker.sharedTracker.customerUserID = userID;
    }
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
    NSString *currencyCode = properties[ARAppsFlyerEventPropertyCurrencyCode];
    if (currencyCode) {
        AppsFlyerTracker.sharedTracker.currencyCode = currencyCode;
    }
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:properties];
    [props setObject:@"0" forKey:@"data_situation"];
#if DEBUG
    [props setObject:@"1" forKey:@"data_situation"];
#endif

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
    if (event) {
        [AppsFlyerTracker.sharedTracker trackEvent:event withValues:props];
    }
}

#endif
@end
