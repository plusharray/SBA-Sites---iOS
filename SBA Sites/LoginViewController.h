//
//  LoginViewController.h
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/13/12.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIActivityIndicatorView *loginIndicator;
}

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIActivityIndicatorView *loginIndicator;

- (IBAction) login: (id) sender;

@end