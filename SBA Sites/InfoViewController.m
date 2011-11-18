//
//  InfoViewController.m
//  SBA Site
//
//  Created by Ross Chapman on 10/21/10.
//  Copyright (c) 2010 Convergint Technologies LLC. All rights reserved.
//

#import "InfoViewController.h"
//#import "GANTracker.h"

@implementation InfoViewController
//=========================================================== 
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
//=========================================================== 
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//=========================================================== 
#pragma mark -
#pragma mark Memory Management
#pragma mark -
//=========================================================== 
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
