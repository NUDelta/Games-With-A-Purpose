//
//  curbStomp.m
//  LocaleNatives
//
//  Created by Stephen Chan on 2/2/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "curbStomp.h"
#import "locationListener.h"

@interface curbStomp()

@property (strong, nonatomic) locationListener *listener;

@end

@implementation curbStomp

- (id)init
{
    self = [super init];
    if (self) {
        self.listener = [[locationListener alloc] init];
    }
    return self;
}

- (NSString *)getNearestIntersection
{
    NSString *street1;
    NSString *street2;
    
    NSString *currentLat = [NSString stringWithFormat:@"%f", self.listener.currentLocation.coordinate.latitude];
    NSString *currentLong = [NSString stringWithFormat:@"%f", self.listener.currentLocation.coordinate.longitude];
    NSLog(@"%@", currentLat);
    NSLog(@"%@", currentLong);
    NSString *URLRequestString = [[[[@"http://api.geonames.org/findNearestIntersectionJSON?lat=" stringByAppendingString:currentLat] stringByAppendingString:@"&lng=" ] stringByAppendingString:currentLong] stringByAppendingString:@"&username=schan777"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLRequestString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if (response1) {
        NSDictionary *jsonIntersectionData = [NSJSONSerialization JSONObjectWithData:response1 options:0 error:nil];
        NSLog(@"%@", jsonIntersectionData);
        NSDictionary *intersection = [jsonIntersectionData objectForKey:@"intersection"];
        street1 = [intersection objectForKey:@"street1"];
        street2 = [intersection objectForKey:@"street2"];
        return [[street1 stringByAppendingString:@" and "] stringByAppendingString:street2];
    }
    return @"unknown location";
}

- (NSString *)gameInstructions
{
    return [self generateGameInstructions];
}

- (NSString *)generateGameInstructions
{
    NSString *curbStomp = [[@"Get to the intersection of " stringByAppendingString:[self getNearestIntersection]] stringByAppendingString:@". Once there, look around. If you see a fire hydrant, jump in the air as high as you can."];
    return curbStomp;
}

- (void)stopLocationListener
{
    self.listener = nil;
}

@end
