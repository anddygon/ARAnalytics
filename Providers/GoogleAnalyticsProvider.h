#import "ARAnalyticalProvider.h"

@interface GoogleAnalyticsProvider : ARAnalyticalProvider



/***
 * maps custom names to GAI customMetrics
 * i.e. @{@"FooMetric":[GAIFields customMetricForIndex:1], @"BarMetric":[GAIFields customMetricForIndex:2]}
 */
@property (nonatomic, strong) NSDictionary *customMetricMappings;


@end
