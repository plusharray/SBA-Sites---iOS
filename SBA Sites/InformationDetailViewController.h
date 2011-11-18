//
//  InformationDetailViewController.h
//  SBA Site
//
//  Created by Ross Chapman on 11/2/10.
//  Copyright 2010 Bingaling Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	kNameID,
	kCoordinates,
	kAddress
} SearchInstructionsType;

@interface InformationDetailViewController : UITableViewController

@property (nonatomic) SearchInstructionsType instructionsType;

@end
