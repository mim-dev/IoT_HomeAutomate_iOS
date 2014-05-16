//
//  MIMUserService.h
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RSMBaseNetworkService.h"

@interface MIMUserService : RSMBaseNetworkService

+ (MIMUserService *)sharedInstance;

- (NSString *)postMoodWithUsername:(NSString *)aUsername
						  password:(NSString *)aPassword
						  location:(CLLocation *)aLocation
							  date:(NSDate *)aDate
							rating:(NSNumber *)aRating
							 error:(NSError * __autoreleasing *)outError
				   completionBlock:(void (^)(NSError *error))aCompletionBlock;

- (NSString *)postPhysicalWithUsername:(NSString *)aUsername
							  password:(NSString *)aPassword
							  location:(CLLocation *)aLocation
								  date:(NSDate *)aDate
								rating:(NSNumber *)aRating
								 error:(NSError * __autoreleasing *)outError
					   completionBlock:(void (^)(NSError *error))aCompletionBlock;

@end
