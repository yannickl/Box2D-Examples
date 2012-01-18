//
//  TestSliceBody.h
//  Box2DCocos2DExamples
//
//  Created by Yannick Loriot on 08/01/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "Box2dScene.h"

@class CCRayCast;

/**
 * Slice/Split/Cut body example scene.
 * Slicing, splitting and cutting objects with Box2D.
 */
@interface TestSliceBody : Box2dScene
{
@public
@protected
    // Laser drawn by the user to cut bodies
    CCRayCast *laser;
}

#pragma mark Constructors - Initializers

#pragma mark Public Methods

@end
