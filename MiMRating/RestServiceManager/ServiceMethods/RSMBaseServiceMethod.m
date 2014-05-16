//
// REST-Service-Manager (RSM)
//
// Core REST service method implementation
//
// An in-code representation of a single REST service method
//
// Created by Luther Stanton on 12/12/12.
//
/*

Licensed under simplified BSD License:

        Copyright (c) 2013, Luther Stanton

        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice, this
            list of conditions and the following disclaimer.
        2. Redistributions in binary form must reproduce the above copyright notice,
            this list of conditions and the following disclaimer in the documentation
            and/or other materials provided with the distribution.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
        ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

        The views and conclusions contained in the software and documentation are those
        of the authors and should not be interpreted as representing official policies,
        either expressed or implied, of the FreeBSD Project.
 */

#import "RSMBaseServiceMethod.h"
#import "RSMHHTTPConnection.h"
#import "RSMBaseServiceMethod+Protected.h"
#import "RSMServicesError.h"
#import "NSString+RestServiceManager.h"
#import "RSMServices.h"


@implementation RSMBaseServiceMethod {

@private
    BOOL _useSecureConnection;
    NSString *_host;
    NSString *_path;
    NSString *_action;

    RSMBaseServerMethodState _serviceState;
    dispatch_queue_t _stateManagementLockQueue;
}

#pragma mark Properties (Protected)

- (NSURLRequest *)urlRequest {
    return nil;
}

- (NSMutableDictionary *)requestHeaders {
    return nil;
}

- (NSURL *)url {

    NSString *urlText;

    if ([NSString isNilOrEmpty:_path]) {
        urlText = [NSString stringWithFormat:@"%@://%@/%@", _useSecureConnection ? @"https" : @"http", _host, _action];
    } else {
        urlText = [NSString stringWithFormat:@"%@://%@/%@/%@", _useSecureConnection ? @"https" : @"http", _host, _path, _action];
    }

    return [[NSURL alloc] initWithString:urlText];

}

- (void)setServiceState:(RSMBaseServerMethodState) aNewState{
    dispatch_sync(_stateManagementLockQueue, ^{
        _serviceState = aNewState;
    });
}

- (RSMBaseServerMethodState)serviceState{

    __block RSMBaseServerMethodState result;

    dispatch_sync(_stateManagementLockQueue, ^{
        result = _serviceState;
    });

    return result;
}

#pragma mark - Instance Lifecycle Management

- (id)initWithUseSecureConnection:(BOOL)aUseSecureConnectionFlag
                             host:(NSString *)theHost
                             path:(NSString *)thePath
                           action:(NSString *)theAction
        connectionTimeOutInterval:(NSTimeInterval)aConnectionTimeOutInterval {

    self = [super init];
    if (self) {

        _connectionTimeOutInterval = aConnectionTimeOutInterval;

        _useSecureConnection = aUseSecureConnectionFlag;
        _host = [theHost copy];
        _path = [thePath copy];
        _action = [theAction copy];
        
        _serviceState = RSM_BASE_SERVICE_STATE_IDLE;

        _stateManagementLockQueue = dispatch_queue_create("com.incomm.serviceframework.RSMBaseServiceMethod.stateManagementLockQueue", NULL);
    }
    return self;
}

// TODO remove after confirmation of iOS 6 target
/*
- (void)dealloc {
    // only needed when deployment target < iOS 6 & pre-processor -> OS_OBJECT_USE_OBJC=0
    dispatch_release(_stateManagementLockQueue);
}
 */

#pragma mark - Operations

- (BOOL)invoke:(NSError * __autoreleasing *)outError {
    
    BOOL result = NO;

    if ([self serviceState] == RSM_BASE_SERVICE_STATE_IDLE) {

        [self setServiceState:RSM_BASE_SERVICE_STATE_CONNECTING];

        _httpConnection = [[RSMHHTTPConnection alloc] initWithCompletedWithSuccessCompletionBlock:^(NSInteger theHTTPStatus, NSDictionary *theHeaderFields, NSData *theResponseContent) {
            [self operationInvocationSucceeded:theHTTPStatus headerFields:theHeaderFields responseContent:theResponseContent];
        }
                                                                            errorCompetionBlock:^(NSError *theError) {
                                                                                [self operationInvocationFailed:theError];
                                                                            }
                                                                                     andTimeout:_connectionTimeOutInterval];

        result = [_httpConnection startConnectionWithNSURLRequest:[self urlRequest] error:outError];

        if(!result){
            [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
        }

    } else {
        if (outError != NULL) {
            *outError = [NSError errorWithDomain:kRSMServicesErrorDomain
                                            code:RSM_SVCS_ERROR_OPERATION_IN_PROGRESS userInfo:nil];
        }
    }

    return result;
}

- (void)cancel {
    
    RSMBaseServerMethodState serviceState = [self serviceState];
    
    if(serviceState == RSM_BASE_SERVICE_STATE_CONNECTING){
        [_httpConnection cancel];
    }

    [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];

    [self operationInvocationFailed:[[NSError alloc] initWithDomain:kRSMServicesErrorDomain
                                                               code:RSM_SVCS_ERROR_REQUEST_CANCELLED userInfo:nil]];
}

#pragma mark - Operations (Protected)

- (void)operationInvocationFailed:(NSError *)theError {
    [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
}

- (void)operationInvocationSucceeded:(NSInteger)theStatus headerFields:(NSDictionary *)theHeaderFields responseContent:(NSData *)theResponseContent {
    [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
}

@end