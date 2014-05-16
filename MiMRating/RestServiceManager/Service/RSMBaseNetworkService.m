//
// REST-Service-Manager (RSM)
//
// Core Network Service implementation
//
// Represents a network service proxy consisting of one or more service methods and the required support structure
//
// Created by Luther Stanton on 11/20/12.
//
// Copyright Luther Stanton 2013

#import "RSMBaseNetworkService.h"
#import "RSMBaseServiceMethod+Protected.h"

static const NSTimeInterval kDefaultNetworkTimeoutInSeconds = 30;

@interface RSMBaseNetworkService ()

#pragma mark - Properties (private)

@property(nonatomic, assign) NSTimeInterval connectionTimeoutInterval;

@end

@implementation RSMBaseNetworkService

#pragma mark - Instance LifeCycle Management

- (id)init {

    return [self initWithConnectionTimeoutInterval:kDefaultNetworkTimeoutInSeconds];
}

- (id)initWithConnectionTimeoutInterval:(NSTimeInterval)seconds {

    self = [super init];

    if (self) {
        _connectionTimeoutInterval = seconds;
        _serviceProcessingList = [RSMServiceOperationInvocationList new];
    }

    return self;
}

#pragma mark - Operations (Public)
- (void)cancelOperationWithInstanceIdentifier:(NSString *)operationInstanceIdentifier {

    RSMBaseServiceMethod *serviceOperation = [_serviceProcessingList serviceOperationForOperationInstanceIdentifier:operationInstanceIdentifier removeInstance:NO];

    if (serviceOperation != nil) {
        [serviceOperation cancel];
    }
}

#pragma mark - Operations (Protected)

- (NSTimeInterval) networkConnectionTimeout{
    return self.connectionTimeoutInterval;
}

- (void (^)(NSString *))anOperationProcessingCompletedNotificationBlock {


    return ^(NSString *theOperationInstanceIdentifier){
        [_serviceProcessingList removeServiceOperationForOperationInstanceIdentifier:theOperationInstanceIdentifier];
    };

}

@end