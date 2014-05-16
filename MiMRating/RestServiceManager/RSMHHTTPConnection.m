//
// REST-Service-Manager (RSM)
//
// Core HTTP Connection implementation
//
// Encapsulates all aspects of an "on the wire" HTTP Connection including timer / timeout
//  monitoring and reporting
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

#import "RSMHHTTPConnection.h"

#import "RSMServices.h"

@interface RSMHHTTPConnection ()

#pragma mark - Operations (Private)
- (void)watchDogTimerFireHandler:(NSTimer *)theTimer;

@end

@implementation RSMHHTTPConnection {

    BOOL _connectionInProgress;

    NSTimeInterval _connectionTimeoutInterval;
    NSTimer *_watchDogTimer;

    // HTTP elements
    NSInteger _httpStatus;
    NSDictionary *_headerFields;

    NSMutableData *_connectionDataBuffer;
    NSURLConnection *_urlConnection;

    void (^_successCompletionBlock)(NSInteger httpStatus, NSDictionary *headersFields, NSData *theResponseContent);

    void (^_errorCompletionBlock)(NSError *theError);
}

#pragma mark - Instance Lifecycle Management

- (id)initWithCompletedWithSuccessCompletionBlock:(void (^)(NSInteger httpStatus, NSDictionary *headersFields, NSData *theResponseContent))aSuccessCompletionBlock
                              errorCompetionBlock:(void (^)(NSError *theError))anErrorCompletionBlock
                                       andTimeout:(NSTimeInterval)aConnectionTimeoutInterval {

    self = [super init];

    if (self) {
        _successCompletionBlock = aSuccessCompletionBlock;
        _errorCompletionBlock = anErrorCompletionBlock;
        _connectionTimeoutInterval = aConnectionTimeoutInterval;

        _connectionInProgress = NO;
    }

    return self;
}

#pragma mark - Operations

- (BOOL)startConnectionWithNSURLRequest:(NSURLRequest *)anURLRequest error:(NSError **)outError {

    BOOL result = YES;

    if (!_connectionInProgress) {

        // wire the connection to the default run loop
        _urlConnection = [[NSURLConnection alloc] initWithRequest:anURLRequest
                                                         delegate:self
                                                 startImmediately:NO];

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifNetworkRequestStarted object:self];

        [_urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

        // wire the timer
        _watchDogTimer = [NSTimer timerWithTimeInterval:_connectionTimeoutInterval
                                                 target:self
                                               selector:@selector(watchDogTimerFireHandler:)
                                               userInfo:nil repeats:NO];

        // start the process
        [_urlConnection start];
        [[NSRunLoop mainRunLoop] addTimer:_watchDogTimer forMode:NSDefaultRunLoopMode];
        _connectionInProgress = YES;
    } else {
        result = NO;

        if (outError != NULL) {
            *outError = [NSError errorWithDomain:kRSMServicesErrorDomain
                                            code:RSM_SVCS_ERROR_OPERATION_IN_PROGRESS userInfo:nil];
        }
    }

    return result;
}

- (void)cancel {

    if (_connectionInProgress) {

        [_urlConnection cancel];

        if (_watchDogTimer != nil) {

            if ([_watchDogTimer isValid]) {
                [_watchDogTimer invalidate];
            }

            _watchDogTimer = nil;
        }

        _connectionInProgress = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifNetworkRequestEnded object:self];

        _urlConnection = nil;
    }

}

#pragma mark - NSURLConnectionDelegate Protocol Implementation

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    if (connection == _urlConnection && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        _httpStatus = ((NSHTTPURLResponse *) response).statusCode;
        _headerFields = ((NSHTTPURLResponse *) response).allHeaderFields;
    }

    _connectionDataBuffer = [NSMutableData new];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (connection == _urlConnection) {
        [_connectionDataBuffer appendData:data];
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    _connectionDataBuffer = nil;

    if (connection == _urlConnection) {

        if (_watchDogTimer != nil && [_watchDogTimer isValid]) {
            [_watchDogTimer invalidate];
            _watchDogTimer = nil;
        }
        _connectionInProgress = NO;

        if (_errorCompletionBlock) {
        _errorCompletionBlock(error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifNetworkRequestEnded object:self];
        _urlConnection = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (connection == _urlConnection) {

        _urlConnection = nil;

        if (_watchDogTimer != nil && [_watchDogTimer isValid]) {
            [_watchDogTimer invalidate];
            _watchDogTimer = nil;
        }

        _connectionInProgress = NO;

        NSData *connectionDataCopy = [_connectionDataBuffer copy];
        _connectionDataBuffer = nil;
        _urlConnection = nil;

        if (_successCompletionBlock) {
            _successCompletionBlock(_httpStatus, _headerFields, connectionDataCopy);
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifNetworkRequestEnded object:self];
    }

}

#pragma mark - Operations (Private)

- (void)watchDogTimerFireHandler:(NSTimer *)theTimer {

    if (theTimer == _watchDogTimer) {

        _watchDogTimer = nil;

        [_urlConnection cancel];

        _urlConnection = nil;
        _connectionDataBuffer = nil;
        _connectionInProgress = NO;

        NSError *timeOutError = [[NSError alloc] initWithDomain:kRSMServicesErrorDomain code:RSM_SVCS_ERROR_REQUEST_TIMED_OUT userInfo:nil];
        if (_errorCompletionBlock) {
            _errorCompletionBlock(timeOutError);
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifNetworkRequestEnded object:self];
    }

}

@end