//
//  Box2DSceneManager.m
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 29/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "Box2DSceneManager.h"

#import "Box2dScene.h"

@interface Box2DSceneManager ()
/** Box2d scene id. */
@property (nonatomic, assign) NSInteger currentBox2DSceneId;
/** List of box2d scene's names. */
@property (nonatomic, retain) NSArray *box2DScenes;

@end

@implementation Box2DSceneManager
@synthesize currentBox2DSceneId, box2DScenes;

static Box2DSceneManager *box2DSceneManager = nil;

- (void)dealloc
{
    [box2DScenes release], box2DScenes = nil;
    
    if (box2DSceneManager)
    {
        [box2DSceneManager release];
    }
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        currentBox2DSceneId = 0;
        
        box2DScenes = [[NSArray alloc] initWithObjects:
                       @"TestRagdoll",
                       @"TestBuoyancy",
                       @"TestSliceBody",
                       nil];
    }
    return self;
}

+ (Box2DSceneManager *)sharedBox2DSceneManager
{
    @synchronized (self)
    {
        if (box2DSceneManager == nil)
        {
            box2DSceneManager = [[Box2DSceneManager alloc] init];
        }
        return box2DSceneManager;
    }
}

#pragma mark -
#pragma mark Box2DSceneManager Public Methods

- (CCScene *)nextBox2DScene
{
    currentBox2DSceneId = (currentBox2DSceneId + 1) % [box2DScenes count];
    
	return [self currentBox2DScene];
}

- (CCScene *)previousBox2DScene
{
    currentBox2DSceneId = currentBox2DSceneId - 1;
    if (currentBox2DSceneId < 0)
    {
        currentBox2DSceneId = [box2DScenes count] - 1;
    }
    
	return [self currentBox2DScene];
}

- (CCScene *)currentBox2DScene
{
	NSString *box2DSceneName = [box2DScenes objectAtIndex:currentBox2DSceneId];
    
    Class nextBox2DScene = NSClassFromString(box2DSceneName);
	return [nextBox2DScene sceneWithTitle:box2DSceneName];
}

#pragma mark Box2DSceneManager Private Methods

@end
