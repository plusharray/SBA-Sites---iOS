//
//  PAAuthorizationManager.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/27/12.
//
//

#import "PAAuthorizationManager.h"
#import "KeychainItemWrapper.h"
#import "MKNetworkOperation.h"

NSString * const PAAuthorizationManagerDidLogin = @"PAAuthorizationManagerDidLogin";
NSString * const PAAuthorizationManagerDidFailLogin = @"PAAuthorizationManagerDidFailLogin";

@interface PAAuthorizationManager ()

@property (nonatomic, getter = isLoggedIn) __block BOOL loggedIn;
@property (nonatomic, strong) __block NSString *username;
@property (nonatomic, strong) __block KeychainItemWrapper *wrapper;

@end

@implementation PAAuthorizationManager

+ (id)sharedManager
{
	static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        _loggedIn = NO;
		_wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Credentials" accessGroup:nil];
		_username = [_wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    }
    return self;
}

- (void)authenticateWithStoredCredentials
{
	self.username = [self.wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [self.wrapper objectForKey:(__bridge id)(kSecValueData)];
	if (self.username.length > 0 && password.length > 0) {
		[self authenticateWithUser:self.username andPassword:password onCompletion:nil onError:nil];
	} else {
		self.loggedIn = NO;
	}
}

- (void)authenticateWithUser:(NSString *)username andPassword:(NSString *)password onCompletion:(MKNKResponseBlock)response onError:(MKNKErrorBlock)error
{
    MKNetworkEngine *myEngine = [[MKNetworkEngine alloc] initWithHostName:@"map.sbasite.com" customHeaderFields:nil];;
    
    MKNetworkOperation *op = [myEngine operationWithPath:@"Authentication/"];
    
    [op setUsername:username password:password];
    
    [op onCompletion:^(MKNetworkOperation *operation) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// Save credentials
			self.username = username;
			[self.wrapper setObject:self.username forKey:(__bridge id)(kSecAttrAccount)];
			[self.wrapper setObject:password forKey:(__bridge id)(kSecValueData)];
			
			[self setLoggedIn:YES];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:PAAuthorizationManagerDidLogin object:operation];
		});
		if (response)
			response(operation);
	} onError:^(NSError *theError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// Clear credentials from keychain
			[self.wrapper setObject:@"" forKey:(__bridge id)(kSecAttrAccount)];
			[self.wrapper setObject:@"" forKey:(__bridge id)(kSecValueData)];
			
			[self setLoggedIn:NO];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:PAAuthorizationManagerDidFailLogin object:theError];
		});
		if (error)
			error(theError);
	}];
	
    [myEngine enqueueOperation:op];
}


@end
