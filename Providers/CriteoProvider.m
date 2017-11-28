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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^pr\\d+pr$"];
        if ([event isEqualToString: @"product_view"]) {//商品浏览
            NSString *productID = props[@"product_id"];
            double price = [self productPrice: props[@"product_price"]];
            if (productID) {
                CRTOProduct *product = [[CRTOProduct alloc] initWithProductId:productID price: price];
                CRTOProductViewEvent* productView = [[CRTOProductViewEvent alloc] initWithProduct:product];
                [[CRTOEventService sharedEventService] send:productView];
            }
        } else if ([event isEqualToString: @"view_cart"]) {//购物车商品浏览
            NSMutableArray *products = [NSMutableArray array];
            for (NSString *key in props.allKeys) {
                if ([predicate evaluateWithObject:key]) {
                    int index = [self searchIndexIn:key];
                    NSString *idKey = [NSString stringWithFormat:@"pr%did", index];
                    NSString *productID = props[idKey];
                    NSString *priceKey = [NSString stringWithFormat:@"pr%dpr", index];
                    double price = [self productPrice:props[priceKey]];
                    CRTOBasketProduct *product = [[CRTOBasketProduct alloc] initWithProductId:productID price:price quantity:1];
                    [products addObject:product];
                }
            }
            CRTOBasketViewEvent *productsView = [[CRTOBasketViewEvent alloc] initWithBasketProducts:products];
            [[CRTOEventService sharedEventService] send:productsView];
        } else if ([event isEqualToString: @"purchase"]) {//支付成功
            NSString *orderID = props[@"order_id"];
            NSString *currency = props[@"currency"];
            NSMutableArray *products = [NSMutableArray array];
            for (NSString *key in props.allKeys) {
                if ([predicate evaluateWithObject:key]) {
                    int index = [self searchIndexIn:key];
                    NSString *idKey = [NSString stringWithFormat:@"pr%did", index];
                    NSString *productID = props[idKey];
                    NSString *priceKey = [NSString stringWithFormat:@"pr%dpr", index];
                    double price = [self productPrice:props[priceKey]];
                    CRTOBasketProduct *product = [[CRTOBasketProduct alloc] initWithProductId:productID price:price quantity:1];
                    [products addObject:product];
                }
            }
            CRTOTransactionConfirmationEvent *transactionEvent = [[CRTOTransactionConfirmationEvent alloc] initWithBasketProducts:products transactionId:orderID currency:currency];
            [[CRTOEventService sharedEventService] send:transactionEvent];
        } else if ([event isEqualToString:@"product_list_view"]) {//商品列表浏览
            NSMutableArray *products = [NSMutableArray array];
            for (NSString *key in props.allKeys) {
                if ([predicate evaluateWithObject:key]) {
                    int index = [self searchIndexIn:key];
                    NSString *idKey = [NSString stringWithFormat:@"pr%did", index];
                    NSString *productID = props[idKey];
                    NSString *priceKey = [NSString stringWithFormat:@"pr%dpr", index];
                    double price = [self productPrice:props[priceKey]];
                    CRTOProduct *product = [[CRTOProduct alloc] initWithProductId:productID price:price];
                    [products addObject:product];
                }
            }
            CRTOProductListViewEvent *listEvent = [[CRTOProductListViewEvent alloc] initWithProducts:products];
            [CRTOEventService.sharedEventService send:listEvent];
        } else if ([event isEqualToString:ARAnalyticalProviderNewPageViewEventName]) {//首页事件
            NSString *screenName = props[ARAnalyticalProviderNewPageViewEventScreenPropertyKey];
            if ([screenName hasPrefix:@"home"]) {
                CRTOHomeViewEvent *homeEvent = [[CRTOHomeViewEvent alloc] init];
                [CRTOEventService.sharedEventService send:homeEvent];
            }
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
