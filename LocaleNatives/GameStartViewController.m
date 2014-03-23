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
#import "GestureTemplates.h"

@interface GameStartViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *gameMap;
@property (strong, nonatomic) NSString *gameTitle;
@property (strong, nonatomic) curbStomp *curbStompGame;
@property (strong, nonatomic) locationListener *listener;
@property BOOL playedBefore;
@property (strong, nonatomic) GestureTemplates *tester;
@property (weak, nonatomic) IBOutlet UITableView *gameOptionTable;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.curbStompGame = [[curbStomp alloc] init];
    self.listener = [[locationListener alloc] init];
    self.gameOptionTable.delegate = self;
    self.gameOptionTable.dataSource = self;
    [self initializeMap];
    NSLog(@"initialized game");
    if (!self.playedBefore) {
        [self displayIntroMessage];
        self.playedBefore = YES;
        self.tester = [[GestureTemplates alloc] init];
    }
}

- (void)displayIntroMessage
{
    /*UIAlertView *introMessage = [[UIAlertView alloc] initWithTitle:@"Get Started" message:@"Select where you're playing and give your phone a mighty shake! Then look to the text box for more instructions." delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
    [introMessage show]; */
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

- (void)initializeMap
 {
     [self.gameMap setRegion:MKCoordinateRegionMakeWithDistance(self.listener.locationManager.location.coordinate, 500, 500) animated:NO];
     self.gameMap.showsUserLocation = YES;
 }

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *gameCell = [tableView dequeueReusableCellWithIdentifier:@"gameOptionCell"];
    gameCell.textLabel.text = @"Wand Waver";
    return gameCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
