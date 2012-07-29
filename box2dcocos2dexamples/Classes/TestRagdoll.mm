/**
 * TestRagdoll.m is a port to Box2D/Cocos2D of Box2DAS3 Ragdoll example,
 * originally written by Matthew Bush (skatehead [at] gmail.com).
 *
 * Modified by Yannick Loriot
 * http://yannickloriot.com
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#import "TestRagdoll.h"

#import "Box2DExamples.h"

#define RAGDOLLNUMBER 2 // Initial ragdoll number
#define STAIRNUMBER 7   // Number of stairs

@interface TestRagdoll ()

/** Add a new ragdoll into the world at the given position */
- (void)addNewRagDollAtPosition:(CGPoint)ragDollPosition;
/** Generate the stairs into the world */
- (void)generateStairs;

@end

@implementation TestRagdoll

- (void)dealloc
{
	[super dealloc];
}

- (id)init
{
	if ((self = [super init]))
    {
        float posX, posY;

        // Get the screen size
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        // Generate stairs
        [self generateStairs];
        
        // Add ragdolls along the top
        for (int i = 0; i < RAGDOLLNUMBER; i++)
        {
            posX = screenSize.width / 4 + random() % (int)(screenSize.width / 2);
            posY = screenSize.height / 2;
            
            [self addNewRagDollAtPosition:ccp (posX, posY)];
        }
    }
    return self;
}

#pragma mark -
#pragma mark TestRagdoll Public Methods

#pragma mark TestRagdoll Private Methods

- (void)addNewRagDollAtPosition:(CGPoint)_ragDollPosition
{
    // -------------------------
    // Bodies ------------------
    // -------------------------
    
    // Set these to dynamics bodies
    b2BodyDef bd;
    bd.type = b2_dynamicBody;

    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    
    // Head ------
    b2CircleShape headShape;
    headShape.m_radius = ptm(12.5f);
    fixtureDef.shape = &headShape;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.3f;
    bd.position.Set(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y));
    b2Body *head = world->CreateBody(&bd);
    head->CreateFixture(&fixtureDef);
    head->ApplyLinearImpulse(b2Vec2(random() % 100 - 50.0f, random() % 100 - 50.0f), head->GetWorldCenter());
    
    // -----------

    // Torso1 ----
    box.SetAsBox(ptm(15.0f), ptm(10.0f));
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    bd.position.Set(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 25.0f));
    b2Body *torso1 = world->CreateBody(&bd);
    torso1->CreateFixture(&fixtureDef);
    
    // -----------

    // Torso2 ----
    box.SetAsBox(ptm(15.0f), ptm(10.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 43.0f));
    b2Body *torso2 = world->CreateBody(&bd);
    torso2->CreateFixture(&fixtureDef);
    
    // -----------

    // Torso3 ----
    box.SetAsBox(ptm(15.0f), ptm(10.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 58.0f));
    b2Body *torso3 = world->CreateBody(&bd);
    torso3->CreateFixture(&fixtureDef);
    
    // -----------

    // UpperArm --
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;

    // Left
    box.SetAsBox(ptm(18.0f), ptm(6.5f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x - 30.0f), ptm(_ragDollPosition.y + 20.0f));
    b2Body *upperArmL = world->CreateBody(&bd);
    upperArmL->CreateFixture(&fixtureDef);

    // Right
    box.SetAsBox(ptm(18.0f), ptm(6.5f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x + 30.0f), ptm(_ragDollPosition.y + 20.0f));
    b2Body *upperArmR = world->CreateBody(&bd);
    upperArmR->CreateFixture(&fixtureDef);
    
    // -----------

    // Lower Arm
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    
    // Left
    box.SetAsBox(ptm(17.0f), ptm(6.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x - 57.0f), ptm(_ragDollPosition.y + 20.0f));
    b2Body *lowerArmL = world->CreateBody(&bd);
    lowerArmL->CreateFixture(&fixtureDef);
    
    // Right
    box.SetAsBox(ptm(17.0f), ptm(6.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x + 57.0f), ptm(_ragDollPosition.y + 20.0f));
    b2Body *lowerArmR = world->CreateBody(&bd);
    lowerArmR->CreateFixture(&fixtureDef);
    
    // -----------

    // UpperLeg --
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    
    // Left
    box.SetAsBox(ptm(7.5f), ptm(22.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x - 8.0f), ptm(_ragDollPosition.y + 85.0f));
    b2Body *upperLegL = world->CreateBody(&bd);
    upperLegL->CreateFixture(&fixtureDef);
    
    // Right
    box.SetAsBox(ptm(7.5f), ptm(22.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x + 8.0f), ptm(_ragDollPosition.y + 85.0f));
    b2Body *upperLegR = world->CreateBody(&bd);
    upperLegR->CreateFixture(&fixtureDef);
    
    // -----------

    // LowerLeg --
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    
    // Left
    box.SetAsBox(ptm(6.0f), ptm(20.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x - 8.0f), ptm(_ragDollPosition.y + 120.0f));
    b2Body *lowerLegL = world->CreateBody(&bd);
    lowerLegL->CreateFixture(&fixtureDef);
    
    // Right
    box.SetAsBox(ptm(6.0f), ptm(20.0f));
    fixtureDef.shape = &box;
    bd.position.Set(ptm(_ragDollPosition.x + 8.0f), ptm(_ragDollPosition.y + 120.0f));
    b2Body *lowerLegR = world->CreateBody(&bd);
    lowerLegR->CreateFixture(&fixtureDef);
    // -----------

    // -------------------------
    // Joints ------------------
    // -------------------------
    
    b2RevoluteJointDef jd;
    jd.enableLimit = true;
    
    // Head to shoulders
    jd.lowerAngle = -40.0f / (180.0f / M_PI);
    jd.upperAngle = 40.0f / (180.0f / M_PI);
    jd.Initialize(torso1, head, b2Vec2(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 15.0f)));
    world->CreateJoint(&jd);
    
    // Upper arm to shoulders --
    // Left
    jd.lowerAngle = -85.0f / (180.0f / M_PI);
    jd.upperAngle = 130.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperArmL, b2Vec2(ptm(_ragDollPosition.x - 18.0f), ptm(_ragDollPosition.y + 20.0f)));
    world->CreateJoint(&jd);
    
    // Right
    jd.lowerAngle = -130.0f / (180.0f / M_PI);
    jd.upperAngle = 85.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperArmR, b2Vec2(ptm(_ragDollPosition.x + 18.0f), ptm(_ragDollPosition.y + 20.0f)));
    world->CreateJoint(&jd);
    
    // -------------------------
    
    // Lower arm to shoulders --
    // Left
    jd.lowerAngle = -130.0f / (180.0f / M_PI);
    jd.upperAngle = 10.0f / (180.0f / M_PI);
    jd.Initialize(upperArmL, lowerArmL, b2Vec2(ptm(_ragDollPosition.x - 45.0f), ptm(_ragDollPosition.y + 20.0f)));
    world->CreateJoint(&jd);
    
    // Right
    jd.lowerAngle = -10.0f / (180.0f / M_PI);
    jd.upperAngle = 130.0f / (180.0f / M_PI);
    jd.Initialize(upperArmR, lowerArmR, b2Vec2(ptm(_ragDollPosition.x + 45.0f), ptm(_ragDollPosition.y + 20.0f)));
    world->CreateJoint(&jd);
    
    // -------------------------
    
    // Shoulders / stomach -----
    jd.lowerAngle = -15.0f / (180.0f / M_PI);
    jd.upperAngle = 15.0f / (180.0f / M_PI);
    jd.Initialize(torso1, torso2, b2Vec2(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 35.0f)));
    world->CreateJoint(&jd);
    
    // Stomach / hips
    jd.Initialize(torso2, torso3, b2Vec2(ptm(_ragDollPosition.x), ptm(_ragDollPosition.y + 50.0f)));
    world->CreateJoint(&jd);
    
    // -------------------------
    
    // Torso to upper leg ------
    // Left
    jd.lowerAngle = -25.0f / (180.0f / M_PI);
    jd.upperAngle = 45.0f / (180.0f / M_PI);
    jd.Initialize(torso3, upperLegL, b2Vec2(ptm(_ragDollPosition.x - 8), ptm(_ragDollPosition.y + 72.0f)));
    world->CreateJoint(&jd);
    
    // Right
    jd.lowerAngle = -45.0f / (180.0f / M_PI);
    jd.upperAngle = 25.0f / (180.0f / M_PI);
    jd.Initialize(torso3, upperLegR, b2Vec2(ptm(_ragDollPosition.x + 8), ptm(_ragDollPosition.y + 72.0f)));
    world->CreateJoint(&jd);
    
    // -------------------------
    
    // Upper leg to lower leg --
    // Left
    jd.lowerAngle = -25.0f / (180.0f / M_PI);
    jd.upperAngle = 115.0f / (180.0f / M_PI);
    jd.Initialize(upperLegL, lowerLegL, b2Vec2(ptm(_ragDollPosition.x - 8), ptm(_ragDollPosition.y + 105.0f)));
    world->CreateJoint(&jd);
    
    // Right
    jd.lowerAngle = -115.0f / (180.0f / M_PI);
    jd.upperAngle = 25.0f / (180.0f / M_PI);
    jd.Initialize(upperLegR, lowerLegR, b2Vec2(ptm(_ragDollPosition.x + 8), ptm(_ragDollPosition.y + 105.0f)));
    world->CreateJoint(&jd);
    
    // -------------------------
}

- (void)generateStairs
{
    // Get the screen size
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    // Set stairs as static bodies
    b2BodyDef bd;
    bd.type = b2_staticBody;
    
    // Stairs ------
    b2FixtureDef fixtureDef;
    fixtureDef.density = 0.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.3f;
    
    b2PolygonShape stairShape;
    
    // Left
    for (int i = 0; i <= STAIRNUMBER; i++)
    {
        stairShape.SetAsBox(ptm(10.0f * (STAIRNUMBER + 1 - i)), ptm(10.0f));
        fixtureDef.shape = &stairShape;
        bd.position.Set(ptm(STAIRNUMBER * 10.0f - 10.0f * i), ptm(10.0f + 20.0f * i));
        
        b2Body *stair = world->CreateBody(&bd);
        stair->CreateFixture(&fixtureDef);
    }
    
    // Right
    for (int i = 0; i <= STAIRNUMBER; i++)
    {
        stairShape.SetAsBox(ptm(10.0f * (STAIRNUMBER + 1 - i)), ptm(10.0f));
        fixtureDef.shape = &stairShape;
        bd.position.Set(ptm(screenSize.width - STAIRNUMBER * 10.0f + 10.0f * i), ptm(10.0f + 20.0f * i));
        
        b2Body *stair = world->CreateBody(&bd);
        stair->CreateFixture(&fixtureDef);
    }
    
    // -------------
    
    // Center box --
    b2PolygonShape centerBox;
    centerBox.SetAsBox(ptm(30.0f), ptm(30.0f));
    fixtureDef.shape = &centerBox;
    bd.position.Set(ptm(screenSize.width / 2), ptm(30.0f));
    
    b2Body *centerBoxBody = world->CreateBody(&bd);
    centerBoxBody->CreateFixture(&fixtureDef);
    
    // -------------
}

@end
