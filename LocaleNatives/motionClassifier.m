//
//  motionClassifier.m
//  LocaleNatives
//
//  Created by Stephen Chan on 1/24/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "motionClassifier.h"
#import <Parse/Parse.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface motionClassifier()

@property NSTimer *timer;
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
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        NSString *documentsString = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, [[NSDate date] description]];
        NSURL *documentsURL = [NSURL fileURLWithPath:documentsString];
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:@1 forKey:AVNumberOfChannelsKey];
        
        [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        self.recorder = [[AVAudioRecorder alloc] initWithURL:documentsURL settings:recordSetting error:NULL];
        self.recorder.meteringEnabled = YES;
        if (self.recorder) {
            NSLog(@"recorder was initialized");
            [self.recorder prepareToRecord];
            [self.recorder record];
            NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateRecorder) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
    }
    return self;
}

- (void)updateRecorder
{
    [self.recorder updateMeters];
    //NSLog(@"peak power for channel: %f", [self.recorder peakPowerForChannel:0]);
    //NSLog(@"average power for channel: %f", [self.recorder averagePowerForChannel:0]);
}

- (void)classifyMotionWithDeviceMotion
{
    static float DELTA_ACCEL_THRESHOLD = 1.2;
    static float ACCEL_THRESHOLD = 2.0;
    static float POWER_THRESHOLD = -20.0;
    
    [self.recorder updateMeters];
    float maxMicPower = [self.recorder peakPowerForChannel:0];
    
    float deltaAccelArray[100];
    float AccelArray[100];
    // get the max userAccelerationX value of the last few measurements
    for (int i = 0; i < [self.motionListener.deviceMotionArray count]-1; i ++) {
        CMDeviceMotion *currentDeviceMotion = self.motionListener.deviceMotionArray[i+1];
        float currentUserAccel = sqrtf(powf(currentDeviceMotion.userAcceleration.x, 2) + powf(currentDeviceMotion.userAcceleration.y, 2) + powf(currentDeviceMotion.userAcceleration.z, 2));
        CMDeviceMotion *pastDeviceMotion = self.motionListener.deviceMotionArray[i];
        float pastUserAccel = sqrtf(powf(pastDeviceMotion.userAcceleration.x, 2) + powf(pastDeviceMotion.userAcceleration.y, 2) + powf(pastDeviceMotion.userAcceleration.z, 2));
        float deltaUserAccel = fabsf(currentUserAccel - pastUserAccel);
        deltaAccelArray[i] = deltaUserAccel;
        AccelArray[i] = currentUserAccel;
    }
    float maxDeltaAccel = deltaAccelArray[0];
    float maxAccel = AccelArray[0];
    for (int i = 0; i < 100; i++) {
        if (deltaAccelArray[i] > maxDeltaAccel) {
            maxDeltaAccel = deltaAccelArray[i];
        }
        if (AccelArray[i] > maxAccel) {
            maxAccel = AccelArray[i];
        }
    }
    NSLog(@"max delta accel: %f; max accel: %f; max power: %f", maxDeltaAccel, maxAccel, maxMicPower);
    if (maxDeltaAccel > DELTA_ACCEL_THRESHOLD && maxAccel > ACCEL_THRESHOLD && maxMicPower > POWER_THRESHOLD) {
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
