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
    [[CRTOEventService sharedEventService] send:launch];
    
    return self;
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
 #if DEBUG
     return;
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
        if ([event isEqualToString: @"product_view"]) {//商品浏览
            NSString *productID = props[@"product_id"];
            double price = [self productPrice: props[@"product_price"]];
            if (productID) {
                CRTOProduct *product = [[CRTOProduct alloc] initWithProductId:productID price: price];
                CRTOProductViewEvent* productView = [[CRTOProductViewEvent alloc] initWithProduct:product];
                [[CRTOEventService sharedEventService] send:productView];
            }
        } else if ([event isEqualToString: @"view_cart"]) {//购物车商品浏览
            NSString *productID = props[@"product_id"];
            if (productID) {//代表只有一个商品
                double price = [self productPrice:props[@"price"]];
                CRTOBasketProduct *product = [[CRTOBasketProduct alloc] initWithProductId:productID price: price quantity:1];
                CRTOBasketViewEvent* productView = [[CRTOBasketViewEvent alloc] initWithBasketProducts:@[product]];
                [[CRTOEventService sharedEventService] send:productView];
            } else {//多个商品
                NSMutableArray *products = [NSMutableArray array];
                for (NSString *key in props.allKeys) {
                    if ([key hasSuffix:@"id"]) {
                        NSString *productID = props[key];
                        int index = [self searchIndexIn:key];
                        NSString *priceKey = [NSString stringWithFormat:@"pr%dpr", index];
                        double price = [self productPrice:props[priceKey]];
                        CRTOBasketProduct *product = [[CRTOBasketProduct alloc] initWithProductId:productID price:price quantity:1];
                        [products addObject:product];
                    }
                }
                CRTOBasketViewEvent *productsView = [[CRTOBasketViewEvent alloc] initWithBasketProducts:products];
                [[CRTOEventService sharedEventService] send:productsView];
            }
        } else if ([event isEqualToString: @"purchase"]) {//支付成功
            NSString *orderID = props[@"order_id"];
            NSString *currency = props[@"currency"];
            
            NSMutableArray *products = [NSMutableArray array];
            for (NSString *key in props.allKeys) {
                if ([key hasSuffix:@"id"]) {
                    NSString *productID = props[key];
                    int index = [self searchIndexIn:key];
                    NSString *priceKey = [NSString stringWithFormat:@"pr%dpr", index];
                    double price = [self productPrice:props[priceKey]];
                    CRTOBasketProduct *product = [[CRTOBasketProduct alloc] initWithProductId:productID price:price quantity:1];
                    [products addObject:product];
                }
            }
            CRTOTransactionConfirmationEvent *transactionEvent = [[CRTOTransactionConfirmationEvent alloc] initWithBasketProducts:products transactionId:orderID currency:currency];
            [[CRTOEventService sharedEventService] send:transactionEvent];
            
        } else {
            CRTODataEvent *data = [[CRTODataEvent alloc] init];
            [props enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    [data setStringExtraData:obj ForKey:key];
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    [data setFloatExtraData:[obj doubleValue] ForKey:key];
                }
            }];
            [[CRTOEventService sharedEventService] send:data];
        }
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

- (void)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    if ( [[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb] ) {
        NSURL* deeplinkURL = [userActivity webpageURL];
        NSString* deeplinkString = deeplinkURL.absoluteString;
        [self trackDeeplink:deeplinkString];
    }
}

- (void)application:(UIApplication *)app openURL:(id)url options:(id)options {
    NSString* deeplinkString = [url absoluteString];
    [self trackDeeplink:deeplinkString];
}

- (void)application:(UIApplication *)application openURL:(id)url sourceApplication:(id)sourceApplication annotation:(id)annotation {
    NSString* deeplinkString = [url absoluteString];
    [self trackDeeplink:deeplinkString];
}

- (void)application:(UIApplication *)application handleOpenURL:(id)url {
    NSString* deeplinkString = [url absoluteString];
    [self trackDeeplink:deeplinkString];
}

- (void)trackDeeplink:(NSString *)link {
    CRTODeeplinkEvent* deeplinkEvent = [[CRTODeeplinkEvent alloc] initWithDeeplinkLaunchUrl:link];
    // Send the deeplink event
    [[CRTOEventService sharedEventService] send:deeplinkEvent];
}

#pragma mark - private help methods
- (double)productPrice:(NSString *)priceString {
    NSScanner *scanner = [NSScanner scannerWithString:priceString];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    double price;
    [scanner scanDouble:&price];
    return price;
}
//从pr0id pr1id中找出0,1
- (int)searchIndexIn:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int index;
    [scanner scanInt:&index];
    return index;
}
#endif
@end
