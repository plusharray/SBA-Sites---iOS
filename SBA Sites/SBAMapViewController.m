//
//  MapViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 9/24/12.
//
//

#import "SBAMapViewController.h"
#import "SBALayer.h"
#import "SBASiteDetailViewController.h"
#import "SBASiteInfoTemplate.h"
#import "MKNetworkOperation.h"
#import "MKNetworkEngine.h"
#import "KeychainItemWrapper.h"

@interface SBAMapViewController ()
@end

@implementation SBAMapViewController

@synthesize mapView = _mapView;
@synthesize tiledLayer = _tiledLayer;
@synthesize dynamicLayer = _dynamicLayer;
@synthesize dynamicLayerView = _dynamicLayerView;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize identifyTask = _identifyTask;
@synthesize identifyParams = _identifyParams;
@synthesize mappoint = _mappoint;
@synthesize layers = _layers;
@synthesize visibleLayers = _visibleLayers;
@synthesize calloutTemplate = _calloutTemplate;
@synthesize selectedMapType = _selectedMapType;
@synthesize popoverController = __popoverController;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
		// Register for Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteSelected:) name:SBASiteSelected object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layerSelected:) name:SBALayerSelected object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapTypeChanged:) name:SBAMapTypeChanged object:nil];
		
		// Set the default mapType
		self.selectedMapType = 0;
    }
    return self;
}

#pragma mark - Properties

- (void)setMapView:(AGSMapView *)mapView
{
	_mapView = mapView;
	
    // Setup the MapView
    [self userAuthentication];
}

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
    double span = 1.0;
	double xmin, ymin, xmax, ymax;
	xmin = self.mapView.gps.currentLocation.coordinate.longitude - span;
	ymin = self.mapView.gps.currentLocation.coordinate.latitude - span;
	xmax = self.mapView.gps.currentLocation.coordinate.longitude + span;
	ymax = self.mapView.gps.currentLocation.coordinate.latitude + span;
	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
	[self.mapView zoomToEnvelope:env animated:YES];
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
        [self.popoverController dismissPopoverAnimated:YES];
        if (!self.popoverController.popoverVisible) {
            SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"DetailViewController-iPad" bundle:nil];
            viewController.site = result.feature;
            viewController.contentSizeForViewInPopover = CGSizeMake(320.0, 416.0);
            self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
            self.popoverController.delegate = self;
            CGPoint point = [self.mapView toScreenPoint:(AGSPoint *)[[result feature] geometry]];
            [self.popoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1.0, 1.0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

#pragma mark - Setup

- (void)setupMapView: (BOOL) userAuthenticated
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
    if(userAuthenticated)
    {
        self.dynamicLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:DynamicMapServiceURLAuthenticated]];
    }
    else{
        self.dynamicLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
    }
    
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

-(void) userAuthentication
{
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Credentials" accessGroup:nil];
    MKNetworkEngine *myEngine = [[MKNetworkEngine alloc] initWithHostName:@"map.sbasite.com" customHeaderFields:nil];;    
    MKNetworkOperation *op = [myEngine operationWithPath:@"Authentication/"];
    
    [op setUsername:[wrapper objectForKey:(__bridge id)(kSecAttrAccount)] password:[wrapper objectForKey:(__bridge id)(kSecValueData)]];
    
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        [self setupMapView:YES];
        DLog(@"%@", [operation responseString]);
    } onError:^(NSError *error) {
        
        [self setupMapView: NO];
        DLog(@"%@", [error localizedDescription]);
    }];
    [myEngine enqueueOperation:op];
    

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
    SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    viewController.site = graphic;
    
//    [self.navigationController pushViewController:viewController animated:YES];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - AGSIdentifyTaskDelegate methods
//results are returned
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results
{
	
    //clear previous results
    //[self.graphicsLayer removeAllGraphics];
	
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
            if (!self.popoverController.popoverVisible) {
                SBASiteDetailViewController *viewController = [[SBASiteDetailViewController alloc] initWithNibName:@"DetailViewController-iPad" bundle:nil];
                viewController.site = result.feature;
                viewController.contentSizeForViewInPopover = CGSizeMake(320.0, 416.0);
                self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
                self.popoverController.delegate = self;
                CGPoint point = [self.mapView toScreenPoint:self.mappoint];
                [self.popoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 1.0, 1.0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        } else {
			self.infoTemplate = [[SBASiteInfoTemplate alloc] init];
			AGSGraphic *graphic = ((AGSIdentifyResult *)[results objectAtIndex:0]).feature;
			graphic.infoTemplateDelegate = self.infoTemplate;
			[self.mapView showCalloutAtPoint:self.mappoint forGraphic:graphic animated:YES];
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

@end
