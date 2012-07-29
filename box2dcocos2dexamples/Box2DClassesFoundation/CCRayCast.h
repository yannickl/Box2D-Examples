//
//  CCRayCast.h
//  Box2DCocos2DExamples
//
//  Created by Yannick Loriot on 08/01/12.
//  Copyright (c) 2012 Yannick Loriot. All rights reserved.
//  http://yannickloriot.com
//

#import <Foundation/Foundation.h>

@interface CCRayCast : NSObject
{
@public
    CGPoint startPoint;
    CGPoint endPoint;
}
@property CGPoint startPoint;
@property CGPoint endPoint;

#pragma mark Constructors - Initializers

#pragma mark Public Methods

@end
