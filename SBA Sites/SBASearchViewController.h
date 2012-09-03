//
//  SBASearchViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"

@interface SBASearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, AGSLocatorDelegate, BSForwardGeocoderDelegate, AGSFindTaskDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AGSMapView *mapView;
@property (strong, nonatomic) NSArray *visibleLayers;
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

@end
