//
//  LoginViewController.m
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/13/12.
//
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;
@synthesize loginButton;
@synthesize loginIndicator;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (IBAction) login: (id) sender
{
	// TODO: spawn a login thread
	
	loginIndicator.hidden = FALSE;
	[loginIndicator startAnimating];
	
	loginButton.enabled = FALSE;
}

@end