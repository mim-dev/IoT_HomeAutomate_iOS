//
//  MIMUserService.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMUserService.h"
#import "RSMUUID.h"
#import "MIMUserMoodOperation.h"
#import "MIMUserPhysicalOperation.h"
#import "MIMConnectivity.h"

@implementation MIMUserService

+ (MIMUserService *)sharedInstance
{
	static MIMUserService *sharedUserService = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedUserService = [MIMUserService new];
	});
	return sharedUserService;
}

- (NSString *)postMoodWithUsername:(NSString *)aUsername
						  password:(NSString *)aPassword
						  location:(CLLocation *)aLocation
							  date:(NSDate *)aDate
							rating:(NSNumber *)aRating
							 error:(NSError * __autoreleasing *)outError
				   completionBlock:(void (^)(NSError *error))aCompletionBlock
{	
	MIMUserMoodOperation *operation = [[MIMUserMoodOperation alloc] initWithUsername:aUsername
																			password:aPassword
																			location:aLocation
																				date:aDate
																			  rating:aRating
																	 timeOutInterval:MIMConnectivityTimeout
																	 completionBlock:aCompletionBlock];
	
	BOOL operationStarted = NO;
	NSString *instanceIdentifier = [operation exec:outError];
	if (instanceIdentifier != nil && [instanceIdentifier length] > 0) {
		operationStarted = YES;
		[_serviceProcessingList setServiceOperation:operation
					 forOperationInstanceIdentifier:instanceIdentifier];
	}
	
	NSString *result = operationStarted ? instanceIdentifier : nil;
	return result;
}

- (NSString *)postPhysicalWithUsername:(NSString *)aUsername
							  password:(NSString *)aPassword
							  location:(CLLocation *)aLocation
								  date:(NSDate *)aDate
								rating:(NSNumber *)aRating
								 error:(NSError * __autoreleasing *)outError
					   completionBlock:(void (^)(NSError *error))aCompletionBlock
{
	MIMUserPhysicalOperation *operation = [[MIMUserPhysicalOperation alloc] initWithUsername:aUsername
																					password:aPassword
																					location:aLocation
																						date:aDate
																					  rating:aRating
																			 timeOutInterval:MIMConnectivityTimeout
																			 completionBlock:aCompletionBlock];
	
	BOOL operationStarted = NO;
	NSString *instanceIdentifier = [operation exec:outError];
	if (instanceIdentifier != nil && [instanceIdentifier length] > 0) {
		operationStarted = YES;
		[_serviceProcessingList setServiceOperation:operation
					 forOperationInstanceIdentifier:instanceIdentifier];
	}
	
	NSString *result = operationStarted ? instanceIdentifier : nil;
	return result;
}

@end
