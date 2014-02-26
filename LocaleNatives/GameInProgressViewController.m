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
@property (weak, nonatomic) IBOutlet UILabel *activityDetectedLabel;
@property (strong, nonatomic) IBOutlet MKMapView *gameMap;

@end

@implementation GameInProgressViewController

-(void)motionClassifier:(motionClassifier *)classifier didRegisterAction:(NSString *)action
{
    self.action = action;
    [NSThread detachNewThreadSelector:@selector(displayAlert) toTarget:self withObject:nil];
}

- (void)displayAlert
{
    self.activityDetectedLabel.text = self.action;
    MKPointAnnotation *currentLocationPin = [[MKPointAnnotation alloc] init];
    [currentLocationPin setCoordinate:self.classifier.location.locationManager.location.coordinate];
    [currentLocationPin setTitle:@"Jump"];
    [self.gameMap addAnnotation:currentLocationPin];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classifier = [[motionClassifier alloc] init];
    self.classifier.delegate = self;
    if (self.classifier) {
        NSLog(@"initialized classifier");
        [self.classifier.motionListener collectMotionInformationWithInterval:100];
        [self.classifier startClassifyingMotion];
    }

    [self initializeMap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.classifier.motionListener stopCollectingMotionInformation];
    [self.classifier stopClassifyingMotion];
    [super viewWillDisappear:animated];
}

- (void)initializeMap
{
    [self.gameMap setRegion:MKCoordinateRegionMakeWithDistance(self.classifier.location.locationManager.location.coordinate, 500, 500) animated:NO];
    self.gameMap.showsUserLocation = YES;
}

@end
