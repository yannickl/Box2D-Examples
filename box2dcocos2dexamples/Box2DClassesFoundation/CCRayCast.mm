//
//  CCRayCast.m
//  Box2DCocos2DExamples
//
//  Created by Yannick Loriot on 08/01/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "CCRayCast.h"

@interface CCRayCast ()
@end

@implementation CCRayCast
@synthesize startPoint, endPoint;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.startPoint = CGPointZero;
        self.endPoint = CGPointZero;
    }
    return self;
}

#pragma mark -
#pragma mark CCRayCast Public Methods

#pragma mark CCRayCast Private Methods

@end
