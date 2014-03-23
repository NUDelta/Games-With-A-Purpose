//
//  TemplateSaverViewController.m
//  LocaleNatives
//
//  Created by Stephen Chan on 3/8/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "TemplateSaverViewController.h"
#import <Parse/Parse.h>
#import "GraphView.h"
#import <AVFoundation/AVFoundation.h>

#define MAX_ARRAY_LENGTH 500

@interface TemplateSaverViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) NSMutableArray *deviceMotionArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *templateTypeSelection;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet GraphView *accelGraphView;
@property (weak, nonatomic) IBOutlet UILabel *peakPowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *avePowerLabel;

@property (strong, nonatomic) coreMotionListener *motionListener;
@property (strong, nonatomic) NSString *templateType;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) AVAudioRecorder *recorder;

@end

@implementation TemplateSaverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.motionListener = [[coreMotionListener alloc] init];
    self.deviceMotionArray = [[NSMutableArray alloc] init];
    self.motionListener.delegate = self;
}

-(void)motionListener:(coreMotionListener *)listener didReceiveDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    [self.deviceMotionArray addObject:deviceMotion];
    if ([self.deviceMotionArray count] > MAX_ARRAY_LENGTH) {
        [self.deviceMotionArray removeObjectAtIndex:0];
    }
}

- (IBAction)startRecordingButtonPressed:(id)sender {
    self.countdownLabel.text = @"5";
    self.countdownTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    if (self.countdownTimer) {
    [[NSRunLoop currentRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
    }
    
}

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

-(void)countDown
{
    int timeLeft = [self.countdownLabel.text integerValue];
    timeLeft -= 1;
    if (timeLeft == 0) {
        [self.countdownTimer invalidate];
        [self.motionListener collectMotionInformationWithInterval:20];
        
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
        if(self.recorder) {
            NSLog(@"started recording");
        }
        [self.recorder record];
    }
    self.countdownLabel.text = [NSString stringWithFormat:@"%d", timeLeft];
}

/*int trimFromFront(float *array, float threshold, int length)
{
    // trims and returns how many floats were trimmed from the front of the array, based on threshold

    int removed=0;
 
    while (array && *array < threshold) {
        array++;
        removed++;
    }
    return removed;
}

int trimFromTail(float *array, float threshold, int length)
{
    // trims and returns how many floats were trimmed from the tail of the array, based on threshold
    
    if (!array) {
        return -1;
    }
    
    for (int i=length-1; i>=0; i--) {
        float curVal = array[i];
        if (curVal > threshold) {
            array = &array[i];
            return length - i;
        }
    }
    return -1;
} */

-(int)trimFromStart:(NSArray *)array withThreshold:(float)threshold
{
    // returns how many elements should be trimmed from head
    for (int i = 0; i < [array count]; i++) {
        if ([array[i] floatValue] > threshold) {
            return i;
        }
    }
    return 0;
}

-(int)trimFromEnd:(NSArray *)array withThreshold:(float)threshold
{
    // returns how many elements should be trimmed from head
    for (int i = [array count]-1; i > 0; i--) {
        if ([array[i] floatValue] > threshold) {
            return [array count] - i;
        }
    }
    return 0;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.motionListener stopCollectingMotionInformation];
    
    self.templateType = [[self.templateTypeSelection titleForSegmentAtIndex:self.templateTypeSelection.selectedSegmentIndex] stringByAppendingString:@"Template"];
    PFObject *template = [PFObject objectWithClassName:self.templateType];
    
    NSMutableArray *accelArrayX = [[NSMutableArray alloc] init];
    NSMutableArray *accelArrayY = [[NSMutableArray alloc] init];
    NSMutableArray *accelArrayZ = [[NSMutableArray alloc] init];
    
    NSMutableArray *rotationX = [[NSMutableArray alloc] init];
    NSMutableArray *rotationY = [[NSMutableArray alloc] init];
    NSMutableArray *rotationZ = [[NSMutableArray alloc] init];
    
    float threshold = 0.08;
    int length = [self.deviceMotionArray count];
    
    for (int i = 0; i < length; i++) {
        CMDeviceMotion *motion = self.deviceMotionArray[i];
        accelArrayX[i] = [NSNumber numberWithFloat:motion.userAcceleration.x];
        accelArrayY[i] = [NSNumber numberWithFloat:motion.userAcceleration.y];
        accelArrayZ[i] = [NSNumber numberWithFloat:motion.userAcceleration.z];
        
        rotationX[i] = [NSNumber numberWithFloat:motion.rotationRate.x];
        rotationY[i] = [NSNumber numberWithFloat:motion.rotationRate.y];
        rotationZ[i] = [NSNumber numberWithFloat:motion.rotationRate.z];
    }
    
    
    // how many should we clip off of the arrays? They should be the same size,
    // but we want to have the longest possible event occuring
    
    int startTrimX = [self trimFromStart:accelArrayX withThreshold:threshold];
    int endTrimX = [self trimFromEnd:accelArrayX withThreshold:threshold];
    
    int startTrimY = [self trimFromStart:accelArrayY withThreshold:threshold];
    int endTrimY = [self trimFromEnd:accelArrayY withThreshold:threshold];
    
    int startTrimZ = [self trimFromStart:accelArrayZ withThreshold:threshold];
    int endTrimZ = [self trimFromEnd:accelArrayZ withThreshold:threshold];
    
    int finalTrimStart = MIN(MIN(startTrimX, startTrimY), startTrimZ);
    int finalTrimEnd = MIN(MIN(endTrimX, endTrimY), endTrimZ);
    
    [accelArrayX removeObjectsInRange:NSMakeRange(0, finalTrimStart)];
    [accelArrayX removeObjectsInRange:NSMakeRange(length - finalTrimEnd - finalTrimStart, finalTrimEnd)];
    
    [accelArrayY removeObjectsInRange:NSMakeRange(0, finalTrimStart)];
    [accelArrayY removeObjectsInRange:NSMakeRange(length - finalTrimEnd - finalTrimStart, finalTrimEnd)];
    
    [accelArrayZ removeObjectsInRange:NSMakeRange(0, finalTrimStart)];
    [accelArrayZ removeObjectsInRange:NSMakeRange(length - finalTrimEnd - finalTrimStart, finalTrimEnd)];
    
    [self.recorder updateMeters];
    
    template[@"accelX"] = accelArrayX;
    template[@"accelY"] = accelArrayY;
    template[@"accelZ"] = accelArrayZ;
    template[@"rotationX"] = rotationX;
    template[@"rotationY"] = rotationY;
    template[@"rotationZ"] = rotationZ;
    template[@"peakPow"] = [NSNumber numberWithFloat:[self.recorder peakPowerForChannel:1]];
    template[@"avePow"] = [NSNumber numberWithFloat:[self.recorder averagePowerForChannel:1]];
    
    [template saveInBackground];
    [self.accelGraphView drawWithAccelerometerValues:accelArrayX Y:accelArrayY Z:accelArrayZ];
    self.peakPowerLabel.text = [NSString stringWithFormat:@"%f", [self.recorder peakPowerForChannel:1]];
    self.avePowerLabel.text = [NSString stringWithFormat:@"%f", [self.recorder averagePowerForChannel:1]];
    [self.recorder stop];
}

@end
