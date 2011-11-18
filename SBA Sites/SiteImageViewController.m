//
//  SiteImageViewController.m
//  SBA Site
//
//  Created by Ross Chapman on 10/14/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import "SiteImageViewController.h"
//#import "GANTracker.h"

@implementation SiteImageViewController
//=========================================================== 
#pragma mark -
#pragma mark Properties
#pragma mark -
//=========================================================== 
@synthesize pathString;
@synthesize imageView;


- (void) viewDidUnload
{
    self.imageView = nil;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imagePath:(NSString *)aPath
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pathString = aPath;
    }
    return self;
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
	UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.pathString]]];
	if (downloadedImage) {
		[self.imageView performSelectorOnMainThread:@selector(setImage:)
										 withObject:downloadedImage
									  waitUntilDone:NO];
	}
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	/*
	NSError *gaError;
	NSString *className = (NSStringFromClass([self class]));
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/%@", className]
										 withError:&gaError]) {
		// Handle error here
	}
	 */
	SEL method = @selector(getImageForPath:);
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:method object:self.pathString];
	[[self retrieverQueue] addOperation:op];
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end
