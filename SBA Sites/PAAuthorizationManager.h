//
//  PAAuthorizationManager.h
//  SBA Sites
//
//  Created by Ross Chapman on 10/27/12.
//
//

#import <Foundation/Foundation.h>
#import "MKNetworkEngine.h"

extern NSString * const PAAuthorizationManagerDidLogin;
extern NSString * const PAAuthorizationManagerDidFailLogin;

@interface PAAuthorizationManager : NSObject

@property (nonatomic, readonly, getter = isLoggedIn) BOOL loggedIn;
@property (nonatomic, readonly, strong) NSString *username;

+ (id)sharedManager;

- (void)authenticateWithStoredCredentials;

- (void)authenticateWithUser:(NSString *)username
				andPassword:(NSString *)password
			   onCompletion:(MKNKResponseBlock)response
					onError:(MKNKErrorBlock)error;

@end
