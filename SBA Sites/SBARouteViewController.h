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
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSRouteTask *routeTask;
@property (nonatomic, strong) AGSRouteTaskParameters *routeTaskParams;
@property (nonatomic, strong) AGSRouteResult *routeResult;
@property (nonatomic, strong) NSArray *routeStops;
@property (nonatomic, strong) AGSStopGraphic *startingGraphic;
@property (nonatomic, strong) AGSStopGraphic *destinationGraphic;

- (AGSCompositeSymbol*)stopSymbolWithNumber:(NSInteger)stopNumber;
- (AGSCompositeSymbol*)routeSymbol;

@end
