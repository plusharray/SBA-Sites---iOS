//
//  LayerViewController.h
//  SBASite
//
//  Created by Ross Chapman on 9/30/10.
//  Copyright 2010 Bingaling Apps All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *layerArray;
@property (nonatomic) NSInteger selectedMapType;

- (IBAction)mapType:(UISegmentedControl *)segmentPick;
- (IBAction)dismissAction:(id)sender;

@end

