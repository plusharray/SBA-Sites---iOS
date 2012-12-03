//
//  DetailViewController.h
//  SBASite
//
//  Created by Ross Chapman on 9/29/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SwipeView.h"

@protocol SBARouteRequestDelegate;

@interface SBASiteDetailViewController : UIViewController <MFMailComposeViewControllerDelegate, SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) AGSGraphic* site;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *images;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) IBOutlet UIButton* imageButton;
@property (nonatomic, strong) IBOutlet UIImageView* siteImage;
@property (nonatomic, strong) IBOutlet UILabel* siteAddress1;
@property (nonatomic, strong) IBOutlet UILabel* siteAddress2;
@property (nonatomic, strong) IBOutlet UILabel* siteBTA;
@property (nonatomic, strong) IBOutlet UILabel* siteCoordinates;
@property (nonatomic, strong) IBOutlet UILabel* siteID;
@property (nonatomic, strong) IBOutlet UILabel* siteMTA;
@property (nonatomic, strong) IBOutlet UILabel* siteName;
@property (nonatomic, strong) IBOutlet UILabel* siteStatus;
@property (nonatomic, strong) IBOutlet UILabel* structureAGL;
@property (nonatomic, strong) IBOutlet UILabel* structureHeight;
@property (nonatomic, strong) IBOutlet UILabel* structureType;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *coordinatesLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) IBOutlet UILabel *elevationLabel;
@property (strong, nonatomic) IBOutlet UILabel *mtaLabel;
@property (strong, nonatomic) IBOutlet UILabel *btaLabel;

@property (nonatomic, strong) NSOperationQueue* retrieverQueue;


- (IBAction)pageControlTapped:(id)sender;
- (IBAction)presentModalImage:(id)sender;
- (IBAction)dismissAction:(id)sender;
- (IBAction)displayContactPrompt:(id)sender;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
- (IBAction)showDrivingDirections:(id)sender;

@end

@protocol SBARouteRequestDelegate <NSObject>

- (void)requestRoute:(AGSGraphic *)site;

@end