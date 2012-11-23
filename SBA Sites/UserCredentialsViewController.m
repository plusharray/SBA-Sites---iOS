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

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title= @"Login Credentials";
    //get the latest credentials - now you have the set values
    self.username.text = [[PAAuthorizationManager sharedManager] username];
    self.password.text = @"";
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
	} else {
		UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
		[toolbar setItems:@[flexibleSpace, doneButton]];
		self.view.frame = CGRectMake(0, 44, 320, self.view.window.bounds.size.height - 44);
		[self.view addSubview:toolbar];
	}
}

- (void)viewDidUnload {
    [self setUsername:nil];
    [self setPassword:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (self.username.text.length == 0) {
		[self.username becomeFirstResponder];
	} else {
		[self.password becomeFirstResponder];
	}
	
}

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
															[[UIAlertView alertViewWithTitle:@"Successful Login" message:@"Your credentials have been saved and you are now logged in." cancelButtonTitle:@"OK" otherButtonTitles:nil onDismiss:nil onCancel:^{
																[self done:self];
															}] show];
														});
													}
														 onError:^(NSError *error) {
															 dispatch_async(dispatch_get_main_queue(), ^{
																 self.password.text = nil;
																 [[UIAlertView alertViewWithTitle:@"Login Failed" message:@"Please check your credentials and try again."] show];
															 });
														 }];
	
}

- (IBAction)done:(id)sender
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isEqual:self.username]) {
		[self.password becomeFirstResponder];
	} else {
		if (self.username.text && self.username.text.length > 0) {
			[self login:self];
		} else {
			[self.username becomeFirstResponder];
		}
	}
	return YES;
}

@end
