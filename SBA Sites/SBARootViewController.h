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

@interface SBARootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate, UISearchDisplayDelegate, UISearchBarDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, MKReverseGeocoderDelegate, BSForwardGeocoderDelegate, AGSFindTaskDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showLayerListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSearchBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showSiteListPopoverButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *userLocationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showInfoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) AGSTiledMapServiceLayer *tiledLayer;
@property (nonatomic, strong) AGSDynamicMapServiceLayer *dynamicLayer;
@property (nonatomic, strong) UIView *dynamicLayerView;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) AGSPoint* mappoint;
@property (nonatomic, strong) NSArray *layers;
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

- (IBAction)mapType:(UISegmentedControl *)segmentPick;
- (IBAction)toggleLayer:(id)sender;
- (IBAction)userLocationButtonTapped:(id)sender;
- (IBAction)showSiteList:(id)sender;
- (IBAction)showLayerList:(id)sender;
- (IBAction)showSearch:(id)sender;
- (IBAction)showInfo:(id)sender;
- (void)siteSelected:(NSNotification *)notification;

@end
