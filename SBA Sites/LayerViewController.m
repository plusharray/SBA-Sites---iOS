//
//  LayerViewController.m
//  SBASite
//
//  Created by Ross Chapman on 9/30/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import "LayerViewController.h"
#import "SBARootViewController.h"
#import "GradientView.h"
#import "ClearLabelsCellView.h"
#import "SBALayer.h"

@implementation LayerViewController

@synthesize mapTypeSegmentedControl = _mapSegmentedControl;
@synthesize tableView = _tableView;
@synthesize layerArray = _layerArray;
@synthesize selectedMapType = _selectedMapType;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:self.selectedMapType];
	UIImage *normalImage = [UIImage imageNamed:@"button-gray.png"];
    normalImage = [normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 53.0, 0.0, 53.0)];
	[self.doneButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	
	UIImage *highlightedImage = [UIImage imageNamed:@"button-gray-pressed.png"];
    highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 53.0, 0.0, 53.0)];
	[self.doneButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			return YES;
		} else {
			return NO;
		}
	}
}

- (IBAction)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)mapType:(UISegmentedControl *)segmentPick
{
    self.selectedMapType = segmentPick.selectedSegmentIndex;
    [[NSNotificationCenter defaultCenter] postNotificationName:SBAMapTypeChanged object:@(self.selectedMapType)];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.layerArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.backgroundView = [[GradientView alloc] init];
    }
	SBALayer *layer = (SBALayer *)[self.layerArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = layer.name;
    if (layer.visible) {
        cell.imageView.image = layer.image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"Grey.png"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    SBALayer *layer = (SBALayer *)[self.layerArray objectAtIndex:indexPath.row];
    layer.visible = !layer.visible;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [[NSNotificationCenter defaultCenter] postNotificationName:SBALayerSelected object:layer];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [self setDoneButton:nil];
    [super viewDidUnload];
}
@end

