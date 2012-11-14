//
//  SBARootViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "SBASiteDetailViewController.h"

@class PALocationController;
@class SketchToolbar;

@interface SBARootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate, UISearchDisplayDelegate, UISearchBarDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, BSForwardGeocoderDelegate, AGSFindTaskDelegate, UIPopoverControllerDelegate, AGSRouteTaskDelegate, SBARouteRequestDelegate>

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) PALocationController *locationController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showLayerListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSearchBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSiteListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showInfoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIToolbar *routeToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftArrowButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightArrowButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *measureButton;
@property (strong, nonatomic) IBOutlet UIToolbar *measureToolbar;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) AGSTiledMapServiceLayer *tiledLayer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicLayer;
@property (nonatomic, strong) UIView *dynamicLayerView;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) AGSPoint* mappoint;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) NSArray *visibleLayers;
@property (nonatomic) BOOL addressBookSearch;
@property (nonatomic) BOOL searchActiveDB;
@property (nonatomic) BOOL searchActiveForwardGeocode;
@property (nonatomic) BOOL searchActiveReverseGeocode;
@property (nonatomic) BOOL searchPerformed;
@property (nonatomic, strong) NSMutableArray *addressResults;
@property (nonatomic, strong) NSMutableArray *siteResults;
@property (nonatomic, strong) NSString *savedSearchTerm;
@property (nonatomic, strong) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic, strong) AGSFindTask *findTask;
@property (nonatomic, strong) AGSCalloutTemplate *calloutTemplate;
@property (nonatomic) NSInteger selectedMapType;
@property (nonatomic, strong) NSURL *dynamicServiceURL;

@property (nonatomic, strong) AGSRouteTask *routeTask;
@property (nonatomic, strong) AGSRouteTaskParameters *routeTaskParams;
@property (nonatomic, strong) AGSRouteResult *routeResult;
@property (nonatomic, strong) NSArray *routeStops;
@property (nonatomic, strong) AGSStopGraphic *startingGraphic;
@property (nonatomic, strong) AGSStopGraphic *destinationGraphic;
@property (nonatomic, strong) AGSDirectionGraphic *currentDirectionGraphic;
@property (nonatomic, strong) IBOutlet UIView *directionsBannerView;
@property (nonatomic, strong) IBOutlet UILabel *directionsLabel;

@property (nonatomic, strong) SketchToolbar *sketchToolbar;

- (IBAction)mapType:(UISegmentedControl *)segmentPick;
- (IBAction)toggleLayer:(id)sender;
- (IBAction)userLocationButtonTapped:(id)sender;
- (IBAction)showSiteList:(id)sender;
- (IBAction)showLayerList:(id)sender;
- (IBAction)showSearch:(id)sender;
- (IBAction)showInfo:(id)sender;
- (void)siteSelected:(NSNotification *)notification;
- (IBAction)resetRoute:(id)sender;
- (IBAction)previousTurn:(id)sender;
- (IBAction)nextTurn:(id)sender;
- (IBAction)showMeasuringTools:(id)sender;

- (AGSCompositeSymbol*)stopSymbolWithNumber:(NSInteger)stopNumber;
- (AGSCompositeSymbol*)routeSymbol;
- (AGSCompositeSymbol*)currentDirectionSymbol;
- (void)updateDirectionsLabel:(NSString*)newLabel;

@end
