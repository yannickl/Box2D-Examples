//
//  TestRagdoll.h
//  box2dcocos2dexamples
//
//  Created by Yannick LORIOT on 20/05/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#import "Box2dScene.h"

@interface TestRagdoll : Box2dScene
{
@private
    b2CircleShape circ;
    b2PolygonShape box;
    b2BodyDef bd;
    b2RevoluteJointDef jd;
    b2FixtureDef fixtureDef;
}

// Public Methods

@end
