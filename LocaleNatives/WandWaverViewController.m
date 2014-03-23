//
//  WandWaverViewController.m
//  LocaleNatives
//
//  Created by Stephen Chan on 3/12/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "WandWaverViewController.h"

@interface WandWaverViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *memeImage;

@end

@implementation WandWaverViewController

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
        [super motionEnded:motion withEvent:event];
        self.memeImage.image = [UIImage imageNamed:@"Hagrid"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"wand waver");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
