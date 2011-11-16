//
//  SBARootViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBARootViewController : UIViewController <AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate>

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showLayerListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSearchBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSiteListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showInfoButton;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicLayer;
@property (nonatomic, strong) UIView *dynamicLayerView;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) AGSPoint* mappoint;
@property (nonatomic, strong) NSMutableArray *layers;

- (IBAction)mapType:(UISegmentedControl *)segmentPick;
- (IBAction)toggleLayer:(id)sender;
- (IBAction)userLocationButtonTapped:(id)sender;
- (IBAction)showSiteList:(id)sender;
- (IBAction)showLayerList:(id)sender;
- (IBAction)showSearch:(id)sender;
- (IBAction)showInfo:(id)sender;

@end