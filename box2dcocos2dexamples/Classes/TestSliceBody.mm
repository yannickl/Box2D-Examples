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
    maxVerticesPerBody = 24     // Defines the max number of vertex per body
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
inline float determinant(float x1, float y1, float x2, float y2, float x3, float y3)
{
    return x1 * y2 + x2 * y3 + x3 * y1 - y1 * x2 - y2 * x3 - y3 * x1;
}

/**
 * comp_b2Vec2_in_x
 *
 * Compare 2 vertor of vertex in ascending order, according to their 
 * x-coordinate.
 */
inline int comp_b2Vec2_in_x(const void* a_in, const void* b_in)
{
    const b2Vec2 *a = (const b2Vec2 *)a_in;
    const b2Vec2 *b = (const b2Vec2 *)b_in;
    
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
inline void arrangeClockwise(b2Vec2 *vec, int vecCount, b2Vec2 *m_out)
{
    qsort(vec, vecCount, sizeof(b2Vec2), comp_b2Vec2_in_x);

    int iCounterClockWise = 1;
    int iClockWise = vecCount - 1;

    m_out[0] = vec[0];
    b2Vec2 C = vec[0];              // leftmost point
    b2Vec2 D = vec[vecCount - 1];   // rightmost point
 
    for (int i = 1; i < vecCount - 1; i++)
    {
        int d = determinant(C.x, C.y, D.x, D.y, vec[i].x, vec[i].y);
        
        if (d < 0.0f)
        {
            m_out[iCounterClockWise++] = vec[i];
        } else
        {
            m_out[iClockWise--] = vec[i];
        }
    }
    m_out[iCounterClockWise] = vec[vecCount - 1];
}

/**
 * sanityCheck
 *
 * Determine whether the given vertices represent a valid shape.
 */
inline int sanityCheck(b2Vec2 *vec, int vecCount)
{
    // Polygons need to at least have 3 vertices
    if (vecCount < 3)
    {
        return false;
    }
    
    // The number of vertices cannot exceed b2_maxPolygonVertices
    if (vecCount > b2_maxPolygonVertices)
    {
        return false;
    }
    
    // Box2D needs the distance from each vertex to be greater than b2_epsilon
    for (int i = 0; i < vecCount; ++i)
    {
        int i1 = i;
        int i2 = i + 1 < vecCount ? i + 1 : 0;
        b2Vec2 edge = vec[i2] - vec[i1];
        
        if (edge.LengthSquared() < b2_epsilon * b2_epsilon)
        {
            return false;
        }
    }
    
    // Box2D needs the area of a polygon to be greater than b2_epsilon
    float32 area = 0.0f;
    b2Vec2 pRef(0.0f,0.0f);
    for (int i = 0; i < vecCount; ++i)
    {
        b2Vec2 p1 = pRef;
        b2Vec2 p2 = vec[i];
        b2Vec2 p3 = i + 1 < vecCount ? vec[i+1] : vec[0];
        
        b2Vec2 e1 = p2 - p1;
        b2Vec2 e2 = p3 - p1;
        
        float32 D = b2Cross(e1, e2);
        
        float32 triangleArea = 0.5f * D;
        area += triangleArea;
    }
    
    if (area <= 0.0001f)
    {
        NSLog(@"Area too small: %f", area);
        return false;
    }
    
    // Box2D requires that the shape be Convex.
    b2Vec2 v1 = vec[0] - vec[vecCount-1];
    b2Vec2 v2 = vec[1] - vec[0];
    float referenceDeterminant = v1.x * v2.y - v1.y * v2.x;
    
    for (int i = 1; i < vecCount - 1; i++)
    {
        v1 = v2;
        v2 = vec[i+1] - vec[i];
        
        float determinant = v1.x * v2.y - v1.y * v2.x;
        
        // Use the determinant to check direction from one point to another.
        // A convex shape's points should only go around in one direction.
        // The sign of the determinant determines that direction.
        // If the sign of the determinant changes mid-way, then you have a concave shape.
        if (referenceDeterminant * determinant < 0.0f)
        {
            // If multiplying two determinants result to a negative value, 
            // you know that the sign of both numbers differ, hence it is concave
            return false;
        }
    }
    
    v1 = v2;
    v2 = vec[0] - vec[vecCount-1];
    float determinant = v1.x * v2.y - v1.y * v2.x;
    if (referenceDeterminant * determinant < 0.0f)
    {
        return false;
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
    b2Fixture *originalFixture = slicedBody->GetFixtureList();
    b2PolygonShape *originalPolygon = (b2PolygonShape *)originalFixture->GetShape();
    
    // Retrieve the vertex number
    b2Vec2 *verticesVec = originalPolygon->m_vertices;
    int vertexCount = originalPolygon->GetVertexCount();
    
    // Initialize the shape1 and shape2 vertices
    int shape1VertexCount = 0;
    b2Vec2 shape1VerticesSorted[maxVerticesPerBody];
    b2Vec2 temp_shape1Vertices[maxVerticesPerBody];
    int shape2VertexCount = 0;
    b2Vec2 shape2VerticesSorted[maxVerticesPerBody];
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
    for (int i = 0; i < vertexCount; i++)
    {
        // Get our vertex from the polygon
        b2Vec2 currentPoint = verticesVec[i];
        
        //you check if our point is not the same as our entry or exit point first
        b2Vec2 diffFromEntryPoint = currentPoint - b2Vec2(A.x, A.y);
        b2Vec2 diffFromExitPoint = currentPoint - b2Vec2(B.x, B.y);
        
        if ((diffFromEntryPoint.x == 0 && diffFromEntryPoint.y == 0) 
            || (diffFromExitPoint.x == 0 && diffFromExitPoint.y == 0))
            continue;
        
        float d = determinant(A.x, A.y, B.x, B.y, currentPoint.x, currentPoint.y);
        if (d > 0)
        {
            temp_shape1Vertices[shape1VertexCount++] = currentPoint;
        } else
        {
            temp_shape2Vertices[shape2VertexCount++] = currentPoint;
        }
    }
    
    // In order to be able to create the two new shapes, the vertices have to be arranged in clockwise order
    arrangeClockwise(temp_shape1Vertices, shape1VertexCount, shape1VerticesSorted);
    arrangeClockwise(temp_shape2Vertices, shape2VertexCount, shape2VerticesSorted);

    // Setting the properties of the two newly created shapes
    b2BodyDef bodyDef;    
    b2PolygonShape polyShape;
    b2FixtureDef fixtureDef;
    
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(slicedBody->GetPosition().x, slicedBody->GetPosition().y);
    
    fixtureDef.density = originalFixture->GetDensity();
    fixtureDef.friction = originalFixture->GetFriction();
    fixtureDef.restitution = originalFixture->GetRestitution();
    
    // If the shape1 and the shape2 are valid
    if (sanityCheck(shape1VerticesSorted, shape1VertexCount)
        && sanityCheck(shape2VerticesSorted, shape2VertexCount))
    {
        // Creating the first shape
        polyShape.Set(shape1VerticesSorted, shape1VertexCount);
        fixtureDef.shape = &polyShape;
        
        b2Body *body = world->CreateBody(&bodyDef);
        body->SetTransform(slicedBody->GetPosition(), slicedBody->GetAngle());
        body->CreateFixture(&fixtureDef);
        body->SetLinearVelocity(slicedBody->GetLinearVelocity());
        body->SetAngularVelocity(slicedBody->GetAngularVelocity());
        body->SetBullet(true);
        
        // Creating the second shape
        polyShape.Set(shape2VerticesSorted, shape2VertexCount);
        fixtureDef.shape = &polyShape;
        
        body = world->CreateBody(&bodyDef);
        body->SetTransform(slicedBody->GetPosition(), slicedBody->GetAngle());
        body->CreateFixture(&fixtureDef);
        body->SetLinearVelocity(slicedBody->GetLinearVelocity());
        body->SetAngularVelocity(slicedBody->GetAngularVelocity());
        body->SetBullet(true);
        
        // Destroy the original body
        world->DestroyBody(slicedBody);
    }
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
    NSSet *allTouches   = [event allTouches];
    
	for(UITouch *touch in allTouches)
    {
		CGPoint location    = [touch locationInView:touch.view];
		location            = [[CCDirector sharedDirector] convertToGL:location];
        
        laser.endPoint      = location;
    }
    
    CGPoint startPoint  = laser.startPoint;
    CGPoint endPoint    = laser.endPoint;
    
    if (!CGPointEqualToPoint(startPoint, endPoint))
    {
        RayCastCallback laserCallback;
        world->RayCast(&laserCallback, b2Vec2(ptm(startPoint.x), ptm(startPoint.y)), b2Vec2(ptm(endPoint.x), ptm(endPoint.y)));
        world->RayCast(&laserCallback, b2Vec2(ptm(endPoint.x), ptm(endPoint.y)), b2Vec2(ptm(startPoint.x), ptm(startPoint.y)));
        
        [self analyseRayCastCallback:laserCallback];
    }
    
    // Remove the laser on the screen
    laser.startPoint    = CGPointZero;
    laser.endPoint      = CGPointZero;
}

@end
