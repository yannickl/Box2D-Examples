//
//  CCTouchJoint.m
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 12/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#import "CCTouchJoint.h"

@implementation CCTouchJoint
@synthesize mouseJoint;
@synthesize touch;

- (void)dealloc
{
    [touch release];
    [super dealloc];
}

- (id)initLocal:(UITouch *)_touch withMouseJoint:(b2MouseJoint *)_mouseJoint
{
	if ((self = [super init]))
    {
		self.touch = _touch;
		mouseJoint = _mouseJoint;
	}
	return self;
}

+ (id)touch:(UITouch *)_touch withMouseJoint:(b2MouseJoint *)_mouseJoint
{
	return [[self alloc] initLocal:_touch withMouseJoint:_mouseJoint];
}

#pragma mark -
#pragma mark CCTouchJoint Public Methods

- (void)destroyTouchJoint
{
    if (mouseJoint != NULL)
    {
        mouseJoint->GetBodyA()->GetWorld()->DestroyJoint(mouseJoint);
    }
}

#pragma mark CCTouchJoint Private Methods

@end
