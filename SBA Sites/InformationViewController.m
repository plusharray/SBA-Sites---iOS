//
//  InformationViewController.m
//  SBA Site
//
//  Created by Ross Chapman on 11/2/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import "InformationViewController.h"
#import "InformationDetailViewController.h"
#import "InfoViewController.h"
#import "GradientView.h"
#import "ClearLabelsCellView.h"
#import "UserCredentialsViewController.h"

@implementation InformationViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"Info";
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	else if (section == 1) {
		return 3;
	}
	else if (section == 2) {
		return 2;
	}
    else if( section == 3) {
        return 2;
    }
	else {
		return 0;
	}
}

// Customize section header titles
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	
    if (section == 0) {
		return @"Login Information";
	}
	else if (section == 0) {
		return @"Search Instructions";
	}
	else if (section == 1) {
		return @"About";
	}
	else if (section == 2) {
		return @"Support";
	}
	else {
		return nil;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    int section = indexPath.section;
	int row = indexPath.row;
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ClearLabelsCellView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		cell.backgroundView = [[GradientView alloc] init];
    }
	
    if (section == 0) {
		if (row == 0) {
			//- login Credentials
			cell.textLabel.text = @"Credentials";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
		}
    }
	else if (section == 1) {
		if (row == 0) {
			//- Search by Site Name/ID
			cell.textLabel.text = @"Search by Site Name/ID";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
		}
		else if (row == 1) {
			//- Search by Coordinates
			cell.textLabel.text = @"Search by Coordinates";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (row == 2) {
			//- Search by Address
			cell.textLabel.text = @"Search by Address";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if (section == 2) {
		if (row == 0) {
			//- About SBA Sites App -> InfoViewController
			cell.textLabel.text = @"About SBA Communications";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (row == 1) {
			//- App version
			NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			
			cell.textLabel.text = @"App Version";
			cell.detailTextLabel.text = appVersion;
		}
	}
	else if (section == 3) {
		if (row == 0) {
			//- Email support
			cell.textLabel.text = @"Email Support";
			cell.detailTextLabel.text = @"";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			UIImage *cellImage = [UIImage imageNamed:@"18-envelope.png"];
			cell.imageView.image = cellImage;
		}
		else if (row == 1) {
			//- sbasites.com
			cell.textLabel.text = @"Website";
			cell.detailTextLabel.text = @"http://www.sbasite.com";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	int section = indexPath.section;
	int row = indexPath.row;
	
    if (section ==0){
        if(row == 0){
            UserCredentialsViewController *userCredentialsViewController = [[UserCredentialsViewController alloc] initWithNibName:@"UserCredentialsViewController" bundle:nil];
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:userCredentialsViewController animated:YES];
        }
    }
    else if (section == 1) {
		if (row == 0) {
			//- Search by Site Name/ID
			InformationDetailViewController *detailViewController = [[InformationDetailViewController alloc] initWithNibName:@"InformationDetailViewController" bundle:nil];
			detailViewController.instructionsType = kNameID;
			detailViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
		else if (row == 1) {
			//- Search by Coordinates
			InformationDetailViewController *detailViewController = [[InformationDetailViewController alloc] initWithNibName:@"InformationDetailViewController" bundle:nil];
			detailViewController.instructionsType = kCoordinates;
			detailViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
		else if (row == 2) {
			//- Search by Address
			InformationDetailViewController *detailViewController = [[InformationDetailViewController alloc] initWithNibName:@"InformationDetailViewController" bundle:nil];
			detailViewController.instructionsType = kAddress;
			detailViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
			// Pass the selected object to the new view controller.
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	}
	else if (section == 2) {
		if (row == 0) {
			//- About SBA Sites App -> InfoViewController
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				InfoViewController *detailViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController-iPad" bundle:nil];
				detailViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
				// Pass the selected object to the new view controller.
				[self.navigationController pushViewController:detailViewController animated:YES];
			} else {
				InfoViewController *detailViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
				detailViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 465.0);
				// Pass the selected object to the new view controller.
				[self.navigationController pushViewController:detailViewController animated:YES];
			}
		}
	}
	else if (section == 3) {
		if (row == 0) {
			//- Email support
			[self displayComposerSheet];
		}
		else if (row == 1) {
			//- sbasites.com
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sbasite.com"]];
		}
	}
}


//===========================================================
#pragma mark -
#pragma mark MessageUI Methods
#pragma mark -
//===========================================================

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)displayMailComposerSheet
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:@[@"mobilesupport@sbasite.com"]];
	[picker setSubject:@"SBA Sites Support Request"];
	
	picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	picker.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:picker animated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:mobilesupport@sbasite.com&subject=SBA Sites Support Request";
	
	
	NSString *email = [NSString stringWithFormat:@"%@", recipients];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark -
#pragma mark Dismiss Mail view controller

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	//feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//feedbackMsg.text = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			//feedbackMsg.text = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			//feedbackMsg.text = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			//feedbackMsg.text = @"Result: Mail sending failed";
			break;
		default:
			//feedbackMsg.text = @"Result: Mail not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end

