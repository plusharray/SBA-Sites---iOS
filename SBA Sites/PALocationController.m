//
//  PALocationController.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/12.
//
//

#import "PALocationController.h"

@implementation PALocationController

@synthesize location = _location;
@synthesize locationManager = _locationManager;

+ (id)sharedController
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
        _locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
		_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
		[_locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	self.location = [locations lastObject];
	[self.locationManager stopUpdatingLocation];
}

@end
