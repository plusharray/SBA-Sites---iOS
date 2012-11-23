//
//  SBASiteTableViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBASiteTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AGSIdentifyTaskDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) AGSMapView *mapView;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) NSArray *layers;
@property (nonatomic, strong) NSArray *sites;
@property (nonatomic, strong) NSURL *dynamicServiceURL;

- (void)getSites;
- (IBAction)dismissSelf:(id)sender;

@end
