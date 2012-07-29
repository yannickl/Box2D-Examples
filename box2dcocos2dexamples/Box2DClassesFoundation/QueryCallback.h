//
//  QueryCallback.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 21/05/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#import "Box2D.h"

class QueryCallback : public b2QueryCallback
{
public:
	QueryCallback (const b2Vec2& point)
	{
		m_point = point;
		m_fixture = NULL;
	}
    
	bool ReportFixture (b2Fixture* fixture)
	{
		b2Body *body = fixture->GetBody();
		if (body->GetType() != b2_staticBody)
		{
			bool inside = fixture->TestPoint(m_point);
			if (inside)
			{
				m_fixture = fixture;
                
				// We are done, terminate the query.
				return false;
			}
		}
        
		// Continue the query.
		return true;
	}
    
	b2Vec2 m_point;
	b2Fixture* m_fixture;
};