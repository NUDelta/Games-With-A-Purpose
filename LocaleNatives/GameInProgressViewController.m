//
//  GameInProgressViewController.m
//  LocaleNatives
//
//  Created by Stephen Chan on 1/27/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "GameInProgressViewController.h"

@interface GameInProgressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *activityDetectedLabel;


@end

@implementation GameInProgressViewController

-(void)motionClassifier:(motionClassifier *)classifier didRegisterAction:(NSString *)action
{
    self.action = action;
    [NSThread detachNewThreadSelector:@selector(displayAlert) toTarget:self withObject:nil];
    //NSLog(@"registered action");
}

- (void)displayAlert
{
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:self.action delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    //[alert show];
    self.activityDetectedLabel.text = self.action;
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
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.classifier.motionListener stopCollectingMotionInformation];
    [self.classifier stopClassifyingMotion];
    [super viewWillDisappear:animated];
}

@end
