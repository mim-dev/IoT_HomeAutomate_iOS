//
// REST-Service-Manager (RSM)
//
// Definition of the core Network Service members
//
// Represents a network service proxy consisting of one or more service methods and the required support structure
//
// Created by Luther Stanton on 11/20/12.
//
//  Copyright Luther Stanton 2013


#import <Foundation/Foundation.h>

#import "RSMServiceOperationInvocationList.h"

@class RSMServiceOperationInvocationList;

@interface RSMBaseNetworkService : NSObject  {
    @protected
    RSMServiceOperationInvocationList *_serviceProcessingList;
}

// see RSMBaseNetworkService+Protected for designated initializer!
- (void)cancelOperationWithInstanceIdentifier:(NSString *)operationInstanceIdentifier;

@end