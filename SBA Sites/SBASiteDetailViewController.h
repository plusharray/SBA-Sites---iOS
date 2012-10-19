//
//  DetailViewController.h
//  SBASite
//
//  Created by Ross Chapman on 9/29/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DetailViewController : UIViewController <MFMailComposeViewControllerDelegate>

#pragma mark -
#pragma mark Properties
@property (nonatomic, strong) NSOperationQueue* retrieverQueue;
@property (nonatomic, strong) AGSGraphic* site;
@property (nonatomic, strong) IBOutlet UIButton* imageButton;
@property (nonatomic, strong) IBOutlet UIImageView* siteImage;
@property (nonatomic, strong) IBOutlet UILabel* siteAddress1;
@property (nonatomic, strong) IBOutlet UILabel* siteAddress2;
@property (nonatomic, strong) IBOutlet UILabel* siteBTA;
@property (nonatomic, strong) IBOutlet UILabel* siteCoordinates;
@property (nonatomic, strong) IBOutlet UILabel* siteID;
@property (nonatomic, strong) IBOutlet UILabel* siteLayer;
@property (nonatomic, strong) IBOutlet UILabel* siteMTA;
@property (nonatomic, strong) IBOutlet UILabel* siteName;
@property (nonatomic, strong) IBOutlet UILabel* siteStatus;
@property (nonatomic, strong) IBOutlet UILabel* structureAGL;
@property (nonatomic, strong) IBOutlet UILabel* structureHeight;
@property (nonatomic, strong) IBOutlet UILabel* structureType;

- (NSOperationQueue *)retrieverQueue;

- (void)getImageForPath:(NSString *)imgPath;
- (void)showImageViewWithImage:(UIImage *)anImage;
- (void)hideImageView;

- (IBAction)presentModalImage:(id)sender;
- (IBAction)dismissAction:(id)sender;
- (IBAction)displayMailComposerSheet:(id)sender;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;

@end
