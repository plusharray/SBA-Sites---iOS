//
//  SiteDetailViewController.m
//  SBASites
//
//  Created by Ross Chapman on 9/14/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import "DetailViewController.h"
#import "SiteImageViewController.h"

@implementation DetailViewController

#pragma mark -
#pragma mark Properties
@synthesize retrieverQueue = _retrieverQueue;
@synthesize site = _site;
@synthesize imageButton = _imageButton;
@synthesize siteImage = _siteImage;
@synthesize siteAddress1 = _siteAddress1;
@synthesize siteAddress2 = _siteAddress2;
@synthesize siteBTA = _siteBTA;
@synthesize siteCoordinates = _siteCoordinates;
@synthesize siteID = _siteID;
@synthesize siteLayer = _siteLayer;
@synthesize siteMTA = _siteMTA;
@synthesize siteName = _siteName;
@synthesize siteStatus = _siteStatus;
@synthesize structureAGL = _structureAGL;
@synthesize structureHeight = _structureHeight;
@synthesize structureType = _structureType;

- (void) viewDidUnload {
    self.imageButton = nil;
    self.siteImage = nil;
    self.siteAddress1 = nil;
    self.siteAddress2 = nil;
    self.siteBTA = nil;
    self.siteCoordinates = nil;
    self.siteID = nil;
    self.siteLayer = nil;
    self.siteMTA = nil;
    self.siteName = nil;
    self.siteStatus = nil;
    self.structureAGL = nil;
    self.structureHeight = nil;
    self.structureType = nil;
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

//=========================================================== 
#pragma mark -
#pragma mark View lifecycle
#pragma mark -
//=========================================================== 

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [self.site.attributes valueForKey:@"SiteName"];
	self.siteName.text = [self.site.attributes valueForKey:@"SiteName"];
	self.siteID.text = [self.site.attributes valueForKey:@"SiteCode"];
	self.siteAddress1.text = [self.site.attributes valueForKey:@"Address1"];
	self.siteAddress2.text = [NSString stringWithFormat:@"%@, %@ %@", [self.site.attributes valueForKey:@"City"], [self.site.attributes valueForKey:@"State"], [self.site.attributes valueForKey:@"Zip"]];
	//self.siteLayer.text = [self.site layerName];
	self.siteStatus.text = [self.site.attributes valueForKey:@"Status"];
	self.siteCoordinates.text = [NSString stringWithFormat:@"%@, %@", [self.site.attributes valueForKey:@"Latitude"], [self.site.attributes valueForKey:@"Longitude"]];
    self.structureType.text = [self.site.attributes valueForKey:@"Type"];
	self.structureHeight.text = [self.site.attributes valueForKey:@"Height"];
	self.structureAGL.text = [self.site.attributes valueForKey:@"AGL"];
	self.siteMTA.text = [self.site.attributes valueForKey:@"MtaName"];
	self.siteBTA.text = [self.site.attributes valueForKey:@"BtaName"];
	
	NSString *pathString = [NSString stringWithFormat:@"http://map.sbasite.com/Mobile/GetImage?SiteCode=%@&width=600&height=600", [self.site.attributes valueForKey:@"SiteCode"]];
	SEL method = @selector(getImageForPath:);
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:method object:pathString];
	[[self retrieverQueue] addOperation:op];
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

- (IBAction)dismissAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

//=========================================================== 
#pragma mark -
#pragma mark Custom Cell Methods
#pragma mark -
//=========================================================== 
- (IBAction)presentModalImage:(id)sender
{
	NSString *pathString = [NSString stringWithFormat:@"http://map.sbasite.com/Mobile/GetImage?SiteCode=%@&width=600&height=600", [self.site.attributes valueForKey:@"SiteCode"]];
	//self.siteImageController.imageView.image = self.siteImage.image;
	SiteImageViewController *imageController;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		imageController = [[SiteImageViewController alloc] initWithNibName:@"SiteImageViewController-iPad" bundle:nil imagePath:pathString];
		//[imageController setPathString:pathString];
	} else {
		imageController = [[SiteImageViewController alloc] initWithNibName:@"SiteImageViewController" bundle:nil imagePath:pathString];
		//[imageController setPathString:pathString];
	}

	imageController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imageController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[self presentModalViewController:imageController animated:YES];
}

//=========================================================== 
#pragma mark -
#pragma mark MessageUI Methods
#pragma mark -
//=========================================================== 

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (IBAction)displayMailComposerSheet:(id)sender
{
	/*
	NSError *gaError;
	if (![[GANTracker sharedTracker] trackEvent:@"Email Event"
										 action:@"Display email composer"
										  label:@""
										  value:-1
									  withError:&gaError]) {
		// Handle error here
	}
	*/
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
	
	//[picker setToRecipients:[NSArray arrayWithObject:[self.site email]]];
	//[picker setCcRecipients:[NSArray arrayWithObjects:@"siteinquiry@sbasite.com", nil]];
	//[picker setSubject:[NSString stringWithFormat:@"%@ Site Inquiry", [self.site siteName]]];
	
	// Fill out the email body text
	[picker setMessageBody:[NSString stringWithFormat:@"%@", self.site] isHTML:NO];
	picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	picker.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:picker animated:YES];
}

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	//NSLog(@"Launch Mail on device");
	//NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=%@ Site Inquiry", [self.site email], [self.site siteName]];
	//NSString *body = [NSString stringWithFormat:@"%@", self.site];
	
	
	//NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	//email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
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
	/*
			  NSError *gaError;
			  if (![[GANTracker sharedTracker] trackEvent:@"Email Event"
												   action:@"Did Finish"
													label:feedbackMsg
													value:-1
												withError:&gaError]) {
				  // Handle error here
			  }
	 */
	[self dismissModalViewControllerAnimated:YES];
}

@end

