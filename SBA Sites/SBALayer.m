//
//  SBALayer.m
//  SBA Sites
//
//  Created by Ross Chapman on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBALayer.h"

@implementation SBALayer

@synthesize layerID = _layerID;
@synthesize name = _name;
@synthesize image = _image;
@synthesize visible = _visible;

+ (NSString *)layerNameForID:(NSInteger)layerID
{
    NSString *name;
    switch (layerID) {
        case NewConstruction:
            name = SBALayerNewConstruction;
            break;
        case Owned:
            name = SBALayerOwned;
            break;
        case Managed:
            name = SBALayerManaged;
            break;
        case Canada:
            name = SBALayerCanada;
            break;
        case CentralAmerica:
            name = SBALayerCentralAmerica;
            break;
		case Competitors:
            name = SBALayerCompetitors;
            break;
        default:
            name = SBALayerOwned;
            break;
    }
    return name;
}

#pragma mark - Init

+ (id)layerForID:(NSInteger)layerID
{
    return [[self alloc] initWithID:layerID];
}

- (id)initWithID:(NSInteger)layerID
{
    self = [super init];
    if (self) {
        self.layerID = @(layerID);
        self.visible = YES;
        self.name = [SBALayer layerNameForID:self.layerID.integerValue];
    }
    return self;
}

#pragma mark - Accessors

- (UIImage *)image
{
    if (!_image) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png", self.name];
        _image = [UIImage imageNamed:imageName];
    }
    return _image;
}

@end
