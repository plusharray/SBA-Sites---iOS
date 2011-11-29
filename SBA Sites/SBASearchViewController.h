//
//  SBASearchViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface SBASearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, AGSLocatorDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AGSSpatialReference *spatialReference;
@property (nonatomic) BOOL addressBookSearch;
@property (nonatomic) BOOL searchActiveDB;
@property (nonatomic) BOOL searchActiveForwardGeocode;
@property (nonatomic) BOOL searchActiveReverseGeocode;
@property (nonatomic) BOOL searchPerformed;
@property (nonatomic, retain) NSMutableArray *addressResults;
@property (nonatomic, retain) NSMutableArray *siteResults;
@property (nonatomic, retain) NSString *savedSearchTerm;

@end
