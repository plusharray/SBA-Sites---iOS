//
//  SiteImageViewController.h
//  SBA Site
//
//  Created by Ross Chapman on 10/14/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SiteImageViewController : UIViewController {
	NSOperationQueue *_retrieverQueue;
    NSString *pathString;
    UIImageView *imageView;
}
//=========================================================== 
#pragma mark -
#pragma mark Properties
#pragma mark -
//=========================================================== 
@property (nonatomic, strong) NSString *pathString;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imagePath:(NSString *)aPath;

- (IBAction)dismissAction:(id)sender;
- (NSOperationQueue *)retrieverQueue;
- (void)getImageForPath:(NSString *)imgPath;

@end
