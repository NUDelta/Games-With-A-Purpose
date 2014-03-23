//
//  motionClassifier.m
//  LocaleNatives
//
//  Created by Stephen Chan on 1/24/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "motionClassifier.h"
#import "GestureTemplates.h"
#import <Parse/Parse.h>
#import <Accelerate/Accelerate.h>
#import <math.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define MAX_SENSOR_ARRAY_LENGTH 200

@interface motionClassifier()

@property NSTimer *timer;
@property NSNumber *noMotionCount;
@property GestureTemplates *templates;

@end

@implementation motionClassifier

float deltaAccelArray[100];
float PositiveAccelArray[100];
float NegativeAccelArray[100];
float AccelArrayX[500];
vDSP_Length accelXLastZeroCross;
vDSP_Length accelXZeroCrossings;

float AccelArrayY[500];
float AccelArrayZ[500];

float deltaUserAccel;
float maxDeltaAccel;
float minAccel;
float maxAccel;
float maxMicPower;
float aveMicPower;

- (instancetype)init
{
    self =[super init];
    if(self) {
        NSLog(@"initializing coreMotionListener");
        self.motionListener = [[coreMotionListener alloc] init];
        self.motionListener.delegate = self;
        self.location = [[locationListener alloc] init];
        self.templates = [[GestureTemplates alloc] init];
        
        self.accelArrayX = [[NSMutableArray alloc] init];
        self.accelArrayY = [[NSMutableArray alloc] init];
        self.accelArrayZ = [[NSMutableArray alloc] init];
        
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
    
    // get the max userAcceleration value of the last few measurements using squared sums/magnitude
    
    /*for (int i = 0; i < [self.motionListener.deviceMotionArray count]-1; i ++) {
        int positiveAccelCount = 0;
        
        CMDeviceMotion *currentDeviceMotion = self.motionListener.deviceMotionArray[i+1];
        
        if (currentDeviceMotion.userAcceleration.x >= 0) {
            positiveAccelCount += 1;
        }
        if (currentDeviceMotion.userAcceleration.y >= 0) {
            positiveAccelCount += 1;
        }
        if (currentDeviceMotion.userAcceleration.z >= 0) {
            positiveAccelCount += 1;
        }
        
        float currentUserAccel = sqrtf(powf(currentDeviceMotion.userAcceleration.x, 2) + powf(currentDeviceMotion.userAcceleration.y, 2) + powf(currentDeviceMotion.userAcceleration.z, 2));
        CMDeviceMotion *pastDeviceMotion = self.motionListener.deviceMotionArray[i];
        float pastUserAccel = sqrtf(powf(pastDeviceMotion.userAcceleration.x, 2) + powf(pastDeviceMotion.userAcceleration.y, 2) + powf(pastDeviceMotion.userAcceleration.z, 2));
        deltaUserAccel = fabsf(currentUserAccel - pastUserAccel);
        deltaAccelArray[i] = deltaUserAccel;
        if (positiveAccelCount >= 2) {
            PositiveAccelArray[i] = currentUserAccel;
            NegativeAccelArray[i] = 0;
        } else {
            NegativeAccelArray[i] = currentUserAccel;
            PositiveAccelArray[i] = 0;
        }
    }
    maxDeltaAccel = deltaAccelArray[0];
    maxAccel = PositiveAccelArray[0];
    minAccel = NegativeAccelArray[0];
    for (int i = 0; i < 100; i++) {
        if (deltaAccelArray[i] > maxDeltaAccel) {
            maxDeltaAccel = deltaAccelArray[i];
        }
        if (PositiveAccelArray[i] > maxAccel) {
            maxAccel = PositiveAccelArray[i];
        }
        // we use > here because we are still calculating negative accel magnitude
        if (NegativeAccelArray[i] > minAccel) {
            minAccel = NegativeAccelArray[i];
        }
    }
    NSLog(@"min accel: %f; max accel: %f; max power: %f", minAccel, maxAccel, maxMicPower);
    NSLog(@"altitude: %f", self.location.locationManager.location.altitude);
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
    } */
    [self detectKnock];
}

float *floatArrayFromNSArray(NSArray *array, NSUInteger count)
{
    float *floatArray = (float *)malloc(sizeof(float) * count);
    for(int i = 0; i < count; i++) {
        floatArray[i] = [[array objectAtIndex:i] floatValue];
    }
    return floatArray;
}

float minimumDistance(float *x, float *y, float *z, float *refX, float *refY, float *refZ, int overlap, int refLength, int comparisonLength)
{
    int windowStart = 0;
    int numWindows = comparisonLength / overlap;
    
    float windowX[refLength];
    float windowY[refLength];
    float windowZ[refLength];
    
    float differenceX[refLength];
    float differenceY[refLength];
    float differenceZ[refLength];
    
    float squareDifX[refLength];
    float squareDifY[refLength];
    float squareDifZ[refLength];
    
    float distance3D[refLength];
    float squareSumDistance[refLength];
    
    float resultVector[numWindows];
    
    float minDistance = 0;
    float *minimumDistance = &minDistance;
    
    for (int j = 0; j < numWindows; j++) {
        memcpy( windowX, x + windowStart, sizeof(float) * refLength);
        memcpy( windowY, y + windowStart, sizeof(float) * refLength);
        memcpy( windowZ, z + windowStart, sizeof(float) * refLength);
        
        resultVector[j] = vector3Ddistance(windowX, windowY, windowZ, refX, refY, refZ, refLength);
        
        //NSLog(@"%f", resultVector[j]);
        
        /*vDSP_vsub( refX, 1, windowX, 1, differenceX, 1, 1);
        vDSP_vsub( refY, 1, windowY, 1, differenceY, 1, 1);
        vDSP_vsub( refZ, 1, windowZ, 1, differenceZ, 1, 1);
        
        vDSP_vsq( differenceX, 1, squareDifX, 1, 1 );
        vDSP_vsq( differenceY, 1, squareDifY, 1, 1 );
        vDSP_vsq( differenceZ, 1, squareDifZ, 1, 1 );
        
        for (int i = 0; i < refLength; i++) {
            distance3D[i] = sqrtf(squareDifX[i] + squareDifY[i] + squareDifZ[i]);
            NSLog(@"%f", squareDifX[i]);
        }
        vDSP_vsq( distance3D, 1, squareSumDistance, 1, 1 );
        
        vDSP_sve( distance3D, 1, &resultVector[j], refLength ); */
        
        windowStart += overlap;
    }
    
    vDSP_minv( resultVector, 1, minimumDistance, numWindows);
    
    //NSLog(@"minimum distance: %f", *minimumDistance);
    
    return *minimumDistance;
}

float vector3Ddistance ( float *x1, float *y1, float *z1, float *x2, float *y2, float *z2, int length ) {
    // This takes in 6 vectors of equal length, where each element corresponds to an axis of a 3d point.
    // It then calculates the 3D distance for each element and returns the square sum of all these points.
    
    float point1[3];
    float point2[3];
    
    float squareDiff[length];
    
    float sqDiffSum = 0;
    float *squareDiffSum = &sqDiffSum;
    
    for (int i = 0; i < length; i++) {
        float dist = 0;
        float *distance = &dist;
        
        point1[0] = x1[i];
        point1[1] = y1[i];
        point1[2] = z1[i];
        
        point2[0] = x2[i];
        point2[1] = y2[i];
        point2[2] = z2[i];
        
        vDSP_distancesq(point1, 1, point2, 1, distance, 3);
        
        squareDiff[i] = *distance;
    }
    vDSP_svesq(squareDiff, 1, squareDiffSum, length);
    return *squareDiffSum;
}

- (BOOL)detectKnock
{
    //NSLog(@"%d", [self.accelArrayX count]);
    if ([self.accelArrayX count] >= MAX_SENSOR_ARRAY_LENGTH) {
        NSArray *knockTemplates = [self.templates knockAccelerometerTemplates];
        float *accelX = floatArrayFromNSArray(self.accelArrayX, [self.accelArrayX count]);
        float *accelY = floatArrayFromNSArray(self.accelArrayY, [self.accelArrayY count]);
        float *accelZ = floatArrayFromNSArray(self.accelArrayZ, [self.accelArrayZ count]);
        for (NSDictionary *template in knockTemplates) {
       // NSDictionary *template = knockTemplates[1];
            NSUInteger referenceLength = [template[@"X"] count];
        //NSLog(@"%d", referenceLength);
            float *refAccelX = floatArrayFromNSArray(template[@"X"], referenceLength);
            float *refAccelY = floatArrayFromNSArray(template[@"Y"], referenceLength);
            float *refAccelZ = floatArrayFromNSArray(template[@"Z"], referenceLength);
            float minDistance = minimumDistance(accelX, accelY, accelZ, refAccelX, refAccelY, refAccelZ, (referenceLength / 2), referenceLength, MAX_SENSOR_ARRAY_LENGTH);
            [self updateMicrophone];
            //NSLog(@"%f", minDistance);
            if (minDistance < 2 && [self.recorder peakPowerForChannel:0] < 5) {
               NSLog(@"got a knock!");
            }
        }
    }
    return YES;
}

+ (NSArray *)validMotionsToDetect
{
    return @[@"jump", @"knock", @"stomp", @"throw"];
}

- (void)startClassifyingMotion
{
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(classifyMotionWithDeviceMotion) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)motionListener:(coreMotionListener *)listener didReceiveDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    //[NSThread detachNewThreadSelector:@selector(updateMicrophone) toTarget:self withObject:nil];
    [self.accelArrayX addObject:[NSNumber numberWithDouble:(deviceMotion.userAcceleration.x)]];
    [self.accelArrayY addObject:[NSNumber numberWithDouble:deviceMotion.userAcceleration.y]];
    [self.accelArrayZ addObject:[NSNumber numberWithDouble:deviceMotion.userAcceleration.z - 1]];
    if ( [self.accelArrayX count] > MAX_SENSOR_ARRAY_LENGTH) {
        [self.accelArrayX removeObjectAtIndex:0];
        [self.accelArrayY removeObjectAtIndex:0];
        [self.accelArrayZ removeObjectAtIndex:0];
    }
}

- (void)motionListener:(coreMotionListener *)listener didReceiveAccelerometerData:(CMAccelerometerData *)data
{
    /*[self.accelArrayX addObject:[NSNumber numberWithDouble:(data.acceleration.x)]];
    [self.accelArrayY addObject:[NSNumber numberWithDouble:data.acceleration.y]];
    [self.accelArrayZ addObject:[NSNumber numberWithDouble:data.acceleration.z]];
    if ( [self.accelArrayX count] > MAX_SENSOR_ARRAY_LENGTH) {
        NSLog(@"array full");
        [self.accelArrayX removeObjectAtIndex:0];
        [self.accelArrayY removeObjectAtIndex:0];
        [self.accelArrayZ removeObjectAtIndex:0];
    } */
}

- (void)updateMicrophone
{
    [self.recorder updateMeters];
    [self.micMaxPowerArray addObject:[NSNumber numberWithFloat:[self.recorder peakPowerForChannel:0]]];
    [self.micAvePowerArray addObject:[NSNumber numberWithFloat:[self.recorder averagePowerForChannel:0]]];
    //NSLog(@"%f", [self.recorder peakPowerForChannel:0]);
    if ([self.micAvePowerArray count] > MAX_SENSOR_ARRAY_LENGTH) {
        [self.micAvePowerArray removeObjectAtIndex:0];
        [self.micMaxPowerArray removeObjectAtIndex:0];
    }
}

- (void)stopClassifyingMotion
{
    [self.timer invalidate];
}

@end
