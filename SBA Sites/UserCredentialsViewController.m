//
//  UserCredentialsViewController.m
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/25/12.
//
//

#import "UserCredentialsViewController.h"
#import "PAAuthorizationManager.h"

@interface UserCredentialsViewController ()

@end

@implementation UserCredentialsViewController
@synthesize username = _username;
@synthesize password = _password;

-(IBAction)login:(id)sender
{
    [self.view endEditing:YES];
	
    //if empty set your credentials
    if (!self.username.text || !self.password.text)
		return;
	
	[[PAAuthorizationManager sharedManager] authenticateWithUser:self.username.text
													 andPassword:self.password.text
													onCompletion:^(MKNetworkOperation *operation) {
														dispatch_async(dispatch_get_main_queue(), ^{
															[[UIAlertView alertViewWithTitle:@"Successful Login" message:@"Your credentials have been saved and you are now logged in."] show];
														});
													}
														 onError:^(NSError *error) {
															 dispatch_async(dispatch_get_main_queue(), ^{
																 self.password.text = nil;
																 [[UIAlertView alertViewWithTitle:@"Login Failed" message:@"Please check your credentials and try again."] show];
															 });
														 }];
	
}

- (void)viewDidLoad
{
    self.title= @"Login Credentials";
    //get the latest credentials - now you have the set values
    self.username.text = [[PAAuthorizationManager sharedManager] username];
    self.password.text = @"";
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [self setUsername:nil];
    [self setPassword:nil];
    [super viewDidUnload];
}
@end
