//
//  SBAAppDelegate.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"

@interface SBAAppDelegate : UIResponder <UIApplicationDelegate, MHTabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MHTabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
