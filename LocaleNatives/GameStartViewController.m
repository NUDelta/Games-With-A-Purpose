//
//  ViewController.m
//  LocaleNatives
//
//  Created by Stephen Chan on 12/24/13.
//  Copyright (c) 2013 Stephen Chan. All rights reserved.
//

#import "GameStartViewController.h"
#import "locationListener.h"
#import "GameInProgressViewController.h"
#import "coreMotionListener.h"
#import "motionClassifier.h"
#import "curbStomp.h"

@interface GameStartViewController ()

@property (weak, nonatomic) IBOutlet UITextView *gameInstructionMessage;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameLocationControl;
@property (strong, nonatomic) NSString *gameTitle;
@property (strong, nonatomic) curbStomp *curbStompGame;
@property BOOL playedBefore;

@end

@implementation GameStartViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GameStarting"]) {
        NSLog(@"game starting!");
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.curbStompGame stopLocationListener];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    static int INDOORS = 1;
    static int OUTDOORS = 0;
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"shake!");
        if (self.gameLocationControl.selectedSegmentIndex == OUTDOORS) {
            self.gameInstructionMessage.text = self.curbStompGame.gameInstructions;
            NSLog(@"%@", self.curbStompGame.gameInstructions);
            self.navigationItem.title = @"Curb Stomp";
        } else {
            self.gameInstructionMessage.text = @"test";
            self.navigationItem.title = @"Squat City";
        }
        self.gameInstructionMessage.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        self.gameInstructionMessage.textAlignment = NSTextAlignmentCenter;
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.curbStompGame = [[curbStomp alloc] init];
    NSLog(@"initialized game");
    if (!self.playedBefore) {
        [self displayIntroMessage];
        self.playedBefore = YES;
    }
}

- (void)displayIntroMessage
{
    UIAlertView *introMessage = [[UIAlertView alloc] initWithTitle:@"Get Started" message:@"Select where you're playing and give your phone a mighty shake! Then look to the text box for more instructions." delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
    [introMessage show];
}

- (NSArray *)validGameMessages
{
    NSString *curbStomp = @"Get thee to the nearest street corner. Once there, two things may happen. If you see a ramp descending to the street, stomp your way down mightily like a T. Rex descending its throne. If there is only the curb, jump high and get your best airtime - aim to land in a puddle if that's your thing.";
    NSString *waveRunner = @"Wander your way to the shoreline. As the waves come rolling in, run alongside the tide. Feel yourself unwind from the burdens of life, but try not to get your feet wet.";
    NSString *slapSign = @"Suddenly, you find yourself feeling inexplicable rage against the law and all that keeps us in order. In the next 2 minutes, find as many stop signs as you can. When you see one, give it a good, hard slap and possibly a stern talking to.";
    return @[curbStomp, waveRunner, slapSign];
}

- (NSArray *)validGameTitles
{
    NSString *curbStomp = @"Curb Stomp";
    NSString *waveRunner = @"Wave Runner";
    NSString *slapSign = @"Slap Sign";
    return @[curbStomp, waveRunner, slapSign];
}

@end
