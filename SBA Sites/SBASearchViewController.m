//
//  SBASearchViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBASearchViewController.h"
#import <AddressBook/AddressBook.h>
#import "SBAMapViewController.h"

@interface SBASearchViewController (Private)
- (void)searchForString:(NSString *)searchString;
- (void)showPeoplePickerController;
@end

@implementation SBASearchViewController

@synthesize mapViewController = _mapViewController;
@synthesize searchBar = _searchBar;
@synthesize addressBookSearch = _addressBookSearch;
@synthesize searchActiveDB = _searchActiveDB;
@synthesize searchActiveForwardGeocode = _searchActiveForwardGeocode;
@synthesize searchActiveReverseGeocode = _searchActiveReverseGeocode;
@synthesize searchPerformed = _searchPerformed;
@synthesize addressResults = _addressResults;
@synthesize siteResults = _siteResults;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize forwardGeocoder = _forwardGeocoder;
@synthesize findTask = _findTask;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[self.navigationController setToolbarHidden:YES animated:NO];
	
	self.mapViewController = [[SBAMapViewController alloc] init];
	
	self.mapViewController.mapView = self.mapView;
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
	if (section == 0) {
		return @"Site Results";
	}
	else if (section == 1) {
		return @"Address Results";
	} else {
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	int rows = 0;
	if (section == 0) {
		if (self.siteResults.count < 1) {
			if (self.searchActiveDB == YES) {
				rows = 1;
			} else {
				if (self.searchPerformed == YES) {
					rows = 1;
				} else {
					rows = 0;
				}
			}
		} else {
			rows = self.siteResults.count;
		}
	}
	else if (section == 1) {
		if (self.addressResults.count < 1) {
			if ((self.searchActiveReverseGeocode == YES) && (self.searchActiveForwardGeocode == YES)) {
				rows = 1;
			} else {
				if (self.searchPerformed == YES) {
					rows = 1;
				} else {
					rows = 0;
				}
			}
			
		} else {
			rows = self.addressResults.count;
		}
	}
	return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
    int section = indexPath.section;
	int row = indexPath.row;
	
	if (cell.accessoryView == nil) {
		UIActivityIndicatorView *searchActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		searchActivityIndicator.hidesWhenStopped = YES;
		cell.accessoryView = searchActivityIndicator;
	}
	
	if (section == 0) {
		if (self.siteResults.count < 1) {
			if (self.searchActiveDB == YES) {
				cell.textLabel.text = @"Searching....";
				[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
			} else {
				cell.textLabel.text = @"No Results Found";
				[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
			}
			cell.detailTextLabel.text = @"";
		} else {
			if (self.searchActiveDB == YES) {
				[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
			} else {
				[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
			}
			AGSFindResult *result = [self.siteResults objectAtIndex:row];
			cell.textLabel.text = [result.feature.attributes valueForKey:@"SiteName"];
            cell.detailTextLabel.text = [result.feature.attributes valueForKey:@"SiteCode"];
            cell.imageView.image = [UIImage imageNamed:[result layerName]];
		}
	}
	else if (section == 1) {
		if (self.addressResults.count < 1) {
			if ((self.searchActiveReverseGeocode == YES) || (self.searchActiveForwardGeocode == YES)) {
				cell.textLabel.text = @"Searching....";
				[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
			} else {
				cell.textLabel.text = @"No Results Found";
				[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
			}
			cell.detailTextLabel.text = @"";
		} else {
			if ((self.searchActiveReverseGeocode == YES) || (self.searchActiveForwardGeocode == YES)) {
				[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
			} else {
				[(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
			}
			id placemark = [self.addressResults objectAtIndex:indexPath.row];
            NSString *cellTitle;
            NSString *cellSubtitle;
            if ([placemark isKindOfClass:[CLPlacemark class]]) {
                CLPlacemark *aPlacemark = (CLPlacemark *)placemark;
                cellTitle = [NSString stringWithFormat:@"%@", aPlacemark.thoroughfare];
                cellSubtitle = [NSString stringWithFormat:@"%@ , %@", aPlacemark.locality, aPlacemark.administrativeArea];
            } else if ([placemark isKindOfClass:[MKPlacemark class]]) {
                MKPlacemark *aPlacemark = (MKPlacemark *)placemark;
                cellTitle = [NSString stringWithFormat:@"%@", aPlacemark.thoroughfare];
                cellSubtitle = [NSString stringWithFormat:@"%@ , %@", aPlacemark.locality, aPlacemark.administrativeArea];
            }
            cell.textLabel.text = cellTitle;
            cell.detailTextLabel.text = cellSubtitle;
		}
		
	}
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self.searchDisplayController setActive:NO animated:YES];
    if (indexPath.section == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SBASiteSelected object:[self.siteResults objectAtIndex:indexPath.row]];
    } else if (indexPath.section == 1) {
        id placemark = [self.addressResults objectAtIndex:indexPath.row];
        if ([placemark isKindOfClass:[CLPlacemark class]]) {
            CLPlacemark *aPlacemark = (CLPlacemark *)placemark;
            double span = 1.0;
            double xmin, ymin, xmax, ymax;
            xmin = aPlacemark.location.coordinate.longitude - span;
            ymin = aPlacemark.location.coordinate.latitude - span;
            xmax = aPlacemark.location.coordinate.longitude + span;
            ymax = aPlacemark.location.coordinate.latitude + span;
            AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
            [self.mapView zoomToEnvelope:env animated:YES];
        } else if ([placemark isKindOfClass:[MKPlacemark class]]) {
            MKPlacemark *aPlacemark = (MKPlacemark *)placemark;
            double span = 1.0;
            double xmin, ymin, xmax, ymax;
            xmin = aPlacemark.coordinate.longitude - span;
            ymin = aPlacemark.coordinate.latitude - span;
            xmax = aPlacemark.coordinate.longitude + span;
            ymax = aPlacemark.coordinate.latitude + span;
            AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
            [self.mapView zoomToEnvelope:env animated:YES];
        }
    }
    
}

#pragma mark - Search Related

- (void)searchForString:(NSString *)searchString
{
    self.siteResults = [NSMutableArray array];
    self.addressResults = [NSMutableArray array];
    
    // Address
	if (self.forwardGeocoder == nil) {
		self.forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[self.forwardGeocoder findLocation:searchString];
	self.searchActiveForwardGeocode = YES;
	
	if (self.addressBookSearch == YES) {
		return;
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
				self.searchActiveReverseGeocode = YES;
                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
                    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                        self.searchActiveReverseGeocode = NO;
                        [self.addressResults addObjectsFromArray:placemarks];
                        [self.searchDisplayController.searchResultsTableView reloadData];
                    }];
				
			} else {
				self.searchActiveReverseGeocode = NO;
			}
		}
		
	} else {
		self.searchActiveReverseGeocode = NO;
	}
    
    // Find Task
    self.searchActiveDB = YES;
    if (!self.findTask) {
        self.findTask = [[AGSFindTask alloc] initWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
        self.findTask.delegate = self;
    }
    AGSFindParameters *params = [[AGSFindParameters alloc] init];
    params.contains = YES;
    params.layerIds = [self.mapViewController.visibleLayers valueForKey:@"layerID"];
    params.outSpatialReference = self.mapView.spatialReference;
    params.returnGeometry = NO;
    params.searchFields = @[@"SiteName", @"SiteCode"];
    params.searchText = searchString;
    [self.findTask executeWithParameters:params];
}

- (void)showPeoplePickerController
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = @[@(kABPersonAddressProperty)];
	
	
	picker.displayedProperties = displayedItems;
	// Show the picker
    [self presentViewController:picker animated:YES completion:^(void){}];
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
        self.addressBookSearch = YES;
		[self searchForString:address];
		
	}
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	self.addressBookSearch = NO;
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	self.addressBookSearch = YES;
	return NO;
}

#pragma mark - ForwardGeocoderDelegate

-(void)forwardGeocoderError:(NSString *)errorMessage
{
	self.searchActiveForwardGeocode = NO;
	[self.searchDisplayController.searchResultsTableView reloadData];
}

-(void)forwardGeocoderFoundLocation
{
	NSString *message = @"";
	
	if (self.forwardGeocoder.status == G_GEO_SUCCESS) {
		for (int i = 0; i < [self.forwardGeocoder.results count]; i++) {
			NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionaryWithCapacity:5];
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:i];
            NSMutableString *streetAddress = [NSMutableString string];
            NSString *city;
            NSString *state;
            NSString *zip;
			for (BSAddressComponent *addComponent in [place addressComponents]) {
				for (NSString *aType in addComponent.types) {
					if ([aType isEqualToString:@"street_number"]) {
                        [streetAddress insertString:@" " atIndex:0];
                        [streetAddress insertString:addComponent.shortName atIndex:0];
					}
					else if ([aType isEqualToString:@"route"]) {
						[streetAddress appendString:addComponent.shortName];
                        [addressDictionary setValue:streetAddress forKey:(NSString *)kABPersonAddressStreetKey];
					}
					else if ([aType isEqualToString:@"locality"]) {
						city = addComponent.shortName;
                        [addressDictionary setValue:city forKey:(NSString *)kABPersonAddressCityKey];
					}
					else if ([aType isEqualToString:@"administrative_area_level_1"]) {
						state = addComponent.shortName;
                        [addressDictionary setValue:state forKey:(NSString *)kABPersonAddressStateKey];
					}
					else if ([aType isEqualToString:@"postal_code"]) {
						zip = addComponent.shortName;
                        [addressDictionary setValue:zip forKey:(NSString *)kABPersonAddressZIPKey];
					}
				}
			}
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(place.latitude, place.longitude);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:addressDictionary];
            [self.addressResults addObject:placemark];
		}
        
		self.searchActiveForwardGeocode = NO;
		[self.searchDisplayController.searchResultsTableView reloadData];
		message = @"Forward Geocoder Success.";
	}
	
	switch (self.forwardGeocoder.status) {
		case G_GEO_BAD_KEY:
			message = @"The API key is invalid.";
			break;
		case G_GEO_UNKNOWN_ADDRESS:
			message = [NSString stringWithFormat:@"Could not find %@", self.forwardGeocoder.searchQuery];
			break;
		case G_GEO_TOO_MANY_QUERIES:
			message = @"Too many queries has been made for this API key.";
			break;
		case G_GEO_SERVER_ERROR:
			message = @"Server error, please try again.";
			break;
		default:
			break;
	}
	NSLog(@"Foreward Geocoder Status: %@", message);
}

#pragma mark - AGSFindTaskDelegate

- (void)findTask:(AGSFindTask *)findTask operation:(NSOperation*)op didExecuteWithFindResults:(NSArray *)results
{
    self.searchActiveDB = NO;
    self.siteResults = [NSMutableArray arrayWithArray:results];
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (void)findTask:(AGSFindTask *)findTask operation:(NSOperation*)op didFailWithError:(NSError *)error
{
    self.searchActiveDB = NO;
}

@end
