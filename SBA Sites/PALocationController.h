//
//  PALocationController.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/12.
//
//

#import <Foundation/Foundation.h>

@interface PALocationController : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;

+ (id)sharedController;

@end
