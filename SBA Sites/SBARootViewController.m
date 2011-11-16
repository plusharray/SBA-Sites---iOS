//
//  SBARootViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBARootViewController.h"
#import "SBASiteTableViewController.h"

@implementation SBARootViewController

@synthesize mapView = _mapView;
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

#pragma mark - Accessors

- (NSMutableArray *)layers
{
    if (!_layers) {
        _layers = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            [_layers addObject:[NSNumber numberWithInt:i]];
        }
    }
    return _layers;
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
    //self.mapView.gps.currentLocation.coordinate.latitude;
    double span = 2.0;
	double xmin, ymin, xmax, ymax;
	xmin = self.mapView.gps.currentLocation.coordinate.longitude - span;
	ymin = self.mapView.gps.currentLocation.coordinate.latitude - span;
	xmax = self.mapView.gps.currentLocation.coordinate.longitude + span;
	ymax = self.mapView.gps.currentLocation.coordinate.latitude + span;
	
	// zoom to the United States
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
	[self.mapView zoomToEnvelope:env animated:YES];
}

- (IBAction)showSiteList:(id)sender
{
    SBASiteTableViewController *viewController = [[SBASiteTableViewController alloc] initWithNibName:@"SBASiteTableViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:^(void){
        [viewController setMapView:self.mapView];
        [viewController setLayers:self.layers];
        [viewController getSites];
    }];
}

- (IBAction)showLayerList:(id)sender
{
    
}

- (IBAction)showSearch:(id)sender
{
    
}

- (IBAction)showInfo:(id)sender
{
    
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

#pragma mark - View lifecycle

- (void)setupMapView
{
    // set the delegate for the map view
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    
    //create an instance of a tiled map service layer
	AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:TiledMapServiceURL]];
	
	//Add it to the map view
	UIView<AGSLayerView>* lyr = [self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
	
	// Setting these two properties lets the map draw while still performing a zoom/pan
	lyr.drawDuringPanning = YES;
	lyr.drawDuringZooming = YES;
	
	//create an instance of a dynmaic map layer
	self.dynamicLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
	
	//set visible layers
	self.dynamicLayer.visibleLayers = [NSArray arrayWithArray:self.layers];
	
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
    
    // Setup the MapView
    [self setupMapView];
    
    // Setup Navigation Bar and Toolbars
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.mapView.gps stop];
    self.mapView = nil;
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
    
	self.identifyParams.layerIds = [NSArray arrayWithArray:self.layers];
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
        //get the state name
        NSString *stateName = [((AGSIdentifyResult*)[results objectAtIndex:0]).feature.attributes objectForKey:@"STATE_NAME"]; 
        self.mapView.callout.title = stateName;
        self.mapView.callout.detail = @"Click for more detail..";
        
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

@end