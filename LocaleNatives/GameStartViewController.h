//
//  ViewController.h
//  LocaleNatives
//
//  Created by Stephen Chan on 12/24/13.
//  Copyright (c) 2013 Stephen Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GameStartViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

- (NSArray *)validGameMessages;

@end
