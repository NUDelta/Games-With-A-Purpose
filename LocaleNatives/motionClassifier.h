//
//  motionClassifier.h
//  LocaleNatives
//
//  Created by Stephen Chan on 1/24/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "coreMotionListener.h"
#import "locationListener.h"
#import <AVFoundation/AVFoundation.h>

@class motionClassifier;

@protocol motionClassifierDelegate <NSObject>

- (void)motionClassifier:(motionClassifier *)classifier didRegisterAction:(NSString *)action;

@end

@interface motionClassifier : NSObject <coreMotionListenerDelegate>

@property (nonatomic, weak) id <motionClassifierDelegate> delegate;
@property (strong, nonatomic) NSNumber *measurementInterval;
@property (strong, nonatomic)coreMotionListener *motionListener;
@property (strong, nonatomic) locationListener *location;
@property (strong, nonatomic) AVAudioRecorder *recorder;

- (void)motionMeasurementsToString;
- (void)classifyMotionWithDeviceMotion;
- (void)startClassifyingMotion;
- (void)stopClassifyingMotion;

@end
