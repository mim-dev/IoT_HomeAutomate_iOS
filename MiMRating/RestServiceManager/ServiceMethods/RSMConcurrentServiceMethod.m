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

#import "RSMConcurrentServiceMethod.h"
#import "RSMUUID.h"
#import "RSMBaseServiceMethod+Protected.h"


@implementation RSMConcurrentServiceMethod {

}

#pragma mark - Instance Lifecycle Management
- (id)initWithUseSecureConnection:(BOOL)aUseSecureConnectionFlag
                             host:(NSString *)theHost
                             path:(NSString *)thePath
                           action:(NSString *)theAction
              connectionTimeOutInterval:(NSTimeInterval)aConnectionTimeOutInterval
concurrentExecutionMgrNotificationBlock:(void (^)(NSString *theOperationInstanceIdentifier))aConcurrentExecutionMgrNotificationBlock {

    self = [super initWithUseSecureConnection:aUseSecureConnectionFlag
                                         host:theHost
                                         path:thePath
                                       action:theAction
                    connectionTimeOutInterval:aConnectionTimeOutInterval];

    if (self) {
        _concurrentExecutionMgrNotificationBlock = aConcurrentExecutionMgrNotificationBlock;
    }

    return self;

}

#pragma mark - Operations (Public)

- (BOOL)execUsingOperationInstanceIdentifier:(NSString *)anOperationInstanceIdentifier
                                       error:(NSError * __autoreleasing *)outError {

    _operationInstanceIdentifier = anOperationInstanceIdentifier;

    return [super invoke:outError];

}

- (NSString *)exec:(NSError * __autoreleasing *)outError {

    NSString *operationInstanceIdentifier = [RSMUUID UUID];
    BOOL operationCompleted = [self execUsingOperationInstanceIdentifier:operationInstanceIdentifier error:outError];

    NSString *result = operationCompleted ? operationInstanceIdentifier : nil;

    return result;
}

#pragma mark - Operations (Protected)

- (void)operationInvocationFailed:(NSError *)theError {
    [super operationInvocationFailed:theError];
    if (_concurrentExecutionMgrNotificationBlock) {
        _concurrentExecutionMgrNotificationBlock(_operationInstanceIdentifier);
    }
}

- (void)operationInvocationSucceeded:(NSInteger)theStatus headerFields:(NSDictionary *)theHeaderFields responseContent:(NSData *)theResponseContent {
    [super operationInvocationSucceeded:theStatus headerFields:theHeaderFields responseContent:theResponseContent];
    if (_concurrentExecutionMgrNotificationBlock) {
        _concurrentExecutionMgrNotificationBlock(_operationInstanceIdentifier);
    }
}

@end