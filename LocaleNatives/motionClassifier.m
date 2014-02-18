//
//  motionClassifier.m
//  LocaleNatives
//
//  Created by Stephen Chan on 1/24/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "motionClassifier.h"
#import "locationListener.h"
#import <Parse/Parse.h>

@interface motionClassifier()

@property NSTimer *timer;
@property locationListener *location;
@property NSNumber *noMotionCount;

@end

@implementation motionClassifier

- (instancetype)init
{
    self =[super init];
    if(self) {
        NSLog(@"initializing coreMotionListener");
        self.motionListener = [[coreMotionListener alloc] init];
        self.motionListener.delegate = self;
        self.location = [[locationListener alloc] init];
    }
    return self;
}

- (void)classifyMotionWithDeviceMotion
{
    static float THRESHOLD = 1.2;
    float deltaAccelArray[100];
    // get the max userAccelerationX value of the last few measurements
    for (int i = 0; i < [self.motionListener.deviceMotionArray count]-1; i ++) {
        CMDeviceMotion *currentDeviceMotion = self.motionListener.deviceMotionArray[i+1];
        float currentUserAccel = sqrtf(powf(currentDeviceMotion.userAcceleration.x, 2) + powf(currentDeviceMotion.userAcceleration.y, 2) + powf(currentDeviceMotion.userAcceleration.z, 2));
        CMDeviceMotion *pastDeviceMotion = self.motionListener.deviceMotionArray[i];
        float pastUserAccel = sqrtf(powf(pastDeviceMotion.userAcceleration.x, 2) + powf(pastDeviceMotion.userAcceleration.y, 2) + powf(pastDeviceMotion.userAcceleration.z, 2));
        float deltaUserAccel = fabsf(currentUserAccel - pastUserAccel);
        deltaAccelArray[i] = deltaUserAccel;
    }
    float maxDeltaAccel = deltaAccelArray[0];
    for (int i = 0; i < 100; i++) {
        if (deltaAccelArray[i] > maxDeltaAccel) {
            maxDeltaAccel = deltaAccelArray[i];
        }
    }
    NSLog(@"%f", maxDeltaAccel);
    if (maxDeltaAccel > THRESHOLD) {
        [self.delegate motionClassifier:self didRegisterAction:[NSString stringWithFormat:@"You just jumped! %@", [NSDate date]]];
        PFObject *jumpRecord = [PFObject objectWithClassName:@"jumpRecord"];
        jumpRecord[@"Date"] = [NSDate date];
        jumpRecord[@"Latitude"] = [NSString stringWithFormat:@"%f", self.location.currentLocation.coordinate.latitude];
        jumpRecord[@"Longitude"] = [NSString stringWithFormat:@"%f", self.location.currentLocation.coordinate.longitude];
        [jumpRecord saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"finished saving!");
            } else {
                NSLog(@"something went wrong...");
            }
        }];
    }
}

- (void)motionMeasurementsToString
{
    
    NSLog(@"test");
}

- (void)startClassifyingMotion
{
    self.timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(classifyMotionWithDeviceMotion) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)motionListener:(coreMotionListener *)listener didReceiveDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    //NSLog(@"%@", deviceMotion);
    //static int STILL_THRESHOLD = 0.1
    //if (deviceMotion.userAcceleration.x < STILL_THRESHOLD && deviceMotion.userAcceleration.y)
}

- (void)stopClassifyingMotion
{
    [self.timer invalidate];
}

@end
