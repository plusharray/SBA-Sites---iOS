//
//  SBASiteTableViewController.m
//  SBA Sites
//
//  Created by Ross Chapman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBASiteTableViewController.h"

@implementation SBASiteTableViewController

@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize mapView = _mapView;
@synthesize identifyTask = _identifyTask;
@synthesize identifyParams = _identifyParams;
@synthesize layers = _layers;
@synthesize sites = _sites;

#pragma mark - Accessors

- (NSArray *)sites
{
    if (!_sites) {
        _sites = [NSArray array];
    }
    return _sites;
}

#pragma mark - Get Sites

- (void)getSites
{
    self.identifyParams.layerIds = [self.layers valueForKey:@"layerID"];
    self.identifyParams.geometry = self.mapView.envelope;
	self.identifyParams.tolerance = 1;
	self.identifyParams.size = self.mapView.bounds.size;
	self.identifyParams.mapEnvelope = self.mapView.envelope;
	self.identifyParams.returnGeometry = YES;
	self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
	self.identifyParams.spatialReference = self.mapView.spatialReference;
    
	//execute the task
	[self.identifyTask executeWithParameters:self.identifyParams];
}

#pragma mark - IBActions

- (IBAction)dismissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //create identify task
        self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:DynamicMapServiceURL]];
        self.identifyTask.delegate = self;
        
        //create identify parameters
        self.identifyParams = [[AGSIdentifyParameters alloc] init];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.toolbar.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    AGSIdentifyResult *result = [self.sites objectAtIndex:indexPath.row];
    cell.textLabel.text = [result.feature.attributes valueForKey:@"SiteName"];
    cell.detailTextLabel.text = [result.feature.attributes valueForKey:@"SiteCode"];
    cell.imageView.image = [UIImage imageNamed:[result layerName]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SBASiteSelected object:[self.sites objectAtIndex:indexPath.row]];
    [self dismissSelf:self];
}

#pragma mark - AGSIdentifyTaskDelegate methods
//results are returned
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results
{
	self.sites = results;
    [self.tableView reloadData];
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
