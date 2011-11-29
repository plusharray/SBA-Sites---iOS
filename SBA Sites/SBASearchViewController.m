//
//  SBASearchViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBASearchViewController.h"
#import <AddressBook/AddressBook.h>

@interface SBASearchViewController (Private)
- (void)searchForString:(NSString *)searchString;
- (void)showPeoplePickerController;
@end

@implementation SBASearchViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize spatialReference = _spatialReference;
@synthesize addressBookSearch = _addressBookSearch;
@synthesize searchActiveDB = _searchActiveDB;
@synthesize searchActiveForwardGeocode = _searchActiveForwardGeocode;
@synthesize searchActiveReverseGeocode = _searchActiveReverseGeocode;
@synthesize searchPerformed = _searchPerformed;
@synthesize addressResults = _addressResults;
@synthesize siteResults = _siteResults;
@synthesize savedSearchTerm = _savedSearchTerm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self searchDisplayController] setActive:YES animated:YES];
    [[self searchBar] becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SBASearchTableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Search Related

- (void)searchForString:(NSString *)searchString
{
    // Address Search
    
    NSArray *addressArray = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
	if ([addressArray count] > 1) {
		NSString *addressString = [NSString stringWithFormat:@"%@", [addressArray objectAtIndex:0]];
        NSString *address2String = [searchString stringByReplacingOccurrencesOfString:addressString withString:@""];
    }
    
    // Coordinates - Decimal
	NSArray *coordArray = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
	if ([coordArray count] == 2) {
		NSString *latString = [NSString stringWithFormat:@"%@", [coordArray objectAtIndex:0]];
		NSString *lonString = [NSString stringWithFormat:@"%@", [coordArray objectAtIndex:1]];
		double lat = [latString doubleValue];
		double lon = [lonString doubleValue];
		if ((lat != 0) && (lon != 0)) {
			CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
			if (coord.longitude > 0.0f) {
				coord.longitude *= -1.0f;
			}
			if ((coord.latitude != 0) && (coord.longitude != 0)) {
                NSURL *locatorURL = [NSURL URLWithString:@"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Geocode_USA/GeocodeServer"];
                AGSLocator* locator = [[AGSLocator alloc] initWithURL:locatorURL];
                [locator setDelegate:self];
				AGSPoint* point = [AGSPoint pointWithX:coord.latitude y:coord.longitude spatialReference:self.spatialReference];
                [locator addressForLocation:point maxSearchDistance:100];
				self.searchActiveReverseGeocode = YES;
			} else {
				self.searchActiveReverseGeocode = NO;
			}
		}
		
	} else {
		self.searchActiveReverseGeocode = NO;
	}
}

- (void)showPeoplePickerController
{
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	self.searchPerformed = YES;
	[self searchForString:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.siteResults removeAllObjects];
	[self.addressResults removeAllObjects];
	self.searchActiveDB = NO;
	self.searchActiveReverseGeocode = NO;
	self.searchActiveForwardGeocode = NO;
	[searchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
	self.addressBookSearch = YES;
	[self showPeoplePickerController];
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// Only inspect the value if it's an address.
    if (property == kABPersonAddressProperty) {
        /*
         * Set up an ABMultiValue to hold the address values; copy from address
         * book record.
         */
        ABMultiValueRef multi = ABRecordCopyValue(person, property);
		
        // Set up an NSArray and copy the values in.
        NSArray *theArray = (__bridge_transfer id)ABMultiValueCopyArrayOfAllValues(multi);
		
        // Figure out which values we want and store the index.
        const NSUInteger theIndex = ABMultiValueGetIndexForIdentifier(multi, identifier);
		CFRelease(multi);
		
        // Set up an NSDictionary to hold the contents of the array.
        NSDictionary *theDict = [theArray objectAtIndex:theIndex];
		
        // Set up NSStrings to hold keys and values.  First, how many are there?
        const NSUInteger theCount = [theDict count];
        __unsafe_unretained NSString *keys[theCount];
        __unsafe_unretained NSString *values[theCount];
		
        // Get the keys and values from the CFDictionary.  Note that because
        // we're using the "GetKeysAndValues" function, you don't need to
        // release keys or values.  It's the "Get Rule" and only applies to
        // CoreFoundation objects.
        [theDict getObjects:values andKeys:keys];
		
        // Set the address label's text.
        NSString *address;
        address = [NSString stringWithFormat:@"%@, %@, %@, %@ %@",
                   [theDict objectForKey:(NSString *)kABPersonAddressStreetKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressCityKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressStateKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressZIPKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressCountryKey]];
		
        // Return to the main view controller.
#warning Uncompleted method
		
	}
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	self.addressBookSearch = NO;
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	self.addressBookSearch = YES;
	return NO;
}

#pragma mark - AGSLocatorDelegate

- (void)locator:(AGSLocator*)locator operation:(NSOperation*)op didFindLocationsForAddress:(NSArray*)candidates
{
    
}

- (void)locator:(AGSLocator*)locator operation:(NSOperation*)op didFailLocationsForAddress:(NSError*)error
{
    
}

@end
