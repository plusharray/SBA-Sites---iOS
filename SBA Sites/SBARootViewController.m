//
//  SBARootViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBARootViewController.h"
#import "SBASiteTableViewController.h"
#import "DetailViewController.h"
#import "LayerViewController.h"
#import "InformationViewController.h"
#import "SBALayer.h"
#import "SBASearchViewController.h"
#import <AddressBook/AddressBook.h>
#import "GradientView.h"
#import "ClearLabelsCellView.h"

@interface SBARootViewController (Private)
- (void)searchForString:(NSString *)searchString;
- (void)showPeoplePickerController;
@end

@implementation SBARootViewController

@synthesize mapView = _mapView;
@synthesize tiledLayer = _tiledLayer;
@synthesize dynamicLayer = _dynamicLayer;
@synthesize dynamicLayerView = _dynamicLayerView;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize identifyTask = _identifyTask;
@synthesize identifyParams = _identifyParams;
@synthesize mappoint = _mappoint;
@synthesize buttons = _buttons;
@synthesize showLayerListPopoverButton = _showLayerListPopoverButton;
@synthesize showSearchBarButton = _showSearchBarButton;
@synthesize showSiteListPopoverButton = _showSiteListPopoverButton;
@synthesize userLocationButton = _userLocationButton;
@synthesize showInfoButton = _showInfoButton;
@synthesize popoverController = __popoverController;
@synthesize toolbar = _toolbar;
@synthesize layers = _layers;
@synthesize visibleLayers = _visibleLayers;
@synthesize addressBookSearch = _addressBookSearch;
@synthesize searchActiveDB = _searchActiveDB;
@synthesize searchActiveForwardGeocode = _searchActiveForwardGeocode;
@synthesize searchActiveReverseGeocode = _searchActiveReverseGeocode;
@synthesize searchPerformed = _searchPerformed;
@synthesize addressResults = _addressResults;
@synthesize siteResults = _siteResults;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize reverseGeocoder = _reverseGeocoder;
@synthesize forwardGeocoder = _forwardGeocoder;
@synthesize findTask = _findTask;
@synthesize calloutTemplate = _calloutTemplate;
@synthesize selectedMapType = _selectedMapType;

#pragma mark - Accessors

- (NSArray *)visibleLayers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isVisible == YES"];
    NSArray *layers = [self.layers filteredArrayUsingPredicate:predicate];
    return layers;
}

#pragma mark - IBActions

- (IBAction)mapType:(UISegmentedControl *)segmentPick
{
    
}

- (IBAction)toggleLayer:(id)sender
{
    
}

- (IBAction)userLocationButtonTapped:(id)sender
{
    double span = 2.0;
	double xmin, ymin, xmax, ymax;
	xmin = self.mapView.gps.currentLocation.coordinate.longitude - span;
	ymin = self.mapView.gps.currentLocation.coordinate.latitude - span;
	xmax = self.mapView.gps.currentLocation.coordinate.longitude + span;
	ymax = self.mapView.gps.currentLocation.coordinate.latitude + span;
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
	[self.mapView zoomToEnvelope:env animated:YES];
}

- (IBAction)showSiteList:(id)sender
{
    SBASiteTableViewController *viewController = [[SBASiteTableViewController alloc] initWithNibName:@"SBASiteTableViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:^(void){
        [viewController setMapView:self.mapView];
        [viewController setLayers:self.visibleLayers];
        [viewController getSites];
    }];
}

- (IBAction)showLayerList:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		LayerViewController *layerViewController = [[LayerViewController alloc] initWithNibName:@"LayerViewController" bundle:nil];
        layerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		layerViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [layerViewController.mapSegmentedControl addTarget:self action:@selector(mapType:) forControlEvents:UIControlEventValueChanged];
        [layerViewController setLayerArray:self.layers];
        [layerViewController setSelectedMapType:self.selectedMapType];
        [self presentViewController:layerViewController animated:YES completion:^(void){}];
    }
}

- (IBAction)showSearch:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        SBASearchViewController *viewController = [[SBASearchViewController alloc] initWithNibName:@"SBASearchViewController" bundle:nil];
        viewController.spatialReference = self.mapView.spatialReference;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        
    }
}

- (IBAction)showInfo:(id)sender
{
    InformationViewController *infoViewController = [[InformationViewController alloc] initWithNibName:@"InformationViewController" bundle:nil];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

- (void)layerSelected:(NSNotification *)notification
{
    //set visible layers
	self.dynamicLayer.visibleLayers = [self.visibleLayers valueForKey:@"layerID"];
}

- (void)siteSelected:(NSNotification *)notification
{
    AGSIdentifyResult *result = (AGSIdentifyResult *)[notification object];
    AGSPoint* point = (AGSPoint *)[[result feature] geometry];
    
    //clear previous results
    [self.graphicsLayer removeAllGraphics];
	
    //add new results
    AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
    symbol.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
    
    result.feature.symbol = symbol;
    [self.graphicsLayer addGraphic:result.feature];
    
    //get the site code & name
    NSString *siteCode = [result.feature.attributes objectForKey:@"SiteCode"];
    NSString *siteName = [result.feature.attributes objectForKey:@"SiteName"];
    self.mapView.callout.title = siteCode;
    self.mapView.callout.detail = siteName;
    
    // Show the callout
    [self.mapView showCalloutAtPoint:point forGraphic:[result feature] animated:YES];
    
    // Zoom to point
    [self.mapView centerAtPoint:point animated:YES];
    
    //call dataChanged on the graphics layer to redraw the graphics
    [self.graphicsLayer dataChanged];	
}

- (void)mapTypeChanged:(NSNotification *)notification
{
    NSNumber *mapType = (NSNumber *)notification.object;
    self.selectedMapType = mapType.integerValue;
    NSURL *url;
    if (self.selectedMapType == 0) {
        url = [NSURL URLWithString:TiledMapServiceURL];
    } else {
        url = [NSURL URLWithString:AerialMapServiceURL];
    }
    [self.mapView removeMapLayerWithName:@"Tiled Layer"];
    self.tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:url];
    //Add it to the map view
    UIView<AGSLayerView>* lyr = [self.mapView insertMapLayer:self.tiledLayer withName:@"Tiled Layer" atIndex:0];
	
	// Setting these two properties lets the map draw while still performing a zoom/pan
	lyr.drawDuringPanning = YES;
	lyr.drawDuringZooming = YES;
}

#pragma mark - Init

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)setupMapView
{
    // Set up the layers
    NSMutableArray *allLayers = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        [allLayers addObject:[SBALayer layerForID:i]];
    }
    self.layers = [NSArray arrayWithArray:allLayers];
    
    // set the delegate for the map view
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    
    //create an instance of a tiled map service layer
	self.tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:TiledMapServiceURL]];
	
	//Add it to the map view
	UIView<AGSLayerView>* lyr = [self.mapView addMapLayer:self.tiledLayer withName:@"Tiled Layer"];
	
	// Setting these two properties lets the map draw while still performing a zoom/pan
	lyr.drawDuringPanning = YES;
	lyr.drawDuringZooming = YES;
	
	//create an instance of a dynmaic map layer
	self.dynamicLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
    
	//set visible layers
	self.dynamicLayer.visibleLayers = [self.visibleLayers valueForKey:@"layerID"];
	
	//name the layer. This is the name that is displayed if there was a property page, tocs, etc...
	self.dynamicLayerView = [self.mapView addMapLayer:self.dynamicLayer withName:@"Dynamic Layer"];
	
	//set transparency
	self.dynamicLayerView.alpha = 0.5;
    
	// create and add the graphics layer to the map
	self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
	
	//create identify task
	self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
	self.identifyTask.delegate = self;
	
	//create identify parameters
	self.identifyParams = [[AGSIdentifyParameters alloc] init];
    
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:4326];
	double xmin, ymin, xmax, ymax;
	xmin = -125.33203125;
	ymin = -1.58203125;
	xmax = -69.08203125;
	ymax = 79.27734375;
	
	// zoom to the United States
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:sr];
	[self.mapView zoomToEnvelope:env animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hack to make sure scope buttons are hidden
    [self.searchDisplayController.searchBar setShowsScopeBar:NO];
    [self.searchDisplayController.searchBar sizeToFit];
    
    // Set the default mapType
    self.selectedMapType = 0;
    
    // Setup the MapView
    [self setupMapView];
    
    // Setup Navigation Bar and Toolbars
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteSelected:) name:SBASiteSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerSelected:) name:SBALayerSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapTypeChanged:) name:SBAMapTypeChanged object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.mapView.gps stop];
    self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark AGSMapViewLayerDelegate methods

-(void) mapViewDidLoad:(AGSMapView*)mapView {
	[self.mapView.gps start];
}

#pragma mark - AGSMapViewCalloutDelegate methods

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {
    
    //store for later use
    self.mappoint = mappoint;
    
	self.identifyParams.layerIds = [self.visibleLayers valueForKey:@"layerID"];
	self.identifyParams.tolerance = 3;
	self.identifyParams.geometry = self.mappoint;
	self.identifyParams.size = self.mapView.bounds.size;
	self.identifyParams.mapEnvelope = self.mapView.envelope;
	self.identifyParams.returnGeometry = YES;
	self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
	self.identifyParams.spatialReference = self.mapView.spatialReference;
    
	//execute the task
	[self.identifyTask executeWithParameters:self.identifyParams];
	
}
//show the attributes if accessory button is clicked
- (void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic
{
    DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    viewController.site = graphic;
    [self.navigationController pushViewController:viewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - AGSIdentifyTaskDelegate methods
//results are returned
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results
{
	
    //clear previous results
    [self.graphicsLayer removeAllGraphics];
	
    //add new results
    AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
    symbol.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
	
	// for each result, set the symbol and add it to the graphics layer
    for (AGSIdentifyResult* result in results) {
        result.feature.symbol = symbol;
        [self.graphicsLayer addGraphic:result.feature];
    }
    if (results.count > 0) {
        //set the callout content for the first result
        AGSIdentifyResult *result = (AGSIdentifyResult*)[results objectAtIndex:0];
        //get the site code & name
        NSString *siteCode = [result.feature.attributes objectForKey:@"SiteCode"];
        NSString *siteName = [result.feature.attributes objectForKey:@"SiteName"];
        self.mapView.callout.title = siteCode;
        self.mapView.callout.detail = siteName;
        
        //show callout
        [self.mapView showCalloutAtPoint:self.mappoint forGraphic:((AGSIdentifyResult*)[results objectAtIndex:0]).feature animated:YES];
        
        //call dataChanged on the graphics layer to redraw the graphics
        [self.graphicsLayer dataChanged];	
    }
}

//if there's an error with the query display it to the user
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error
{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
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
    if (cell == nil) {
        cell = [[[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundView = [[[GradientView alloc] init] autorelease];
    }
    int section = indexPath.section;
	int row = indexPath.row;
	
	if (cell.accessoryView == nil) {
		UIActivityIndicatorView *searchActivityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
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
			
            MKPlacemark *placemark = [self.addressResults objectAtIndex:row];
            NSString *cellTitle = [NSString stringWithFormat:@"%@", placemark.thoroughfare];
            NSString *cellSubtitle = [NSString stringWithFormat:@"%@ , %@", placemark.locality, placemark.administrativeArea];
            cell.textLabel.text = cellTitle;
            cell.detailTextLabel.text = cellSubtitle;
		}
		
	}
    // Configure the cell...
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [self.searchDisplayController setActive:NO animated:YES];
    if (indexPath.section == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SBASiteSelected object:[self.siteResults objectAtIndex:indexPath.row]];
    } else if (indexPath.section == 1) {
        MKPlacemark *placemark = [self.addressResults objectAtIndex:indexPath.row];
        double span = 2.0;
        double xmin, ymin, xmax, ymax;
        xmin = placemark.coordinate.longitude - span;
        ymin = placemark.coordinate.latitude - span;
        xmax = placemark.coordinate.longitude + span;
        ymax = placemark.coordinate.latitude + span;
        AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
        [self.mapView zoomToEnvelope:env animated:YES];
        /*
        AGSPoint *point = [[AGSPoint alloc] initWithX:placemark.coordinate.latitude y:placemark.coordinate.longitude spatialReference:self.mapView.spatialReference];
        
        
        //create a marker symbol to use in our graphic
        AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"BluePushpin.png"];
        marker.xoffset = 9;
        marker.yoffset = -16;
        marker.hotspot = CGPointMake(-9, -11);
        
        //create the callout template, used when the user displays the callout
		self.calloutTemplate = [[AGSCalloutTemplate alloc]init];
        //set the text and detail text based on 'Name' and 'Descr' fields in the attributes
        self.calloutTemplate.titleTemplate = placemark.thoroughfare;
        self.calloutTemplate.detailTemplate = [NSString stringWithFormat:@"%@ , %@", placemark.locality, placemark.administrativeArea];
        
        //create the graphic
        AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:point
                                                            symbol:marker 
                                                        attributes:(NSMutableDictionary *)[[placemark addressDictionary] mutableCopy]
                                              infoTemplateDelegate:self.calloutTemplate];
        //add the graphic to the graphics layer
        [self.graphicsLayer addGraphic:graphic];
        //we have one result, center at that point
        [self.mapView centerAtPoint:point animated:NO];
         
        // set the width of the callout
        self.mapView.callout.width = 250;
        
        //show the callout
        [self.mapView showCalloutAtPoint:(AGSPoint *)graphic.geometry forGraphic:graphic animated:YES];
        
        //since we've added graphics, make sure to redraw
        [self.graphicsLayer dataChanged];
         */
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
				self.reverseGeocoder =	[[[MKReverseGeocoder alloc] initWithCoordinate:coord] autorelease];
				self.reverseGeocoder.delegate = self;
				[self.reverseGeocoder start];
				self.searchActiveReverseGeocode = YES;
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
    params.layerIds = [self.visibleLayers valueForKey:@"layerID"];
    params.outSpatialReference = self.mapView.spatialReference;
    params.returnGeometry = NO;
    params.searchFields = [NSArray arrayWithObjects:@"SiteName", @"SiteCode", nil];
    params.searchText = searchString;
    [self.findTask executeWithParameters:params];
}

- (void)showPeoplePickerController
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonAddressProperty], nil];
	
	
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

#pragma mark - MKReverseGeocoder

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	self.searchActiveReverseGeocode = NO;
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	self.searchActiveReverseGeocode = NO;
    [self.addressResults addObject:placemark];
	[self.searchDisplayController.searchResultsTableView reloadData];
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
					}
					else if ([aType isEqualToString:@"locality"]) {
						city = addComponent.shortName;
					}
					else if ([aType isEqualToString:@"administrative_area_level_1"]) {
						state = addComponent.shortName;
					}
					else if ([aType isEqualToString:@"postal_code"]) {
						zip = addComponent.shortName;
					}
				}
			}
            if (streetAddress)
                [addressDictionary setValue:streetAddress forKey:(NSString *)kABPersonAddressStreetKey];
            if (city)
                [addressDictionary setValue:city forKey:(NSString *)kABPersonAddressCityKey];
            if (state)
                [addressDictionary setValue:state forKey:(NSString *)kABPersonAddressStateKey];
            if (zip)
                [addressDictionary setValue:zip forKey:(NSString *)kABPersonAddressZIPKey];
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
