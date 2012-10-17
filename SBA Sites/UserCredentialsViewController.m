//
//  UserCredentialsViewController.m
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/25/12.
//
//

#import "UserCredentialsViewController.h"
#import "KeychainItemWrapper.h"

@interface UserCredentialsViewController ()

@end

@implementation UserCredentialsViewController
@synthesize username = _username;
@synthesize password = _password;

-(IBAction)saveCred:(id)sender
{
    [self.view endEditing:YES];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Credentials" accessGroup:nil];

    //if empty set your credentials
    if ( ![_username.text isEqualToString:@""] ) {
        [wrapper setObject:[_username text] forKey:(__bridge id)(kSecAttrAccount)];
    }
    if ( ![_password.text isEqualToString:@""] ) {
        [wrapper setObject:[_password text] forKey:(__bridge id)(kSecValueData)];
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Saved"
												 message:@"Credentials have been saved"
												delegate:self
									   cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
	[av show];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Credentials" accessGroup:nil];

    self.title= @"Login Credentials";
    //get the latest credentials - now you have the set values
    _username.text = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    _password.text = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    
    NSLog(@"username - %@", _username.text); // username - your username here
    NSLog(@"password - %@", _password.text); // password - your password here
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    _password = nil;
    _username = nil;
    [self setUsername:nil];
    [self setPassword:nil];
    [super viewDidUnload];
}
@end
