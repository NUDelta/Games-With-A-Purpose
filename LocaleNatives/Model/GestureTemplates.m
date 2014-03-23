//
//  pListTester.m
//  LocaleNatives
//
//  Created by Stephen Chan on 3/7/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "GestureTemplates.h"
#import <Parse/Parse.h>

@interface GestureTemplates()

@property (strong, nonatomic)NSMutableArray *knockAccelTemplates;
@property (strong, nonatomic) NSMutableArray *stompAccelTemplates;
@property float *floats;

@end

@implementation GestureTemplates

struct point3D {
    float x;
    float y;
    float z;
};

- (instancetype)init
{
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"KnockTemplates" ofType:@"plist"];
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"KnockTemplates.plist"];
        
        self.pListArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        [self.pListArray addObject:@"three"];
        ///NSLog(@"%@", filePath);
        

        BOOL status = [self.pListArray writeToFile:filePath atomically:YES];
        if (status) {
           // NSLog(@"%@", self.pListArray);
        }
        NSArray *accelXArray = @[@0.165329,
                                 @0.1190491,
                                 @0.06028748,
                                 @0.1483917,
                                 @0.0289917,
                                 @0.08029175,
                                 @0.01831055,
                                 @0.01831055,
                                 @0.04785156,
                                 @0.06681824];
        NSArray *accelYArray = @[@0.3035126,
                                 @0.03604126,
                                 @0.0113678,
                                 @0.08326721,
                                 @(-0.03297424),
                                 @0.01913452,
                                 @(-0.01977539),
                                 @(-0.01977539),
                                 @0.02526855,
                                 @0.0401001];
        NSArray *accelZArray = @[@0.2746582,
                                 @(-2.007889),
                                 @(-0.6647034),
                                 @(-0.7673645),
                                 @(-1.037872),
                                 @(-0.9421539),
                                 @(-1.118668),
                                 @(-1.118668),
                                 @(-0.9449463),
                                 @(-0.9277344)];
        
        
        
        NSArray *accelZArray2 = @[@(-0.2785496),
                                  @(0.4855987),
                                  @(0.7735581),
                                  @(0.8247727),
                                  @(0.2631507),
                                  @(0.1339757),
                                  @(0.0696331),
                                  @(0.1986893),
                                  @(0.2828922),
                                  @(0.2599975),
                                  @(0.3119451),
                                  @(0.3544316),
                                  @(0.3435668),
                                  @(0.01867229),
                                  @(0.1213014),
                                  @(0.3125122),
                                  @(0.1501174),
                                  @(-0.05701726),
                                  @(-0.3247143),
                                  @(-0.3149983),
                                  @(-0.6001411),
                                  @(-0.8713327),
                                  @(-0.6687438),
                                  @(-0.4091719),
                                  @(-0.2072452),
                                  @(-0.1575086)];
        
        NSArray *accelYArray2 = @[@(-0.05960215),
                                  @(0.08463857),
                                  @(-0.01427207),
                                  @(-0.03112262),
                                  @(-0.004407194),
                                  @(0.1120527),
                                  @(0.1192815),
                                  @(0.05650664),
                                  @(0.01153289),
                                  @(0.02202101),
                                  @(0.02850364),
                                  @(0.02885715),
                                  @(-0.01802785),
                                  @(-0.04937492),
                                  @(-0.07315116),
                                  @(-0.005849538),
                                  @(0.04792369),
                                  @(-0.02730505),
                                  @(-0.1094194),
                                  @(-0.1076237),
                                  @(-0.1283891),
                                  @(-0.1656725),
                                  @(-0.1354991),
                                  @(-0.1874838),
                                  @(-0.1585337),
                                  @(-0.161855)];
        
        NSArray *accelXArray2 = @[@(-0.10655),
                                  @(0.075178),
                                  @(0.1386631),
                                  @(0.1495024),
                                  @(0.1522498),
                                  @(0.03004405),
                                  @(-0.03769776),
                                  @(-0.02846963),
                                  @(-0.006852143),
                                  @(0.08984525),
                                  @(0.1968621),
                                  @(0.1941424),
                                  @(0.2074532),
                                  @(0.1545337),
                                  @(0.1373218),
                                  @(0.03278341),
                                  @(-0.1245597),
                                  @(-0.1456911),
                                  @(-0.1559576),
                                  @(-0.1572813),
                                  @(-0.2117343),
                                  @(-0.2976038),
                                  @(-0.2851224),
                                  @(-0.2796181),
                                  @(-0.3105959),
                                  @(-0.3424593)];
        
        NSArray *accelZArray3 = @[@(-0.07393296),
                         @(-1.01186),
                         @(-1.011857),
                         @(-0.08415503),
                         @(0.07502297),
                         @(-0.002908462),
                         @(0.1487177),
                         @(-0.04148787),
                         @(0.0554955),
                         @(0.09991042),
                         @(0.09991115),
                         @(-0.07023831)];
        
        NSArray *accelYArray3 = @[@(-0.1722315),
                                  @(0.1972423),
                                  @(0.1969747),
                                  @(0.01128415),
                                  @(0.08670302),
                                  @(-0.122337),
                                  @(0.134144),
                                  @(-0.01266716),
                                  @(-0.04858406),
                                  @(0.09751874),
                                  @(0.09752917),
                                  @(-0.1043413)];
        
        NSArray *accelXArray3 = @[@(-0.1852999),
                                  @(-0.05340722),
                                  @(-0.05344576),
                                  @(-0.13831),
                                  @(-0.06637816),
                                  @(-0.06439403),
                                  @(0.0453353),
                                  @(0.03109631),
                                  @(0.06127746),
                                  @(0.09706759),
                                  @(0.09711572),
                                  @(0.02757045)];
        
        NSArray *accelZArray4 = @[@(0.00390357),
                                  @(0.4290144),
                                  @(-0.3656223),
                                  @(-0.04880674),
                                  @(-0.03046594),
                                  @(0.05599038),
                                  @(0.04388916),
                                  @(0.05315042),
                                  @(0.05314963),
                                  @(-0.04613889),
                                  @(0.09032001),
                                  @(-0.02576311)];
        
        NSArray *accelYArray4 = @[@(-0.00279557),
                                  @(-0.03223516),
                                  @(0.09053628),
                                  @(-0.04017616),
                                  @(-0.04559481),
                                  @(0.1049623),
                                  @(-0.100005),
                                  @(0.04810826),
                                  @(0.04807746),
                                  @(0.05338365),
                                  @(-0.07447792),
                                  @(-0.03547174)];
        
        NSArray *accelXArray4 = @[@(0.001648337),
                                  @(-0.004960945),
                                  @(-0.0878102),
                                  @(-0.1341095),
                                  @(-0.1087701),
                                  @(-0.04288673),
                                  @(-0.03926231),
                                  @(0.004135391),
                                  @(0.004068481),
                                  @(0.03862945),
                                  @(0.04410728),
                                  @(0.03563421)];
        
        NSDictionary *knockTemplate1 = @{ @"X" : accelXArray, @"Y" : accelYArray, @"Z" : accelZArray };
        NSDictionary *knockTemplate2 = @{ @"X" : accelXArray2, @"Y" : accelYArray2, @"Z" : accelZArray2 };
        NSDictionary *knockTemplate3 = @{ @"X" : accelXArray3, @"Y" : accelYArray3, @"Z" : accelZArray3 };
        NSDictionary *knockTemplate4 = @{ @"X" : accelXArray4, @"Y" : accelYArray4, @"Z" : accelZArray4 };
        
        self.knockAccelTemplates = [[NSMutableArray alloc] init];
        [self.knockAccelTemplates addObject:knockTemplate1];
        [self.knockAccelTemplates addObject:knockTemplate2];
        [self.knockAccelTemplates addObject:knockTemplate3];
        [self.knockAccelTemplates addObject:knockTemplate4];
        
        self.stompAccelTemplates = [[NSMutableArray alloc] init];
        PFQuery *query = [PFQuery queryWithClassName:@"StompTemplate"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *stompTemplate in objects) {
                NSMutableDictionary *stompTemp = [[NSMutableDictionary alloc] init];
                [stompTemp setValue:stompTemplate[@"accelX"] forKey:@"X"];
                [stompTemp setValue:stompTemplate[@"accelY"] forKey:@"Y"];
                [stompTemp setValue:stompTemplate[@"accelZ"] forKey:@"Z"];
                [self.stompAccelTemplates addObject:stompTemp];
                stompTemp = nil;
            }
        }];
    }
    return self;
}

-(NSArray *)knockAccelerometerTemplates
{
    return self.knockAccelTemplates;
}

-(NSArray *)stompAccelerometerTemplates
{
    return self.stompAccelTemplates;
}

@end
