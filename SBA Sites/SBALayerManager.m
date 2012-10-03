//
//  SBALayerManager.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/1/12.
//
//

#import "SBALayerManager.h"
#import "SBALayer.h"

@implementation SBALayerManager

@synthesize allLayers = _allLayers;
@synthesize visibleLayers = _visibleLayers;

+ (id)sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        
		// Set up the layers
		NSMutableArray *allLayers = [[NSMutableArray alloc] initWithCapacity:5];
		for (int i = 0; i < 5; i++) {
			[allLayers addObject:[SBALayer layerForID:i]];
		}
		_allLayers = allLayers;
		_visibleLayers = allLayers;
		
    }
    return self;
}

@end
