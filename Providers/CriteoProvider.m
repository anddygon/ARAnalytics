//
//  CriteoProvider.m
//  ARAnalyticsBootstrapiOS
//
//  Created by xiaoP on 2017/10/25.
//  Copyright © 2017年 Orta Therox. All rights reserved.
//

#import "CriteoProvider.h"
#import <CriteoEventsSDK/CriteoAdvertiser.h>

@interface CriteoProvider ()
@end

@implementation CriteoProvider
#ifdef AR_CRITEO_EXISTS
- (instancetype)init {
    self = [super init];
    
    CRTOAppLaunchEvent *launch = [[CRTOAppLaunchEvent alloc] init];
    [self.eventService send:launch];
    
    return self;
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
#if DEBUG
    return
#endif
    if (event) {
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
        
        //对事件进行匹配
//        if ([event isEqualToString:@"product_view"] && props[@"product_id"] && props[@"product_price"]) {
//            CRTOProduct *product = [[CRTOProduct alloc] initWithProductId:props[@"product_id"] price: [props[@"product_price"] doubleValue]];
//            CRTOProductViewEvent *productView = [[CRTOProductViewEvent alloc] initWithProduct:product];
//            [self.eventService send:productView];
//        } else {
//            
//        }
        CRTODataEvent *data = [[CRTODataEvent alloc] init];
        [props enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [data setStringExtraData:obj ForKey:key];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                [data setFloatExtraData:[obj doubleValue] ForKey:key];
            }
        }];
        [self.eventService send:data];
    }
}

- (void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email {
    CRTOEventService* eventService = [CRTOEventService sharedEventService];
    if (userID) {
        eventService.customerId = userID;
    }
    if (email) {
        eventService.customerEmail = email;
    }
}

- (void)setUserProperty:(NSString *)property toValue:(id)value {
    
}

- (void)didShowNewPageView:(NSString *)pageTitle withProperties:(NSDictionary *)properties {
    CRTOHomeViewEvent *homeEvent = [[CRTOHomeViewEvent alloc] init];
    [homeEvent setStringExtraData:pageTitle ForKey:@"page_title"];
}

#pragma mark - private help methods
- (CRTOEventService *)eventService {
    return [CRTOEventService sharedEventService];
}
#endif
@end
