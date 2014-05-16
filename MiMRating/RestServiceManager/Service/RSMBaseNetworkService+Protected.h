//
// REST-Service-Manager (RSM)
//
// Definition of the core Network Service protected members
//
// Represents a network service proxy consisting of one or more service methods and the required support structure
//
// Created by Luther Stanton on 11/20/12.
//
//  Copyright Luther Stanton 2013


#import <Foundation/Foundation.h>
#import "RSMBaseNetworkService.h"


@interface RSMBaseNetworkService (Protected)

- (NSTimeInterval) networkConnectionTimeout;

// designated initializer
- (id)initWithConnectionTimeoutInterval:(NSTimeInterval)seconds;

- (void (^)(NSString *))anOperationProcessingCompletedNotificationBlock;

@end