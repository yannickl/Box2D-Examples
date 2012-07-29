//
//  RaycastCallback.h
//  Box2DCocos2DExamples
//
//  Created by Yannick Loriot on 08/01/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import "Box2D.h"

class RayCastCallback : public b2RayCastCallback
{
private:
    enum
	{
		e_maxCount = 20
	};
    
    /** Returns the number of distinct bodies available in the m_bodies. */
    int distinctBodies (b2Body* t[])
    {
        int distinctBodyCount = 0;
        
        for (int i = 0; i < m_count; i++)
        {
            b2Body* currentBody = m_bodies[i];
            boolean_t bodyAlreadyAdded = NO;
            
            for (int j = 0; j < distinctBodyCount; j++)
            {
                if (t[j] ==  currentBody)
                {
                    bodyAlreadyAdded = YES;
                    break;
                }
            }
            
            if (!bodyAlreadyAdded)
            {
                // Add it to the list
                t[distinctBodyCount++] = currentBody;
            }
        }
        
        return distinctBodyCount;
    }
    
public:
    RayCastCallback()
	{
		m_count = 0;
	}
    
	float32 ReportFixture(b2Fixture* fixture, const b2Vec2& point,
                          const b2Vec2& normal, float32 fraction)
	{
		b2Body* body = fixture->GetBody();
        
		void* userData = body->GetUserData();
		if (userData)
		{
			int32 index = *(int32*)userData;
			if (index == 0)
			{
				// filter
				return -1.0f;
			}
		}
        
		b2Assert(m_count < e_maxCount);
        
        m_bodies[m_count] = body;
		m_points[m_count] = point;
		++m_count;
        
		if (m_count == e_maxCount)
		{
			return 0.0f;
		}
        
		return 1.0f;
	}
    
    /** Returns the number of bodies can be sliced. */
    int bodiesCanBeSliced (b2Body* t[])
    {
        b2Body *bodies[m_count];
        int bodyNumber = this->distinctBodies(bodies);
        int sliceBodyCount = 0;
        
        for (int i = 0; i < bodyNumber; i++)
        {
            // For each body in the list
            b2Body *body = bodies[i];
            int bodyOccurrenceCount = 0;
            
            // Check if the body has 2 cut points
            for (int j = 0; j < m_count; j++)
            {
                if (m_bodies[j] == body)
                {
                    if (++bodyOccurrenceCount >= 2)
                    {
                        break;
                    }
                }
            }
            
            // If yes, add it to the list
            if (bodyOccurrenceCount == 2)
            {
                t[sliceBodyCount++] = body;
            }
        }
        
        return sliceBodyCount;
    }
    
    void intersectionPoints (b2Body* body, b2Vec2 *intersections)
    {
        int intersectionCount = 0;
        for (int j = 0; j < m_count; j++)
        {
            if (m_bodies[j] == body)
            {
                intersections[intersectionCount++] = m_points[j];
                if (intersectionCount >= 2)
                {
                    break;
                }
            }
        }
    }
    
    b2Body* m_bodies[e_maxCount];   // Ref to the bodies
	b2Vec2 m_points[e_maxCount];    // Ref to the points
	int32 m_count;
};