//
//  Box2DSceneManager.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 29/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "cocos2d.h"

@interface Box2DSceneManager : NSObject
{
@private
    NSInteger currentBox2DSceneId;
    NSArray *box2DScenes;
}

#pragma mark Constructors - Initializers

/** Returns the singleton box2d scene manager. */
+ (Box2DSceneManager *)sharedBox2DSceneManager;

#pragma mark Public Methods

/** Returns the next box2d scene. */
- (CCScene *)nextBox2DScene;

/** Returns the previous box2d scene. */
- (CCScene *)previousBox2DScene;

/** Returns the current box2d scene. */
- (CCScene *)currentBox2DScene;

@end
