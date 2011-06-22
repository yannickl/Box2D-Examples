//
//  Box2DExamples.h
//  Box2DCocos2DExamples
//
//  Created by Yannick LORIOT on 21/06/11.
//  Copyright 2011 Yannick Loriot. All rights reserved.
//

#ifndef __H_BOX2D_EXAMPLES__
#define __H_BOX2D_EXAMPLES__

// Pixel to metres ratio. Box2D uses metres as the unit for measurement.
// This ratio defines how many pixels correspond to 1 Box2D "metre"
// Box2D is optimized for objects of 1x1 metre therefore it makes sense
// to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// World gravity.
#define WORLDGRAVITY 20.0f

static inline float ptm(float d)
{
    return d / PTM_RATIO;
}

#endif /** !__H_BOX2D_EXAMPLES__ guard */