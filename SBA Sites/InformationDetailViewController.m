//
//  InformationDetailViewController.m
//  SBA Site
//
//  Created by Ross Chapman on 11/2/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import "InformationDetailViewController.h"
#import "GradientView.h"
#import "ClearLabelsCellView.h"

@implementation InformationDetailViewController

@synthesize instructionsType = _instructionsType;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
	switch (self.instructionsType) {
		case kNameID:
			self.title = @"Search by Site Name/ID";
			break;
		case kCoordinates:
			self.title = @"Search by Coordinates";
			break;
		case kAddress:
			self.title = @"Search by Address";
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (self.instructionsType) {
		case kNameID:
			return 2;
			break;
		case kCoordinates:
			return 2;
			break;
		case kAddress:
			return 5;
			break;
		default:
			return 0;
			break;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (self.instructionsType) {
		case kNameID:			
			if (section == 0) {
				return 2;
			}
			else if (section == 1) {
				return 2;
			}
			else {
				return 0;
			}
			break;
		case kCoordinates:
			if (section == 0) {
				return 2;
			}
			else if (section == 1) {
				return 2;
			}
			else {
				return 0;
			}
			break;
		case kAddress:
			if (section == 0) {
				return 1;
			}
			else if (section == 1) {
				return 2;
			}
			else if (section == 2) {
				return 1;
			}
			else if (section == 3) {
				return 1;
			}
			else if (section == 4) {
				return 2;
			}
			else {
				return 0;
			}
			break;
		default:
			return 0;
			break;
	}
}


// Customize section header titles
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	switch (self.instructionsType) {
		case kNameID:
			if (section == 0) {
				return @"Site Name Examples";
			}
			else if (section == 1) {
				return @"Site ID Examples";
			}
			else {
				return nil;
			}
			break;
		case kCoordinates:
			if (section == 0) {
				return @"Coordinate Pair Examples";
			}
			else if (section == 1) {
				return @"Longitude Without \'-\' Accepted";
			}
			else {
				return nil;
			}
			break;
		case kAddress:
			if (section == 0) {
				return @"Address Search with Full Address";
			}
			else if (section == 1) {
				return @"City, State/Province";
			}
			else if (section == 2) {
				return @"State/Province";
			}
			else if (section == 3) {
				return @"Zip Code";
			}
			else if (section == 4) {
				return @"Major City";
			}
			else {
				return nil;
			}
			break;
		default:
			return 0;
			break;
	}
	
	
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    int section = indexPath.section;
	int row = indexPath.row;
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.backgroundView = [[GradientView alloc] init];
    }
    
    switch (self.instructionsType) {
		case kNameID:
			if (section == 0) {
				if (row == 0) {
					cell.textLabel.text = @"ex:\"Shadow\"";
					cell.detailTextLabel.text = @"Partial Site Name Search";
				}
				else {
					cell.textLabel.text = @"ex:\"Hackberry\"";
					cell.detailTextLabel.text = @"Full Site Name Search";
				}
			}
			else if (section == 1) {
				if (row == 0) {
					cell.textLabel.text = @"ex:\"FL\"";
					cell.detailTextLabel.text= @"Site ID Partial Search";
				}
				else if (row == 1) {
					cell.textLabel.text = @"ex:\"FL98463-L\"";
					cell.detailTextLabel.text = @"Site ID Exact Search";
				}
			}
			break;
		case kCoordinates:
			if (row == 0) {
				cell.textLabel.text = @"ex:\"53.5,-117.2\"";
				cell.detailTextLabel.text = @"Lat/Long delimited by comma";
				
			}
			else if (row == 1) {
				cell.textLabel.text = @"ex:\"53.5,117.2\"";
				cell.detailTextLabel.text = @"\'-\' symbol is not required for Long";
			}
			break;
		case kAddress:
			if (section == 0) {
				if (row == 0) {
					cell.detailTextLabel.text = @"Address Exact Search";
					cell.textLabel.text = @"ex:\"1430 Beechwood Cir Lawrenceville, GA 30046\"";
				}
			}
			else if (section == 1) {
				if (row == 0) {
					cell.detailTextLabel.text = @"Address Partial Search";
					cell.textLabel.text = @"ex:\"Boca Raton, FL\"";
				}
				else if (row == 1) {
					cell.detailTextLabel.text = @"Address Partial Search";
					cell.textLabel.text = @"ex:\"Lawrenceville, GA\"";
				}
			}
			else if (section == 2) {
				if (row == 0) {
					cell.detailTextLabel.text = @"Address Partial Search";
					cell.textLabel.text = @"ex:\"California\"";
				}
			}
			else if (section == 3) {
				cell.detailTextLabel.text = @"Address Partial Search";
				cell.textLabel.text = @"ex:\"33487\"";
			}
			else if (section == 4) {
				if (row == 0) {
					cell.detailTextLabel.text = @"Address Partial Search";
					cell.textLabel.text = @"ex:\"Miami\"";
				}
				else if (row == 1) {
					cell.detailTextLabel.text = @"Address Partial Search";
					cell.textLabel.text = @"ex:\"Vancouver\"";
				}
			}
			break;
		default:
			break;
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

