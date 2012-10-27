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

@implementation SBASiteDetailViewController

@synthesize site = _site;
@synthesize images = _images;
@synthesize scrollView = _scrollView;
@synthesize swipeView = _swipeView;
@synthesize imageButton = _imageButton;
@synthesize siteImage = _siteImage;
@synthesize siteAddress1 = _siteAddress1;
@synthesize siteAddress2 = _siteAddress2;
@synthesize siteBTA = _siteBTA;
@synthesize siteCoordinates = _siteCoordinates;
@synthesize siteID = _siteID;
@synthesize siteMTA = _siteMTA;
@synthesize siteName = _siteName;
@synthesize siteStatus = _siteStatus;
@synthesize structureAGL = _structureAGL;
@synthesize structureHeight = _structureHeight;
@synthesize structureType = _structureType;
@synthesize pageControl = _pageControl;


- (void) viewDidUnload {
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
	//[self.scrollView setContentSize:CGSizeMake(320, 634)];
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
	
//	NSString *pathString = [NSString stringWithFormat:@"http://map.sbasite.com/Mobile/GetImage?SiteCode=%@&width=600&height=600", [self.site.attributes valueForKey:@"SiteCode"]];
//	SEL method = @selector(getImageForPath:);
//	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:method object:pathString];
//	[[self retrieverQueue] addOperation:op];
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

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (IBAction)displayMailComposerSheet:(id)sender
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
	
	[picker setToRecipients:@[[self.site.attributes valueForKey:@"Email"]]];
	[picker setCcRecipients:@[@"siteinquiry@sbasite.com"]];
	[picker setSubject:[NSString stringWithFormat:@"%@ Site Inquiry", [self.site.attributes valueForKey:@"SiteName"]]];
	
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
	NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=%@ Site Inquiry", [self.site.attributes valueForKey:@"Email"], [self.site.attributes valueForKey:@"SiteName"]];
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

