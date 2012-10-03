//
//  SBARouteViewController.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/1/12.
//
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class SBAMapViewController;

@interface SBARouteViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, UITextFieldDelegate, AGSRouteTaskDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) SBAMapViewController *mapViewController;
@property (strong, nonatomic) IBOutlet UITextField *startingAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *destinationAddressTextField;
@property (nonatomic, retain) AGSRouteTask *routeTask;
@property (nonatomic, retain) AGSRouteTaskParameters *routeTaskParams;
@property (nonatomic, retain) AGSRouteResult *routeResult;
@property (nonatomic, strong) NSArray *routeStops;
@property (nonatomic, strong) AGSStopGraphic *startingGraphic;
@property (nonatomic, strong) AGSStopGraphic *destinationGraphic;

- (id)initWithSBAMapViewController:(SBAMapViewController *)mapViewController;
- (AGSCompositeSymbol*)stopSymbolWithNumber:(NSInteger)stopNumber;
- (AGSCompositeSymbol*)routeSymbol;

@end
