//
//  Box2dScene.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 12/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#import "cocos2d.h"

#import "Box2D.h"
#import "GLES-Render.h"

@interface Box2dScene : CCLayer
{
@public
    b2World *world;
    
@private
	GLESDebugDraw *m_debugDraw;
    
    // Vector of actual mouse position
	b2Vec2 m_mouseWorld;
    
	// Body to hold one side of joint
	b2Body *holdJoint;
    
    NSMutableArray *touchJointList;
}
@property (readonly) b2World *world;

/**
 * Returns a CCScene that contains the Box2dScene layer.
 */
+ (CCScene *)scene;

// Public Methods

@end
