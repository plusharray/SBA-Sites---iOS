//
//  SBARouteViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/1/12.
//
//

#import "SBARouteViewController.h"
#import "SBAMapViewController.h"
#import <CoreLocation/CoreLocation.h>

#define kRouteTaskUrl			@"http://sampleserver3.arcgisonline.com/ArcGIS/rest/services/Network/USA/NAServer/Route"

@interface SBARouteViewController ()

@end

@implementation SBARouteViewController

@synthesize mapViewController = _mapViewController;
@synthesize startingAddressTextField = _startingAddressTextField;
@synthesize destinationAddressTextField = _destinationAddressTextField;
@synthesize routeTask = _routeTask;
@synthesize routeTaskParams = _routeTaskParams;
@synthesize routeResult = _routeResult;
@synthesize routeStops = _routeStops;
@synthesize startingGraphic = _startingGraphic;
@synthesize destinationGraphic = _destinationGraphic;


- (id)initWithSBAMapViewController:(SBAMapViewController *)mapViewController
{
	self = [self initWithNibName:@"SBARouteViewController" bundle:nil];
    if (self) {
        _mapViewController = mapViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[self.navigationController setToolbarHidden:YES animated:NO];
	
	
	// Setup the route task
	NSURL *routeTaskUrl = [NSURL URLWithString:kRouteTaskUrl];
	self.routeTask = [AGSRouteTask routeTaskWithURL:routeTaskUrl];
    
    // assign delegate to this view controller
	self.routeTask.delegate = self;
	
	// kick off asynchronous method to retrieve default parameters
	// for the route task
	[self.routeTask retrieveDefaultRouteTaskParameters];
	
	// Setup textfields
	self.startingAddressTextField.placeholder = @"Start: Current Location";
	self.destinationAddressTextField.placeholder = @"Please provide destination";
	
}

- (void)viewDidUnload {
	[self setStartingAddressTextField:nil];
	[self setDestinationAddressTextField:nil];
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	CGRect rect = CGRectMake(0, 78, self.view.bounds.size.width, self.view.bounds.size.height - 78);
	[self.mapViewController.mapView setFrame:rect];
	if (![self.view.subviews containsObject:self.mapViewController.mapView]) {
		[self.view addSubview:self.mapViewController.mapView];
	}
}

#pragma mark - AddressBook

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
        
		
	}
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isEqual:self.startingAddressTextField]) {
		
		// Create the starting graphic here
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		[geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
			CLPlacemark *placemark = [placemarks lastObject];
			if (placemark) {
				AGSPoint *point = [[AGSPoint alloc] initWithX:placemark.location.coordinate.longitude y:placemark.location.coordinate.latitude spatialReference:self.mapViewController.mapView.spatialReference];
				AGSStopGraphic *graphic = [[AGSStopGraphic alloc] initWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
				self.startingGraphic = graphic;
			} else {
				self.startingGraphic = nil;
			}
			
		}];
		[self.destinationAddressTextField becomeFirstResponder];
	} else {
		// Create the destination graphic here
		CLGeocoder *geocoder = [[CLGeocoder alloc] init];
		[geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
			CLPlacemark *placemark = [placemarks lastObject];
			if (placemark) {
				AGSPoint *point = [[AGSPoint alloc] initWithX:placemark.location.coordinate.longitude y:placemark.location.coordinate.latitude spatialReference:self.mapViewController.mapView.spatialReference];
				AGSStopGraphic *graphic = [[AGSStopGraphic alloc] initWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
				self.destinationGraphic = graphic;
				
				if (self.startingGraphic) {
					[self requestRoute];
				}
				
			} else {
				self.destinationGraphic = nil;
			}
			
		}];
		[textField resignFirstResponder];
	}
	return YES;
}

#pragma mark AGSRouteTaskDelegate

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
    //[self updateDirectionsLabel:@"Routing completed"];
	
	// we know that we are only dealing with 1 route...
	self.routeResult = [routeTaskResult.routeResults lastObject];
	if (self.routeResult) {
		// symbolize the returned route graphic
		self.routeResult.routeGraphic.symbol = [self routeSymbol];
        
        // add the route graphic to the graphic's layer
		[self.mapViewController.graphicsLayer addGraphic:self.routeResult.routeGraphic];
		
		// enable the next button so the user can traverse directions
		//self.nextBtn.enabled = YES;
		
        // remove the stop graphics from the graphics layer
        // careful not to attempt to mutate the graphics array while
        // it is being enumerated
		NSMutableArray *graphics = [self.mapViewController.graphicsLayer.graphics mutableCopy];
		for (AGSGraphic *g in graphics) {
			if ([g isKindOfClass:[AGSStopGraphic class]]) {
				[self.mapViewController.graphicsLayer removeGraphic:g];
			}
		}
		
        // add the returned stops...it's possible these came back in a different order
        // because we specified findBestSequence
		for (AGSStopGraphic *sg in self.routeResult.stopGraphics) {
            
            // get the sequence from the attribetus
			NSInteger sequence = [[sg.attributes valueForKey:@"Sequence"] integerValue];
            
            // create a composite symbol using the sequence number
			sg.symbol = [self stopSymbolWithNumber:sequence];
            
            // add the graphic
			[self.mapViewController.graphicsLayer addGraphic:sg];
		}
        
        // tell the graphics layer to redraw
		[self.mapViewController.graphicsLayer dataChanged];
	}
}

//
// solve failed
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
	//[self updateDirectionsLabel:@"Routing failed"];
	
	// the solve route failed...
	// let the user know
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Solve Route Failed"
												 message:[NSString stringWithFormat:@"Error: %@", error]
												delegate:nil
									   cancelButtonTitle:@"Ok"
									   otherButtonTitles:nil];
	[av show];
}

#pragma mark UIAlertViewDelegate

//
// If the user clicks 'Retry' then we should attempt to retrieve the defaults again
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// see which button was clicked, Ok or Retry
	// Ok		index 0
	// Retry	index 1
	switch (buttonIndex) {
		case 1:  // Retry
			[self.routeTask retrieveDefaultRouteTaskParameters];
		default:
			break;
	}
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

//
// perform the route task's solve operation
//
- (IBAction)requestRoute {
	
    // update our banner
	//[self updateDirectionsLabel:@"Routing..."];
	
	
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
	self.routeTaskParams.preserveLastStop = NO;
	
	// since we used "findBestSequence" we need to
	// get the newly reordered stops
	self.routeTaskParams.returnStopGraphics = YES;
	
	// ensure the graphics are returned in our map's spatial reference
	self.routeTaskParams.outSpatialReference = self.mapViewController.mapView.spatialReference;
	
	// let's ignore invalid locations
	self.routeTaskParams.ignoreInvalidLocations = YES;
	
	// you can also set additional properties here that should
	// be considered during analysis.
	// See the conceptual help for Routing task.
	
	// execute the route task
	[self.routeTask solveWithParameters:self.routeTaskParams];
}


@end
