//
//  SBALayer.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBALayer : NSObject

@property (nonatomic, strong) NSNumber *layerID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, getter = isVisible) BOOL visible;

+ (NSString *)layerNameForID:(NSInteger)layerID;
+ (id)layerForID:(NSInteger)layerID;
- (id)initWithID:(NSInteger)layerID;

@end
