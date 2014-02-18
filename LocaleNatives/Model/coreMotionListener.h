//
//  coreMotionListener.h
//  LocaleNatives
//
//  Created by Stephen Chan on 12/31/13.
//  Copyright (c) 2013 Stephen Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class coreMotionListener;

@protocol coreMotionListenerDelegate <NSObject>

- (void)motionListener:(coreMotionListener *)listener didReceiveDeviceMotion:(CMDeviceMotion *)deviceMotion;

@end

@interface coreMotionListener : NSObject

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) id <coreMotionListenerDelegate> delegate;
@property (strong, readonly) NSMutableArray *deviceMotionArray;

-(void)collectMotionInformationWithInterval:(NSUInteger)interval;
-(void)stopCollectingMotionInformation;

@end
