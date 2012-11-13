//
//  UserCredentialsViewController.h
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/25/12.
//
//

#import <UIKit/UIKit.h>

@interface UserCredentialsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

- (IBAction)login:(id)sender;
- (IBAction)done:(id)sender;

@end
