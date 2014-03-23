//
//  GraphView.h
//  LocaleNatives
//
//  Created by Stephen Chan on 3/20/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GraphView : UIView

@property float scaleFactorX;
@property (strong, nonatomic) NSMutableArray *accelArrayX;
@property (strong, nonatomic) NSMutableArray *accelArrayY;
@property (strong, nonatomic) NSMutableArray *accelArrayZ;

-(void)drawWithAccelerometerValues:(NSMutableArray *)X Y:(NSMutableArray *)Y Z:(NSMutableArray *)Z;

@end
