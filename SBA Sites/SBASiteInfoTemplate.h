//
//  SBASiteInfoTemplate.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/12/12.
//
//

#import <Foundation/Foundation.h>

@interface SBASiteInfoTemplate : NSObject <AGSInfoTemplateDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;
@property (strong, nonatomic) IBOutlet UIButton *routeButton;
@property (strong, nonatomic) IBOutlet UIButton *accessoryButton;

@end
