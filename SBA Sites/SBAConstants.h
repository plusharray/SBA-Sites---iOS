//
//  SBAConstants.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TiledMapServiceURL;
extern NSString * const DynamicMapServiceURL;
// Notifications
extern NSString * const SBASiteSelected;
extern NSString * const SBALayerSelected;
// Layers
extern NSString * const SBALayerNewConstruction;
extern NSString * const SBALayerOwned;
extern NSString * const SBALayerManaged;
extern NSString * const SBALayerCanada;
extern NSString * const SBALayerCentralAmerica;

typedef enum {
	kNewConstruction = 0,
	kOwned,
	kManaged,
    kCanada,
    kCentralAmerica
} SBALayerID;
