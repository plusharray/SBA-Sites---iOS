//
//  SBALayerManager.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/1/12.
//
//

#import <Foundation/Foundation.h>

@interface SBALayerManager : NSObject

@property (strong, nonatomic) NSArray *allLayers;
@property (strong, nonatomic) NSArray *visibleLayers;

+ (id)sharedManager;

@end
