//
//  MIMUserPhysicalOperation.h
//  MiMRating
//
//  Created by Jason George on 5/12/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "RSMConcurrentServiceMethod.h"

@interface MIMUserPhysicalOperation : RSMConcurrentServiceMethod

// designated initializer
- (instancetype)initWithUsername:(NSString *)aUsername
						password:(NSString *)aPassword
						location:(CLLocation *)aLocation
							date:(NSDate *)aDate
						  rating:(NSNumber *)aRating
				 timeOutInterval:(NSTimeInterval)aTimeOutInterval
				 completionBlock:(void (^)(NSError *error))aCompletionBlock;

@end
