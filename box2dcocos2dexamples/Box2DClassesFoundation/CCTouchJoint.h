//
//  CCTouchJoint.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 12/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#import "Box2D.h"

@interface CCTouchJoint : NSObject
{
@public
    b2MouseJoint *mouseJoint;
    UITouch *touch;
}
@property (assign) b2MouseJoint *mouseJoint;
@property (nonatomic, retain) UITouch *touch;

- (id)initLocal:(UITouch *)touch withMouseJoint:(b2MouseJoint *)mouseJoint;
+ (id)touch:(UITouch *)touch withMouseJoint:(b2MouseJoint *)mouseJoint;

// Public methods

/**
 * Destroy the touch joint in the Box2d world.
 */
- (void)destroyTouchJoint;

@end
