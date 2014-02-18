//
//  GameInProgressViewController.h
//  LocaleNatives
//
//  Created by Stephen Chan on 1/27/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "motionClassifier.h"

@interface GameInProgressViewController : UIViewController <motionClassifierDelegate>

@property (strong, nonatomic) motionClassifier *classifier;
@property (strong, nonatomic) NSString *action;

- (void)motionClassifier:(motionClassifier *)classifier didRegisterAction:(NSString *)action;

@end
