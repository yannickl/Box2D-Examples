//
//  TestSliceBody.m
//  Box2DCocos2DExamples
//
//  Created by Yannick Loriot on 08/01/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//
//  Inspired from the Emanuele Feronato and Antoan Angelov 
//  tutorials:
//  http://www.emanueleferonato.com/2011/08/05/slicing-splitting-and-cutting-objects-with-box2d-part-4-using-real-graphics/
//

#import "TestSliceBody.h"

#import "Box2DExamples.h"
#import "CCRayCast.h"

#import "QueryCallback.h"
#import "RayCastCallback.h"

enum
{
    maxVerticesPerBody = 20     // Defines the max number of vertex per body
};

/**
 * determinant
 *
 * Finds the determinant of a 3x3 matrix.
 * If you studied matrices, you'd know that it returns a positive number
 * if three given points are in clockwise order, negative if they are in
 * anti-clockwise order and zero if they lie on the same line.
 * Another useful thing about determinants is that their absolute value
 * is two times the face of the triangle, formed by the three given points.
 */
float determinant(float x1, float y1, float x2, float y2, float x3, float y3)
{
    return x1 * y2 + x2 * y3 + x3 * y1 - y1 * x2 - y2 * x3 - y3 * x1;
}

/**
 * comp_b2Vec2_in_x
 *
 * Compare 2 vertor of vertex in ascending order, according to their 
 * x-coordinate.
 */
int comp_b2Vec2_in_x(const void* a_in, const void* b_in)
{
    const b2Vec2* a = (const b2Vec2*)a_in;
    const b2Vec2* b = (const b2Vec2*)b_in;
    
    if (a->x > b->x)
    {
        return 1;
    } else if (a->x < b->x)
    {
        return -1; 
    }
    
    return 0;
}

/** 
 * arrangeClockwise
 *
 * Takes as a parameter vertices, representing the coordinates of the shape
 * and returns a new vector of vertex, with the same points arranged clockwise.
 *
 * The algorithm is simple: 
 * First, it arranges all given points in ascending order, according to their
 * x-coordinate.
 * Secondly, it takes the leftmost and rightmost points (lets call them C and 
 * D), and creates tempVec, where the points arranged in clockwise order will
 * be stored.
 * Then, it iterates over the vertices vector, and uses the det() method I 
 * talked about earlier. It starts putting the points above CD from the 
 * beginning of the vector, and the points below CD from the end of the vector.
 */
void arrangeClockwise(b2Vec2 *vec, int vecCount, b2Vec2 *m_out)
{
    qsort(vec, vecCount, sizeof(b2Vec2), comp_b2Vec2_in_x);
    
    int i1 = 1;
    int i2 = vecCount - 1;
    
    m_out[0] = vec[0];
    b2Vec2 C = vec[0];
    b2Vec2 D = vec[vecCount - 1];
    
    for (int i = 1; i < vecCount-1; i++)
    {
        int d = determinant(C.x, C.y, D.x, D.y, vec[i].x, vec[i].y);
        
        if (d < 0)
        {
            m_out[i1++] = vec[i];
        } else
        {
            m_out[i2--] = vec[i];
        }
    }
    
    m_out[i1] = vec[vecCount-1];
}

/**
 * sanityCheck
 *
 * Determine whether the given vertices represent a valid shape.
 */
int sanityCheck(b2Vec2 *vec, int vecCount)
{
    if (vecCount < 3)
    {
        return false;
    }
    
    // Calculate the area
    float32 area = 0.0;
    for (int i = 0; i < vecCount; i++)
    {
        int j = (i + 1) % vecCount;
        area += vec[j].x * vec[i].y - vec[i].x * vec[j].y;
    }
    area = area / 2;
  
    if (abs(area) < 0.00001f)
    {
        return false;
    }
    
    for (int i = 0; i < vecCount; ++i)
    {
        int i1 = i;
        int i2 = i + 1 < vecCount ? i + 1 : 0;
        b2Vec2 edge = vec[i2] - vec[i1];
        if (edge.LengthSquared() < b2_epsilon)
            return false;
    }
    
    for (int i = 0; i < vecCount; ++i)
    {
        int i1 = i;
        int i2 = i + 1 < vecCount ? i + 1 : 0;
        b2Vec2 edge = vec[i2] - vec[i1];
        
        for (int j = 0; j < vecCount; ++j)
        {
            // Don't check vertices on the current edge.
            if (j == i1 || j == i2)
            {
                continue;
            }
            
            b2Vec2 r = vec[j] - vec[i1];
            
            // Your polygon is non-convex (it has an indentation) or
            // has colinear edges.
            float s = edge.x * r.y - edge.y * r.x;
            
            if (s < 0.0f)
                return false;
        }
    }
    
    return true;
}

@interface TestSliceBody ()
@property (nonatomic, retain) CCRayCast *laser;

/** Creates and a box of the specified frame onto the world. */
- (void)addBoxWithFrame:(CGRect)frame;

/** Analyse the ray cast callback and slice the bodies if necessary. */
- (void)analyseRayCastCallback:(RayCastCallback)rayCastCallback;

/** Slice the given body at the given intersection points.  */
- (void)sliceBody:(b2Body *)sliceBody fromPoint:(b2Vec2)A toPoint:(b2Vec2)B;

@end

@implementation TestSliceBody
@synthesize laser;

- (void)dealloc
{
    [laser release], laser = nil;
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Get the screen size
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        // Defines the boxes size
        CGSize size12 = CGSizeMake(screenSize.height / 2, screenSize.height / 2);
        CGSize size16 = CGSizeMake(screenSize.height / 6, screenSize.height / 6);
        
        [self addBoxWithFrame:
         CGRectMake(ptm(screenSize.width / 2), ptm(size12.height), ptm(size12.width), ptm(size12.height))];
        [self addBoxWithFrame:
         CGRectMake(ptm(screenSize.width / 2 - size12.width / 2 + size16.width / 2), ptm(size12.height + size12.height / 2 + size16.height / 2), ptm(size16.width), ptm(size16.height))];
        [self addBoxWithFrame:
         CGRectMake(ptm(screenSize.width / 2 + size12.width / 2 - size16.width / 2), ptm(size12.height + size12.height / 2 + size16.height / 2), ptm(size16.width), ptm(size16.height))];
        
        laser = [[CCRayCast alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark TestSliceBody Public Methods

- (void)draw
{
    [super draw];
    
    // Draw the raycast
    glColor4ub(255, 0, 0, 255);
    ccDrawLine(laser.startPoint, laser.endPoint);
}

#pragma mark TestSliceBody Private Methods

- (void)addBoxWithFrame:(CGRect)frame
{
    b2BodyDef bd;    
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    
    bd.type = b2_dynamicBody;
    bd.position.Set(frame.origin.x, frame.origin.y);
    
    box.SetAsBox(frame.size.width / 2, frame.size.height / 2);
    
    fixtureDef.shape = &box;
    fixtureDef.density = 5.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.03f;
    b2Body *boxBody = world->CreateBody(&bd);
    boxBody->CreateFixture(&fixtureDef);
}

- (void)analyseRayCastCallback:(RayCastCallback)rayCastCallback
{
    // If there is at least two intersections we look for split bodies
    if (rayCastCallback.m_count >= 2)
    {
        // Retrieve the bodies to slice
        b2Body *bodyToSlice[rayCastCallback.m_count];
        int bodyToSliceNumber = rayCastCallback.bodiesCanBeSliced(bodyToSlice);

        // For each body to slice
        for (int i = 0; i < bodyToSliceNumber; i++)
        {
            // Retrieves the intersections
            b2Vec2 intersections[2];
            rayCastCallback.intersectionPoints(bodyToSlice[i], intersections);
            
            [self sliceBody:bodyToSlice[i] fromPoint:intersections[0] toPoint:intersections[1]];
        }
    }
}

- (void)sliceBody:(b2Body *)slicedBody fromPoint:(b2Vec2)A toPoint:(b2Vec2)B
{
    b2Fixture *origFixture = slicedBody->GetFixtureList();
    b2PolygonShape *shape = (b2PolygonShape *)origFixture->GetShape();
    
    // Retrieve the vertex number
    b2Vec2 *verticesVec = shape->m_vertices;
    int numVertices = shape->GetVertexCount();
    
    // Initialize the shape1 and shape2 vertices
    int shape1VertexCount = 0;
    b2Vec2 shape1Vertices[maxVerticesPerBody];
    b2Vec2 temp_shape1Vertices[maxVerticesPerBody];
    int shape2VertexCount = 0;
    b2Vec2 shape2Vertices[maxVerticesPerBody];
    b2Vec2 temp_shape2Vertices[maxVerticesPerBody];
    
    // The world.RayCast() method returns points in world coordinates
    // So use the b2Body.GetLocalPoint() to convert them to local coordinates
    A = slicedBody->GetLocalPoint(A);
    B = slicedBody->GetLocalPoint(B);
    
    // Store the vertices of the two new shapes that are about to be created. 
    // Since both point A and B are vertices of the two new shapes, add them to both vectors.
    temp_shape1Vertices[shape1VertexCount++] = A;
    temp_shape1Vertices[shape1VertexCount++] = B;
    
    temp_shape2Vertices[shape2VertexCount++] = A;
    temp_shape2Vertices[shape2VertexCount++] = B;
    
    // Iterate over all vertices of the original body. 
    // Use the derterminant function to see on which side of AB each point is standing on.
    // The parameters it needs are the coordinates of 3 points:
    // - if the value > 0, then the three points are in clockwise order (the point is under AB)
    // - if the value = 0, then the three points lie on the same line (the point is on AB)
    // - if the value < 0, then the three points are in counter-clockwise order (the point is above AB). 
    for (int i = 0; i < numVertices; i++)
    {
        float d = determinant(A.x, A.y, B.x, B.y, verticesVec[i].x, verticesVec[i].y);
        if (d > 0)
        {
            temp_shape1Vertices[shape1VertexCount++] = verticesVec[i];
        } else
        {
            temp_shape2Vertices[shape2VertexCount++] = verticesVec[i];
        }
    }
    
    // In order to be able to create the two new shapes, the vertices have to be arranged in clockwise order
    arrangeClockwise(temp_shape1Vertices, shape1VertexCount, shape1Vertices);
    arrangeClockwise(temp_shape2Vertices, shape2VertexCount, shape2Vertices);

    // Setting the properties of the two newly created shapes
    b2BodyDef bodyDef;    
    b2PolygonShape polyShape;
    b2FixtureDef fixtureDef;
    
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(slicedBody->GetPosition().x, slicedBody->GetPosition().y);
    
    fixtureDef.density = origFixture->GetDensity();
    fixtureDef.friction = origFixture->GetFriction();
    fixtureDef.restitution = origFixture->GetRestitution();
    
    // If the shape1 is valid
    if (sanityCheck(shape1Vertices, shape1VertexCount))
    {
        // Creating the first shape
        polyShape.Set(shape1Vertices, shape1VertexCount);
        fixtureDef.shape = &polyShape;
        
        b2Body *body = world->CreateBody(&bodyDef);
        body->SetTransform(slicedBody->GetPosition(), slicedBody->GetAngle());
        body->CreateFixture(&fixtureDef);
        body->SetLinearVelocity(slicedBody->GetLinearVelocity());
        body->SetAngularVelocity(slicedBody->GetAngularVelocity());
        body->SetBullet(true);
    }
    
    // If the shape2 is valid
    if (sanityCheck(shape2Vertices, shape2VertexCount))
    {
        // Creating the second shape
        polyShape.Set(shape2Vertices, shape2VertexCount);
        fixtureDef.shape = &polyShape;
        
        b2Body *body = world->CreateBody(&bodyDef);
        body->SetTransform(slicedBody->GetPosition(), slicedBody->GetAngle());
        body->CreateFixture(&fixtureDef);
        body->SetLinearVelocity(slicedBody->GetLinearVelocity());
        body->SetAngularVelocity(slicedBody->GetAngularVelocity());
        body->SetBullet(true);
    }    
    
    // To finish, destroy the original body
    world->DestroyBody(slicedBody);
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
	for(UITouch *touch in allTouches)
    {
		CGPoint location = [touch locationInView:touch.view];
        
		location = [[CCDirector sharedDirector] convertToGL:location];
        
        laser.startPoint = location;
        laser.endPoint = location;
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
	for(UITouch *touch in allTouches)
    {
		CGPoint location = [touch locationInView:touch.view];
        
		location = [[CCDirector sharedDirector] convertToGL:location];

        laser.endPoint = location;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
	for(UITouch *touch in allTouches)
    {
		CGPoint location = [touch locationInView:touch.view];
        
		location = [[CCDirector sharedDirector] convertToGL:location];
        
        laser.endPoint = location;
    }
    
    CGPoint startPoint = laser.startPoint;
    CGPoint endPoint = laser.endPoint;
    
    if (!CGPointEqualToPoint(startPoint, endPoint))
    {
        RayCastCallback laserCallback;
        world->RayCast(&laserCallback, b2Vec2(ptm(startPoint.x), ptm(startPoint.y)), b2Vec2(ptm(endPoint.x), ptm(endPoint.y)));
        world->RayCast(&laserCallback, b2Vec2(ptm(endPoint.x), ptm(endPoint.y)), b2Vec2(ptm(startPoint.x), ptm(startPoint.y)));
        
        [self analyseRayCastCallback:laserCallback];
    }
    
    // Remove the laser on the screen
    laser.startPoint = CGPointZero;
    laser.endPoint = CGPointZero;
}

@end
