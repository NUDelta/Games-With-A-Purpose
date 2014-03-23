//
//  GameInProgressViewController.m
//  LocaleNatives
//
//  Created by Stephen Chan on 1/27/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "GameInProgressViewController.h"
#import "locationListener.h"

@interface GameInProgressViewController ()
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation GameInProgressViewController

-(void)motionClassifier:(motionClassifier *)classifier didRegisterAction:(NSString *)action
{
    self.action = action;
    [NSThread detachNewThreadSelector:@selector(displayAlert) toTarget:self withObject:nil];
}

- (void)displayAlert
{
    /*self.activityDetectedLabel.text = self.action;
    MKPointAnnotation *currentLocationPin = [[MKPointAnnotation alloc] init];
    [currentLocationPin setCoordinate:self.classifier.location.locationManager.location.coordinate];
    [currentLocationPin setTitle:@"Jump"];
    [self.gameMap addAnnotation:currentLocationPin]; */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"shake!");
        [self.player play];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classifier = [[motionClassifier alloc] init];
    self.classifier.delegate = self;
    if (self.classifier) {
        NSLog(@"initialized classifier");
        [self.classifier.motionListener collectMotionInformationWithInterval:20];
        [self.classifier startClassifyingMotion];
    }
    
    NSString *spellSound = [[NSBundle mainBundle] pathForResource:@"FFLife1" ofType:@"mp3"];
    NSURL *spellSoundURL   = [NSURL fileURLWithPath:spellSound];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:spellSoundURL error:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.classifier.motionListener stopCollectingMotionInformation];
    [self.classifier stopClassifyingMotion];
    [super viewWillDisappear:animated];
}

@end
