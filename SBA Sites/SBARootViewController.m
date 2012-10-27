//
//  SBARootViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBARootViewController.h"
#import "SBASiteTableViewController.h"
#import "SBASiteDetailViewController.h"
#import "LayerViewController.h"
#import "InformationViewController.h"
#import "SBALayer.h"
#import "SBASearchViewController.h"
#import <AddressBook/AddressBook.h>
#import "GradientView.h"
#import "ClearLabelsCellView.h"
#import "PALocationController.h"

#define kRouteTaskUrl @"http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Network/USA/NAServer/Route"

@interface SBARootViewController ()
{
	int	_directionIndex;
}
- (void)searchForString:(NSString *)searchString;
- (void)showPeoplePickerController;
- (void)showRouteToolbar;
- (void)hideRouteToolbar;

@end

@implementation SBARootViewController

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
    self.selectedMapType = segmentPick.selectedSegmentIndex;
    [[NSNotificationCenter defaultCenter] postNotificationName:SBAMapTypeChanged object:@(self.selectedMapType)];
}

- (IBAction)toggleLayer:(id)sender
{
    UIButton *button = (UIButton *)sender;
    SBALayer *layer = (SBALayer *)[self.layers objectAtIndex:button.tag];
    layer.visible = !layer.visible;
    if (layer.visible) {
        [button setImage:layer.image forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"Grey.png"] forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SBALayerSelected object:nil];
}

- (IBAction)userLocationButtonTapped:(id)sender
{
	[self.locationController.locationManager startUpdatingLocation];
    double span = 1.0;
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
    [viewController setMapView:self.mapView];
    [viewController setLayers:self.visibleLayers];
    [viewController getSites];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:viewController animated:YES completion:^(void){}];
    } else {
        if (!self.masterPopoverController.popoverVisible) {
			self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
			self.masterPopoverController.delegate = self;
			[self.masterPopoverController presentPopoverFromBarButtonItem:self.showSiteListPopoverButton
												 permittedArrowDirections:UIPopoverArrowDirectionAny
																 animated:YES];
		}
    }
}

- (IBAction)showLayerList:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		LayerViewController *layerViewController = [[LayerViewController alloc] initWithNibName:@"LayerViewController" bundle:nil];
        layerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		layerViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [layerViewController.mapTypeSegmentedControl addTarget:self action:@selector(mapType:) forControlEvents:UIControlEventValueChanged];
        [layerViewController setLayerArray:self.layers];
        [layerViewController setSelectedMapType:self.selectedMapType];
        [self presentViewController:layerViewController animated:YES completion:^(void){}];
    }
}

- (IBAction)showSearch:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
    } else {
        if (!self.masterPopoverController.popoverVisible) {
            SBASearchViewController *viewController = [[SBASearchViewController alloc] initWithNibName:@"SBASearchViewController" bundle:nil];
            //viewController.mapView = self.mapView;
            //viewController.visibleLayers = self.visibleLayers;
			self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
			self.masterPopoverController.delegate = self;
			[self.masterPopoverController presentPopoverFromBarButtonItem:self.showSearchBarButton
												 permittedArrowDirections:UIPopoverArrowDirectionAny
																 animated:YES];
		}
    }
}

- (IBAction)showInfo:(id)sender
{
    InformationViewController *viewController = [[InformationViewController alloc] initWithNibName:@"InformationViewController" bundle:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        if (!self.masterPopoverController.popoverVisible) {
			viewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
			self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
			self.masterPopoverController.delegate = self;
			[self.masterPopoverController presentPopoverFromBarButtonItem:self.showInfoButton
												 permittedArrowDirections:UIPopoverArrowDirectionAny
																 animated:YES];
		}
    }
}

- (void)layerSelected:(NSNotification *)notification
{
    //set visible layers
	self.dynamicLayer.visibleLayers = [self.visibleLayers valueForKey:@"layerID"];
}

- (void)siteSelected:(NSNotification *)notification
{
    AGSIdentifyResult *result = (AGSIdentifyResult *)[notification object];;
    [self.mapView centerAtPoint:(AGSPoint *)[[result feature] geometry] animated:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
        if (!self.masterPopoverController.popoverVisible) {
            SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"DetailViewController-iPad" bundle:nil];
            viewController.site = result.feature;
			viewController.delegate = self;
            viewController.contentSizeForViewInPopover = CGSizeMake(320.0, 416.0);
            self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
            self.masterPopoverController.delegate = self;
            CGPoint point = [self.mapView toScreenPoint:(AGSPoint *)[[result feature] geometry]];
            [self.masterPopoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1.0, 1.0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        //get the site code & name
        NSString *siteCode = [result.feature.attributes objectForKey:@"SiteCode"];
        NSString *siteName = [result.feature.attributes objectForKey:@"SiteName"];
        self.mapView.callout.title = siteCode;
        self.mapView.callout.detail = siteName;
        //show callout
        [self.mapView showCalloutAtPoint:self.mappoint forGraphic:result.feature animated:YES];
        
        //call dataChanged on the graphics layer to redraw the graphics
        [self.graphicsLayer dataChanged];
    }
}

- (IBAction)resetRoute:(id)sender
{
	// reset index
	_directionIndex = 0;
	
	[self hideRouteToolbar];
	
	// remove the stop graphics from the graphics layer
	// careful not to attempt to mutate the graphics array while
	// it is being enumerated
	NSMutableArray *graphics = [self.graphicsLayer.graphics mutableCopy];
	for (AGSGraphic *g in graphics) {
		if ([g isKindOfClass:[AGSStopGraphic class]]) {
			[self.graphicsLayer removeGraphic:g];
		}
	}
	
	// tell the graphics layer to redraw
	[self.graphicsLayer dataChanged];
}

- (IBAction)previousTurn:(id)sender
{
	_directionIndex--;
	
    // remove current direction
	if ([self.graphicsLayer.graphics containsObject:self.currentDirectionGraphic]) {
		[self.graphicsLayer removeGraphic:self.currentDirectionGraphic];
	}
    
	// get next direction
	AGSDirectionSet *directions = self.routeResult.directions;
	self.currentDirectionGraphic = [directions.graphics objectAtIndex:_directionIndex];
	self.currentDirectionGraphic.symbol = [self currentDirectionSymbol];
	[self.graphicsLayer addGraphic:self.currentDirectionGraphic];
	[self.graphicsLayer dataChanged];
	
    // update banner text
	[self updateDirectionsLabel:self.currentDirectionGraphic.text];
	
    // zoom to env factored by 1.3
	AGSMutableEnvelope *env = [[self.currentDirectionGraphic.geometry.envelope mutableCopy] autorelease];
	[env expandByFactor:1.3];
	[self.mapView zoomToEnvelope:env animated:YES];
	
    [self setupNextPreviousButtons];
}

- (void)setupNextPreviousButtons
{
    // determine if we need to disable a next/prev button
    if (_directionIndex >= self.routeResult.directions.graphics.count - 1) {
		self.rightArrowButton.enabled = NO;
	} else {
		self.rightArrowButton.enabled = YES;
	}
	if (_directionIndex > 0) {
		self.leftArrowButton.enabled = YES;
	} else {
		self.leftArrowButton.enabled = NO;
	}
}

- (IBAction)nextTurn:(id)sender
{
	_directionIndex++;
	
    // remove current direction graphic, so we can display next one
	if ([self.graphicsLayer.graphics containsObject:self.currentDirectionGraphic]) {
		[self.graphicsLayer removeGraphic:self.currentDirectionGraphic];
	}
	
    // get current direction and add it to the graphics layer
	AGSDirectionSet *directions = self.routeResult.directions;
	self.currentDirectionGraphic = [directions.graphics objectAtIndex:_directionIndex];
	self.currentDirectionGraphic.symbol = [self currentDirectionSymbol];
	[self.graphicsLayer addGraphic:self.currentDirectionGraphic];
	[self.graphicsLayer dataChanged];
	
    // update banner
	[self updateDirectionsLabel:self.currentDirectionGraphic.text];
	
    // zoom to envelope of the current direction (expanded by factor of 1.3)
	AGSMutableEnvelope *env = [[self.currentDirectionGraphic.geometry.envelope mutableCopy] autorelease];
	[env expandByFactor:1.3];
	[self.mapView zoomToEnvelope:env animated:YES];
	
    [self setupNextPreviousButtons];
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
    
	// Start Location Controller
	self.locationController = [PALocationController sharedController];
	
    // Set the default mapType
    self.selectedMapType = 0;
    
    // Setup the MapView
    [self setupMapView];
    
    // Register for Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteSelected:) name:SBASiteSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerSelected:) name:SBALayerSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapTypeChanged:) name:SBAMapTypeChanged object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.selectedMapType = 0;
        self.buttons = [NSMutableArray arrayWithCapacity:5];
        for (SBALayer *aLayer in self.layers) {
            // Make Button to control visibility of layer
            UIButton *layerButton = [[[NSBundle mainBundle] loadNibNamed:@"LayerButton" owner:self options:nil] objectAtIndex:0];
            layerButton.titleLabel.font = [UIFont systemFontOfSize: 12];
            [layerButton setTitle:aLayer.name forState:UIControlStateNormal];
            [layerButton setImage:aLayer.image forState:UIControlStateNormal];
            layerButton.tag = [self.layers indexOfObject:aLayer];
            layerButton.frame = CGRectMake(0.0f, 0.0f, 130.0f, 42.0f);
            // create a bar button item to hold the new button
            UIBarButtonItem *buttonBarButton = [[UIBarButtonItem alloc] initWithCustomView:layerButton];
            [self.buttons addObject:buttonBarButton];
        }
        [self.toolbar setItems:self.buttons];
    }
}

- (void)viewDidUnload
{
    [self setMapTypeSegmentedControl:nil];
	[self setRouteToolbar:nil];
	[self setLeftArrowButton:nil];
	[self setRightArrowButton:nil];
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
	self.identifyParams.tolerance = 12;
	self.identifyParams.geometry = self.mappoint;
	self.identifyParams.size = self.mapView.bounds.size;
	self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
	self.identifyParams.returnGeometry = YES;
	self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
	self.identifyParams.spatialReference = self.mapView.spatialReference;
    
	//execute the task
	[self.identifyTask executeWithParameters:self.identifyParams];
	
}
//show the attributes if accessory button is clicked
- (void)mapView:(AGSMapView *)mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *)graphic
{
    SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"SBASiteDetailViewController" bundle:nil];
    viewController.site = graphic;
	viewController.delegate = self;
    
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
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (!self.masterPopoverController.popoverVisible) {
                SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"DetailViewController-iPad" bundle:nil];
                viewController.site = result.feature;
                viewController.contentSizeForViewInPopover = CGSizeMake(320.0, 416.0);
                self.masterPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
                self.masterPopoverController.delegate = self;
                CGPoint point = [self.mapView toScreenPoint:self.mappoint];
                [self.masterPopoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1.0, 1.0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        } else {
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
        cell = [[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.backgroundView = [[GradientView alloc] init];
    }
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
				self.searchActiveReverseGeocode = YES;
				CLGeocoder *geocoder = [[CLGeocoder alloc] init];
				CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
				[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
					self.searchActiveReverseGeocode = NO;
					[self.addressResults addObjectsFromArray:placemarks];
					[self.searchDisplayController.searchResultsTableView reloadData];
					self.searchActiveReverseGeocode = NO;
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
    params.layerIds = [self.visibleLayers valueForKey:@"layerID"];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
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

#pragma mark - AGSRouteTaskDelegate

//
// we got the default parameters from the service
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams {
	self.routeTaskParams = routeParams;
}

//
// an error was encountered while getting defaults
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error {
	
	[self hideRouteToolbar];
	
	// Create an alert to let the user know the retrieval failed
	// Click Retry to attempt to retrieve the defaults again
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
												 message:@"Failed to retrieve default route parameters"
												delegate:self
									   cancelButtonTitle:@"Ok" otherButtonTitles:@"Retry",nil];
	[av show];
}


//
// route was solved
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
	
    // update our banner with status
    [self updateDirectionsLabel:@"Routing completed"];
	
	// we know that we are only dealing with 1 route...
	self.routeResult = [routeTaskResult.routeResults lastObject];
	if (self.routeResult) {
		[self showRouteToolbar];
		
		// symbolize the returned route graphic
		self.routeResult.routeGraphic.symbol = [self routeSymbol];
        
        // add the route graphic to the graphic's layer
		[self.graphicsLayer addGraphic:self.routeResult.routeGraphic];
		
		// enable the next button so the user can traverse directions
		self.rightArrowButton.enabled = YES;
		
		// reset index
		_directionIndex = 0;
		
		[self setupNextPreviousButtons];
		
        // remove the stop graphics from the graphics layer
        // careful not to attempt to mutate the graphics array while
        // it is being enumerated
		NSMutableArray *graphics = [self.graphicsLayer.graphics mutableCopy];
		for (AGSGraphic *g in graphics) {
			if ([g isKindOfClass:[AGSStopGraphic class]]) {
				[self.graphicsLayer removeGraphic:g];
			}
		}
		
		double xMin = self.mapView.fullEnvelope.xmax;
		double xMax = self.mapView.fullEnvelope.xmin;
		double yMin = self.mapView.fullEnvelope.ymax;
		double yMax = self.mapView.fullEnvelope.ymin;
		
        // add the returned stops...it's possible these came back in a different order
        // because we specified findBestSequence
		for (AGSStopGraphic *sg in self.routeResult.stopGraphics) {
            
            // get the sequence from the attribetus
			NSInteger sequence = [[sg.attributes valueForKey:@"Sequence"] integerValue];
            
            // create a composite symbol using the sequence number
			sg.symbol = [self stopSymbolWithNumber:sequence];
            
            // add the graphic
			[self.graphicsLayer addGraphic:sg];
			
			if (sg.geometry.envelope.xmin < xMin)
				xMin = sg.geometry.envelope.xmin;
			if (sg.geometry.envelope.xmax > xMax)
				xMax = sg.geometry.envelope.xmax;
			if (sg.geometry.envelope.ymin < yMin)
				yMin = sg.geometry.envelope.ymin;
			if (sg.geometry.envelope.ymax > yMax)
				yMax = sg.geometry.envelope.ymax;
		}
        
        // tell the graphics layer to redraw
		[self.graphicsLayer dataChanged];
		AGSMutableEnvelope *envelope = [[AGSMutableEnvelope alloc] initWithXmin:xMin ymin:yMin xmax:xMax ymax:yMax spatialReference:self.mapView.spatialReference];
		[envelope expandByFactor:2.0];
		[self.mapView zoomToEnvelope:envelope animated:YES];
	}
}

//
// solve failed
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
	
	[self updateDirectionsLabel:@"Routing failed"];
	
	[self hideRouteToolbar];
	
	// the solve route failed...
	// let the user know
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Solve Route Failed"
												 message:[NSString stringWithFormat:@"Error: %@", error]
												delegate:nil
									   cancelButtonTitle:@"Ok"
									   otherButtonTitles:nil];
	[av show];
}

#pragma mark - Routing

//
// represents the current direction
//
- (AGSCompositeSymbol*)currentDirectionSymbol {
	AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
	
	AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls1.color = [UIColor whiteColor];
	sls1.style = AGSSimpleLineSymbolStyleSolid;
	sls1.width = 8;
	[cs.symbols addObject:sls1];
	
	AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls2.color = [UIColor redColor];
	sls2.style = AGSSimpleLineSymbolStyleDash;
	sls2.width = 4;
	[cs.symbols addObject:sls2];
	
	return cs;
}

//
// create a composite symbol with a number
//
- (AGSCompositeSymbol*)stopSymbolWithNumber:(NSInteger)stopNumber {
	AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
	
    // create outline
	AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
	sls.color = [UIColor blackColor];
	sls.width = 2;
	sls.style = AGSSimpleLineSymbolStyleSolid;
	
    // create main circle
	AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
	sms.color = [UIColor greenColor];
	sms.outline = sls;
	sms.size = 20;
	sms.style = AGSSimpleMarkerSymbolStyleCircle;
	[cs.symbols addObject:sms];
	
    // add number as a text symbol
	AGSTextSymbol *ts = [[AGSTextSymbol alloc] initWithTextTemplate:[NSString stringWithFormat:@"%d", stopNumber]
															  color:[UIColor blackColor]];
	ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
	ts.hAlignment = AGSTextSymbolHAlignmentCenter;
	ts.fontSize	= 16;
	ts.fontWeight = AGSTextSymbolFontWeightBold;
	[cs.symbols addObject:ts];
	
	return cs;
}

//
// create our route symbol
//
- (AGSCompositeSymbol*)routeSymbol {
	AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
	
	AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls1.color = [UIColor yellowColor];
	sls1.style = AGSSimpleLineSymbolStyleSolid;
	sls1.width = 8;
	[cs.symbols addObject:sls1];
	
	AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
	sls2.color = [UIColor blueColor];
	sls2.style = AGSSimpleLineSymbolStyleSolid;
	sls2.width = 4;
	[cs.symbols addObject:sls2];
	
	return cs;
}


- (void)updateDirectionsLabel:(NSString*)newLabel {
	self.directionsLabel.text = newLabel;
}

- (void)showRouteToolbar
{
	if (![self.view.subviews containsObject:self.routeToolbar]) {
		[self.routeToolbar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
		[self.view addSubview:self.routeToolbar];
	}
	[self.searchDisplayController.searchBar setHidden:YES];
}

- (void)hideRouteToolbar
{
	[self.searchDisplayController.searchBar setHidden:NO];
	[self.routeToolbar removeFromSuperview];
	self.directionsBannerView.hidden = YES;
}

//
// perform the route task's solve operation
//
- (void)requestRoute:(AGSGraphic *)site {
	
	self.directionsBannerView.hidden = NO;
	
    // update our banner
	[self updateDirectionsLabel:@"Routing..."];
	
	// Create the starting graphic here
	if (self.locationController.location) {
		AGSPoint *point = [[AGSPoint alloc] initWithX:self.locationController.location.coordinate.longitude y:self.locationController.location.coordinate.latitude spatialReference:self.mapView.spatialReference];
		AGSStopGraphic *graphic = [[AGSStopGraphic alloc] initWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
		self.startingGraphic = graphic;
		[self.graphicsLayer addGraphic:self.startingGraphic];
		[self.graphicsLayer dataChanged];
	} else {
		self.startingGraphic = nil;
		UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Location Error" message:@"Please make sure you have Location Services enabled for this app."];
		[alertView show];
		return;
	}
	
	// Create the stopping graphic here
	if (site) {
		AGSPoint *point = [[AGSPoint alloc] initWithX:[[site.attributes valueForKey:@"Longitude"] floatValue] y:[[site.attributes valueForKey:@"Latitude"] floatValue] spatialReference:self.mapView.spatialReference];
		AGSStopGraphic *graphic = [[AGSStopGraphic alloc] initWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
		self.destinationGraphic = graphic;
		[self.graphicsLayer addGraphic:self.destinationGraphic];
		[self.graphicsLayer dataChanged];
	} else {
		self.destinationGraphic = nil;
		UIAlertView *alertView = [UIAlertView alertViewWithTitle:@"Location Error" message:@"Please select a site to get directions to."];
		[alertView show];
		return;
	}
	
	// Setup the route task
	NSURL *routeTaskUrl = [NSURL URLWithString:kRouteTaskUrl];
	self.routeTask = [AGSRouteTask routeTaskWithURL:routeTaskUrl];
    
    // assign delegate to this view controller
	self.routeTask.delegate = self;
	
	// kick off asynchronous method to retrieve default parameters
	// for the route task
	[self.routeTask retrieveDefaultRouteTaskParameters];
	
	NSMutableArray *stops = [NSMutableArray array];
	NSMutableArray *polygonBarriers = [NSMutableArray array];
	
	[stops addObject:self.startingGraphic];
	[stops addObject:self.destinationGraphic];
	
	// set the stop and polygon barriers on the parameters object
	if (stops.count > 0) {
		[self.routeTaskParams setStopsWithFeatures:stops];
	}
	
	if (polygonBarriers.count > 0) {
		[self.routeTaskParams setPolygonBarriersWithFeatures:polygonBarriers];
	}
	
	// this generalizes the route graphics that are returned
	self.routeTaskParams.outputGeometryPrecision = 5.0;
	self.routeTaskParams.outputGeometryPrecisionUnits = AGSUnitsMeters;
    
    // return the graphic representing the entire route, generalized by the previous
    // 2 properties: outputGeometryPrecision and outputGeometryPrecisionUnits
	self.routeTaskParams.returnRouteGraphics = YES;
	
	// this returns turn-by-turn directions
	self.routeTaskParams.returnDirections = YES;
	
	// the next 3 lines will cause the task to find the
	// best route regardless of the stop input order
	self.routeTaskParams.findBestSequence = YES;
	self.routeTaskParams.preserveFirstStop = YES;
	self.routeTaskParams.preserveLastStop = YES;
	
	// since we used "findBestSequence" we need to
	// get the newly reordered stops
	self.routeTaskParams.returnStopGraphics = YES;
	
	// ensure the graphics are returned in our map's spatial reference
	self.routeTaskParams.outSpatialReference = self.mapView.spatialReference;
	
	// let's ignore invalid locations
	self.routeTaskParams.ignoreInvalidLocations = YES;
	
	// you can also set additional properties here that should
	// be considered during analysis.
	// See the conceptual help for Routing task.
	
	// execute the route task
	[self.routeTask solveWithParameters:self.routeTaskParams];
}


@end
