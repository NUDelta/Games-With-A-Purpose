//
//  GraphView.m
//  LocaleNatives
//
//  Created by Stephen Chan on 3/20/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawWithAccelerometerValues:(NSMutableArray *)X Y:(NSMutableArray *)Y Z:(NSMutableArray *)Z
{
    // assumes for now that there are fewer array elements than pixels in our view
    self.scaleFactorX = 1.0;
    if ([X count] > self.bounds.size.width) {
        self.scaleFactorX = self.bounds.size.width / [X count];
    }
    self.accelArrayX = X;
    self.accelArrayY = Y;
    self.accelArrayZ = Z;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.5);
    
    int length = [self.accelArrayX count];
    CGPoint points[length];
    
    // assume that acceleration doesn't go much beyond 5g's
    float scaleFactorY = self.bounds.size.height / 5;
    
    for (int i = 0; i < length; i++) {
        points[i] = CGPointMake(i * self.scaleFactorX, ([self.accelArrayX[i] floatValue] * scaleFactorY)+ self.bounds.origin.y + self.bounds.size.height / 2);
    }
    
    CGContextSetRGBStrokeColor(context, 255, 0, 0, 1);
    CGContextAddLines(context, points, length);
    CGContextStrokePath(context);
    
    for (int i = 0; i < length; i++) {
        points[i] = CGPointMake(i * self.scaleFactorX, ([self.accelArrayY[i] floatValue] * scaleFactorY)+ self.bounds.origin.y + self.bounds.size.height / 2);
    }
    
    CGContextSetRGBStrokeColor(context, 0, 255, 0, 1);
    CGContextAddLines(context, points, length);
    CGContextStrokePath(context);
    
    for (int i = 0; i < length; i++) {
        points[i] = CGPointMake(i * self.scaleFactorX, ([self.accelArrayZ[i] floatValue] * scaleFactorY)+ self.bounds.origin.y + self.bounds.size.height / 2);
    }
    
    CGContextSetRGBStrokeColor(context, 0, 0, 255, 1);
    CGContextAddLines(context, points, length);
    
    CGContextStrokePath(context);
}
         
@end
