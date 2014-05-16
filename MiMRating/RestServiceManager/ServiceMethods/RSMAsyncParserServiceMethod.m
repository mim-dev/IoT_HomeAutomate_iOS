//
// REST-Service-Manager (RSM)
//
// Concurrent Service Method implementation
//
// Provides the infrastructure and constructs for a concurrent / asynchronous service method invocation
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

#import "RSMAsyncParserServiceMethod.h"
#import "RSMBaseServiceMethod+Protected.h"
#import "RSMBaseResultParser.h"


@implementation RSMAsyncParserServiceMethod

#pragma mark - Instance Lifecycle Management
- (id)initWithUseSecureConnection:(BOOL)aUseSecureConnectionFlag
                             host:(NSString *)theHost
                             path:(NSString *)thePath
                           action:(NSString *)theAction
        connectionTimeOutInterval:(NSTimeInterval)aConnectionTimeOutInterval {
    
    self = [super initWithUseSecureConnection:aUseSecureConnectionFlag
                                         host:theHost
                                         path:thePath
                                       action:theAction
                    connectionTimeOutInterval:aConnectionTimeOutInterval];
    
    if (self) {
        _opQueue = [NSOperationQueue new];
    }
    
    return self;
    
}

- (void)dealloc {
    [_opQueue cancelAllOperations];
}

#pragma mark - Operations (Public)

- (void)cancel {
    
    RSMBaseServerMethodState serviceState = [self serviceState];
    
    if(serviceState == RSM_BASE_SERVICE_STATE_PARSING){
        [_opQueue cancelAllOperations];
        
        [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
        
        [self operationInvocationFailed:[[NSError alloc] initWithDomain:kRSMServicesErrorDomain
                                                                   code:RSM_SVCS_ERROR_REQUEST_CANCELLED userInfo:nil]];
    }
    else {
        [super cancel];
    }
    
}

#pragma mark - Operations (Protected)

- (void)parseResultsWithParser:(RSMBaseResultParser *)aParser {
    [self setServiceState:RSM_BASE_SERVICE_STATE_PARSING];
    [_opQueue addOperation:aParser];
}

- (void)asynchronousParsingCompleted {
    [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
}

- (void)asynchronousParsingFailed:(NSError *)theError {
    [self setServiceState:RSM_BASE_SERVICE_STATE_IDLE];
}

@end

