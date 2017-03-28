#import "DumplingsProvider.h"
#import <DumplingsTracker/DumplingsTracker.h>

@interface DumplingsProvider ()

@property (nonatomic, strong) NSString *userId;

@end

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

-(void)identifyUserWithID:(NSString *)userID andEmailAddress:(NSString *)email{
    if (userID) {
        self.userId = userID;
    }
}

- (void)event:(NSString *)event withProperties:(NSDictionary *)properties {
#if DEBUG
    return;
#endif
    
    if (event) {
        NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:properties];
        if(self.userId) {
            [props setObject:self.userId forKey:@"customer_user_id"];
        }
        [DumplingsTracker eventWithName:event parameters:props];
    }
}

#endif

@end
