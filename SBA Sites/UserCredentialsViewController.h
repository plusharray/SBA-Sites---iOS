//
//  UserCredentialsViewController.h
//  SBA Sites
//
//  Created by Mahmoud Abouelnasr on 9/25/12.
//
//

#import <UIKit/UIKit.h>

@interface UserCredentialsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

-(IBAction)saveCred:(id)sender;
@end
