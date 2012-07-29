//
//  Box2dScene.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 12/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "cocos2d.h"

#import "Box2D.h"
#import "GLES-Render.h"

/**
 * Box2D scene.
 * Contains the box2D world with the management mutli-touch
 * and accelerometer.
 */
@interface Box2dScene : CCLayer
{
@public
    CCLabelTTF *sceneTitleLabel;
    
    b2World *world;
    GLESDebugDraw *m_debugDraw;
    
@private
    // Vector of actual mouse position
	b2Vec2 m_mouseWorld;
    
	// Body to hold one side of joint
	b2Body *holdJoint;
    
    NSMutableArray *touchJointList;
}
/** Title label of the scene. */
@property (nonatomic, retain) CCLabelTTF *sceneTitleLabel;
/** Box2D world. */
@property (readonly) b2World *world;
/** GLES Debug draw. */
@property (readonly) GLESDebugDraw *m_debugDraw;

#pragma mark Constructors - Initializers

/**
 * Returns a CCScene that contains the Box2dScene layer.
 *
 * @param title The title of the scene.
 */
+ (CCScene *)sceneWithTitle:(NSString *)title;

#pragma mark Public Methods

@end
