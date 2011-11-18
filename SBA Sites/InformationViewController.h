//
//  InformationViewController.h
//  SBA Site
//
//  Created by Ross Chapman on 11/2/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface InformationViewController : UITableViewController <MFMailComposeViewControllerDelegate>

- (void)displayMailComposerSheet;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;

@end
