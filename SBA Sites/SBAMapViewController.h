//
//  MapViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 9/24/12.
//
//

#import <UIKit/UIKit.h>

@interface SBAMapViewController : NSObject <AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) AGSMapView *mapView;
@property (nonatomic, strong) AGSTiledMapServiceLayer *tiledLayer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicLayer;
@property (nonatomic, strong) UIView *dynamicLayerView;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) AGSPoint* mappoint;
@property (nonatomic, strong) NSArray *layers;
@property (nonatomic, strong, readonly) NSArray *visibleLayers;
@property (nonatomic, strong) AGSCalloutTemplate *calloutTemplate;
@property (nonatomic) NSInteger selectedMapType;
@property (nonatomic, strong) UIPopoverController *popoverController;

- (void)setupMapView:(BOOL)userAuthenticated;

- (IBAction)mapType:(UISegmentedControl *)segmentPick;
- (IBAction)toggleLayer:(id)sender;
- (IBAction)userLocationButtonTapped:(id)sender;

@end
