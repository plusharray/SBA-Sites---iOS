//
//  SBASiteTableViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBASiteTableViewController : UITableViewController <AGSIdentifyTaskDelegate>

@property (nonatomic, strong) AGSMapView *mapView;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) NSArray *sites;

- (void)getSites;

@end
