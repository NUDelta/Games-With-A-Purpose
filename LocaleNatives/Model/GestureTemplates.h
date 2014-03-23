//
//  pListTester.h
//  LocaleNatives
//
//  Created by Stephen Chan on 3/7/14.
//  Copyright (c) 2014 Stephen Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GestureTemplates : NSObject

@property (strong, nonatomic) NSMutableArray *pListArray;

-(NSArray *)knockAccelerometerTemplates;
-(NSArray *)jumpAccelerometerTemplates;
-(NSArray *)stompAccelerometerTemplates;

@end
