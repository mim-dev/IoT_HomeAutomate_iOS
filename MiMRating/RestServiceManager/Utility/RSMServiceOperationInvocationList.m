//
// REST-Service-Manager (RSM)
//
// Service Operation Invocation List implementation
//
// The Service Operation Invocation List is utilized by RSMBaseNetworkService to maintain a list
//  of service operation invocations
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

#import "RSMServiceOperationInvocationList.h"
#import "RSMBaseServiceMethod.h"

@implementation RSMServiceOperationInvocationList {

    dispatch_queue_t _processingListLockQueue;

    NSMutableDictionary *_processingList;

}

- (id)init {

    self = [super init];

    if (self) {
        _processingList = [[NSMutableDictionary alloc] initWithCapacity:10];
        _processingListLockQueue = dispatch_queue_create("com.incomm.serviceoperationinvcoation.processingListQueue", NULL);
    }

    return self;

}

// TODO remove after confirmation of iOS 6 target
/*
- (void)dealloc {
    // only needed when deployment target < iOS 6 & pre-processor -> OS_OBJECT_USE_OBJC=0
    dispatch_release(_processingListLockQueue);
}
 */

- (BOOL)setServiceOperation:(RSMBaseServiceMethod *)aServiceOperation forOperationInstanceIdentifier:(NSString *)anOperationInstanceIdentifier {

    __block BOOL result;

    dispatch_sync(_processingListLockQueue, ^{
        if ([_processingList objectForKey:anOperationInstanceIdentifier] == nil) {
            [_processingList setObject:aServiceOperation forKey:anOperationInstanceIdentifier];
            result = YES;
        } else {
            result = NO;
        }
    });

    return result;

}

- (RSMBaseServiceMethod *)serviceOperationForOperationInstanceIdentifier:(NSString *)anOperationInstanceIdentifier removeInstance:(BOOL)aRemoveInstanceFlag {

    __block RSMBaseServiceMethod *result;

    dispatch_sync(_processingListLockQueue, ^{

        result = [_processingList objectForKey:anOperationInstanceIdentifier];

        if (result != nil && aRemoveInstanceFlag) {
            [_processingList removeObjectForKey:anOperationInstanceIdentifier];
        }
    });

    return result;
}

- (BOOL)removeServiceOperationForOperationInstanceIdentifier:(NSString *)anOperationInstanceIdentifier {

    __block BOOL result;

    dispatch_sync(_processingListLockQueue, ^{
        if ([_processingList objectForKey:anOperationInstanceIdentifier] != nil) {
            [_processingList removeObjectForKey:anOperationInstanceIdentifier];
            result = YES;
        } else {
            result = NO;
        }
    });

    return result;

}

@end