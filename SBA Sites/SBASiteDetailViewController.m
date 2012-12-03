//
//  SiteDetailViewController.m
//  SBASites
//
//  Created by Ross Chapman on 9/14/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import "SBASiteDetailViewController.h"
#import "SiteImageViewController.h"
#import "SBARootViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"

@implementation SBASiteDetailViewController

- (void) viewDidUnload {
	[self setBtaLabel:nil];
	[self setMtaLabel:nil];
	[self setElevationLabel:nil];
	[self setHeightLabel:nil];
	[self setTypeLabel:nil];
	[self setCoordinatesLabel:nil];
	[self setStatusLabel:nil];
	[self setPageControl:nil];
    [self setSwipeView:nil];
	[self setScrollView:nil];
    self.imageButton = nil;
    self.siteImage = nil;
    self.siteAddress1 = nil;
    self.siteAddress2 = nil;
    self.siteBTA = nil;
    self.siteCoordinates = nil;
    self.siteID = nil;
    self.siteMTA = nil;
    self.siteName = nil;
    self.siteStatus = nil;
    self.structureAGL = nil;
    self.structureHeight = nil;
    self.structureType = nil;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey-background.png"]]];
	[self.scrollView setContentSize:CGSizeMake(320, 404)];
	if ([self.site.attributes valueForKey:@"SiteName"]) {
		self.title = [self.site.attributes valueForKey:@"SiteName"];
		self.siteName.text = [self.site.attributes valueForKey:@"SiteName"];
		self.siteID.text = [self.site.attributes valueForKey:@"SiteCode"];
		self.siteAddress1.text = [self.site.attributes valueForKey:@"Address1"];
		self.siteAddress2.text = [NSString stringWithFormat:@"%@, %@ %@", [self.site.attributes valueForKey:@"City"], [self.site.attributes valueForKey:@"State"], [self.site.attributes valueForKey:@"Zip"]];
		self.statusLabel.text = @"Status:";
		self.siteStatus.text = [self.site.attributes valueForKey:@"Status"];
		self.siteCoordinates.text = [NSString stringWithFormat:@"%@, %@", [self.site.attributes valueForKey:@"Latitude"], [self.site.attributes valueForKey:@"Longitude"]];
		self.structureType.text = [self.site.attributes valueForKey:@"Type"];
		self.heightLabel.text = @"Height(ft):";
		self.structureHeight.text = [self.site.attributes valueForKey:@"Height"];
		self.elevationLabel.text = @"Grd Elev(ft):";
		self.structureAGL.text = [self.site.attributes valueForKey:@"AGL"];
		self.mtaLabel.text = @"MTA:";
		self.siteMTA.text = [self.site.attributes valueForKey:@"MtaName"];
		self.btaLabel.text = @"FCC Reg. #:";
		self.siteBTA.text = [self.site.attributes valueForKey:@"BtaName"];
		
		NSString *pathString = [NSString stringWithFormat:@"http://map.sbasite.com/Mobile/GetImage?SiteCode=%@&width=600&height=600", [self.site.attributes valueForKey:@"SiteCode"]];
		SEL method = @selector(getImageForPath:);
		NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:method object:pathString];
		[[self retrieverQueue] addOperation:op];
	} else {
		self.title = [self.site.attributes valueForKey:@"identifier"];
		self.siteName.text = [self.site.attributes valueForKey:@"company"];
		self.siteID.text = [self.site.attributes valueForKey:@"identifier"];
		self.siteAddress1.text = [self.site.attributes valueForKey:@"contactaddress_1"];
		self.siteAddress2.text = [NSString stringWithFormat:@"%@, %@ %@", [self.site.attributes valueForKey:@"city"], [self.site.attributes valueForKey:@"state"], [self.site.attributes valueForKey:@"zip"]];
		self.statusLabel.text = @"";
		self.siteStatus.text = @"";
		self.siteCoordinates.text = [NSString stringWithFormat:@"%@, %@", [self.site.attributes valueForKey:@"latitude"], [self.site.attributes valueForKey:@"longitude"]];
		self.structureType.text = [self.site.attributes valueForKey:@"Type"];
		self.heightLabel.text = @"Height(meters):";
		self.structureHeight.text = [self.site.attributes valueForKey:@"Grnd_meters"];
		self.elevationLabel.text = @"Grd Elev(meters):";
		self.structureAGL.text = [self.site.attributes valueForKey:@"AGL_meters"];
		self.mtaLabel.text = @"Proximity:";
		self.siteMTA.text = [self.site.attributes valueForKey:@"proximity"];
		self.btaLabel.text = @"FCC Reg. #:";
		self.siteBTA.text = [self.site.attributes valueForKey:@"fcc_reg_num"];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
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

- (NSOperationQueue *)retrieverQueue {
	if(nil == _retrieverQueue) {
		_retrieverQueue = [[NSOperationQueue alloc] init];
		_retrieverQueue.maxConcurrentOperationCount = 1;
	}
	return _retrieverQueue;
}

- (void)getImageForPath:(NSString *)imagePath
{
	UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
	if ((downloadedImage.size.width > 1.0) || (downloadedImage.size.height > 1.0)) {
		[self performSelectorOnMainThread:@selector(showImageViewWithImage:)
							   withObject:downloadedImage
							waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(hideImageView)
							   withObject:nil
							waitUntilDone:NO];
	}
}

- (void)showImageViewWithImage:(UIImage *)anImage
{
	self.siteImage.image = anImage;
	[self.siteImage setHidden:NO];
	[self.imageButton setHidden:NO];
	self.siteName.frame = CGRectMake(108.0, 15.0, 300.0, 15.0);
	self.siteID.frame = CGRectMake(108.0, 35.0, 300.0, 15.0);
	self.siteAddress1.frame = CGRectMake(108.0, 55.0, 300.0, 15.0);
	self.siteAddress2.frame = CGRectMake(108.0, 75.0, 300.0, 15.0);

}

- (void)hideImageView
{
	[self.siteImage setHidden:YES];
	[self.imageButton setHidden:YES];
	/*
	 self.siteName.frame = CGRectMake(10.0, 15.0, 300.0, 15.0);
	 self.siteID.frame = CGRectMake(10.0, 35.0, 300.0, 15.0);
	 self.siteAddress1.frame = CGRectMake(10.0, 55.0, 300.0, 15.0);
	 self.siteAddress2.frame = CGRectMake(10.0, 75.0, 300.0, 15.0);
	 */
}

- (IBAction)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pageControlTapped:(id)sender
{
    //update swipe view page
    [self.swipeView scrollToPage:self.pageControl.currentPage duration:0.4];
}

- (IBAction)presentModalImage:(id)sender
{
	NSString *pathString = [NSString stringWithFormat:@"http://map.sbasite.com/Mobile/GetImage?SiteCode=%@&width=600&height=600", [self.site.attributes valueForKey:@"SiteCode"]];
	SiteImageViewController *imageController;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		imageController = [[SiteImageViewController alloc] initWithNibName:@"SiteImageViewController-iPad" bundle:nil imagePath:pathString];
	} else {
		imageController = [[SiteImageViewController alloc] initWithNibName:@"SiteImageViewController" bundle:nil imagePath:pathString];
	}
	
	imageController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imageController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[self presentModalViewController:imageController animated:YES];
}

- (void)displayMailComposer
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

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (IBAction)displayContactPrompt:(id)sender
{
	if ([self.site.attributes valueForKey:@"SiteName"]) {
		[self displayMailComposer];
	} else {
		DismissBlock dismissBlock = ^(int buttonIndex) {
			if (buttonIndex == 0) {
				[self displayMailComposer];
			} else {
				NSString *phoneNumber = [@"tel://" stringByAppendingString:[self.site.attributes valueForKey:@"contactphone"]];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
			}
		};
		[UIActionSheet actionSheetWithTitle:@"Contact"
									message:@"Email or Call"
									buttons:@[@"Email", @"Call"]
								 showInView:self.view
								  onDismiss:dismissBlock
								   onCancel:nil];
	}
}

-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	NSString *recipients = nil;
	NSString *subject = nil;
	if ([self.site.attributes valueForKey:@"SiteName"]) {
		recipients = [self.site.attributes valueForKey:@"Email"];
		subject = [NSString stringWithFormat:@"%@ Site Inquiry", [self.site.attributes valueForKey:@"SiteName"]];
	} else {
		recipients = [self.site.attributes valueForKey:@"contactemail"];
		if ([recipients isEqualToString:@"Null"]) {
			[UIAlertView alertViewWithTitle:@"Error" message:@"There is no contact email address available for this site"];
			return;
		}
		subject = [NSString stringWithFormat:@"%@ Site Inquiry", [self.site.attributes valueForKey:@"identifier"]];
	}
	[picker setToRecipients:@[recipients]];
	[picker setCcRecipients:@[@"siteinquiry@sbasite.com"]];
	[picker setSubject:subject];
	
	// Fill out the email body text
    NSString *tempBody = [[NSString stringWithFormat:@"%@", self.site.attributes] stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *body = [tempBody stringByReplacingOccurrencesOfString:@"}" withString:@""];
	[picker setMessageBody:[NSString stringWithFormat:@"%@", body] isHTML:NO];
	picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	picker.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:picker animated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	//NSLog(@"Launch Mail on device");
	NSString *recipient = nil;
	NSString *subject = nil;
	if ([self.site.attributes valueForKey:@"SiteName"]) {
		recipient = [self.site.attributes valueForKey:@"Email"];
		subject = [NSString stringWithFormat:@"%@ Site Inquiry", [self.site.attributes valueForKey:@"SiteName"]];
	} else {
		recipient = [self.site.attributes valueForKey:@"contactemail"];
		if ([recipient isEqualToString:@"Null"]) {
			[UIAlertView alertViewWithTitle:@"Error" message:@"There is no contact email address available for this site"];
			return;
		}
		subject = [NSString stringWithFormat:@"%@ Site Inquiry", [self.site.attributes valueForKey:@"identifier"]];
	}
	NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=%@", recipient, subject];
	NSString *body = [NSString stringWithFormat:@"%@", self.site.attributes];
	
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)showDrivingDirections:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
	[self.delegate performSelector:@selector(requestRoute:) withObject:self.site afterDelay:0.3];
}

#pragma mark -
#pragma mark Dismiss Mail view controller

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	NSString *feedbackMsg;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			feedbackMsg = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			feedbackMsg = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			feedbackMsg = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			feedbackMsg = @"Result: Mail sending failed";
			break;
		default:
			feedbackMsg = @"Result: Mail not sent";
			break;
	}
	NSLog(@"Mail Composer: %@", feedbackMsg);
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.images count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = (UIImageView *)view;
    
    //create or reuse view
    if (view == nil)
    {
		
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 90.0f, 90.0f)];
        view = imageView;
    }
    
    //configure view
    [imageView setImage:[self.images objectAtIndex:index]];
    
    //return view
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    //update page control page
    self.pageControl.currentPage = swipeView.currentPage;
}

#pragma mark - SwipeViewDelegate

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Selected item at index %i", index);
}

@end

