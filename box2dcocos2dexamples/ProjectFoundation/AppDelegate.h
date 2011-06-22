//
//  AppDelegate.h
//  box2dcocos2dexamples
//
//  Created by Yannick LORIOT on 20/05/11.
//  Copyright Yannick Loriot 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
