//
//  SBAConstants.m
//  SBA Sites
//
//  Created by Ross Chapman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBAConstants.h"

NSString * const TiledMapServiceURL = @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer";
NSString * const AerialMapServiceURL = @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_Imagery_World_2D/MapServer";
NSString * const DynamicMapServiceURL = @"http://mapservices.sbasite.com/ArcGIS/rest/services/Google/MobileiOS/MapServer";

NSString * const DynamicMapServiceURLAuthenticated = @"http://mapservices.sbasite.com/ArcGIS/rest/services/Google/MobileiOS2/MapServer";

// Notifications
NSString * const SBASiteSelected = @"SBASiteSelected";
NSString * const SBALayerSelected = @"SBALayerSelected";
NSString * const SBAMapTypeChanged = @"SBAMapTypeChanged";
// Layers
NSString * const SBALayerNewConstruction = @"New Construction";
NSString * const SBALayerOwned = @"SBA Owned";
NSString * const SBALayerManaged = @"SBA Managed";
NSString * const SBALayerCanada = @"Canada";
NSString * const SBALayerCentralAmerica = @"Central America";