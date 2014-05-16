//
//  MIMUserMoodOperation.m
//  MiMRating
//
//  Created by Jason George on 5/12/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMUserMoodOperation.h"
#import "MIMConnectivity.h"
#import "RSMBaseServiceMethod+Protected.h"

static NSString * const kAction = @"reportinguser/mood";

@implementation MIMUserMoodOperation {
	
	NSString *_username;
	NSString *_password;
	CLLocation *_location;
	NSDate *_date;
	NSNumber *_rating;
	NSTimeInterval _timeOutInterval;
	void (^_completionBlock)(NSError *error);
}

- (instancetype)initWithUsername:(NSString *)aUsername
						password:(NSString *)aPassword
						location:(CLLocation *)aLocation
							date:(NSDate *)aDate
						  rating:(NSNumber *)aRating
				 timeOutInterval:(NSTimeInterval)aTimeOutInterval
				 completionBlock:(void (^)(NSError *error))aCompletionBlock
{
	self = [super initWithUseSecureConnection:NO
										 host:MIMConnectivityHost
										 path:MIMConnectivityPath
									   action:kAction
					connectionTimeOutInterval:MIMConnectivityTimeout];
	if (self) {
		_username = aUsername;
		_password = aPassword;
		_location = aLocation;
		_date = aDate;
		_rating = aRating;
		_timeOutInterval = aTimeOutInterval;
	}
	return self;
}

#pragma mark - Operations (Super Overrides)

- (void)operationInvocationSucceeded:(NSInteger)theStatus
						headerFields:(NSDictionary *)theHeaderFields
					 responseContent:(NSData *)theResponseContent
{
	NSError *error = nil;
	if (theStatus != 204) {
		error = [NSError errorWithDomain:MIMConnectivityErrorDomain
									code:theStatus
								userInfo:nil];
	}
	
	if (_completionBlock != nil) {
		_completionBlock(error);
	}
}

- (void)operationInvocationFailed:(NSError *)theError
{
	NSError *error = [NSError errorWithDomain:MIMConnectivityErrorDomain
										 code:-1
									 userInfo:nil];
	if (_completionBlock != nil) {
		_completionBlock(error);
	}
}

- (NSURLRequest *)urlRequest
{
	NSString *username = @"";
	if (_username != nil) {
		username = _username;
	}
	
	NSString *password = @"";
	if (_password != nil) {
		password = _password;
	}
	
	NSDictionary *userDictionary = @{@"username" : username,
									 @"password" : password};
	
	NSNumber *latitude = @0;
	NSNumber *longitude = @0;
	if (_location != nil) {
		latitude = [NSNumber numberWithFloat:_location.coordinate.latitude];
		longitude = [NSNumber numberWithFloat:_location.coordinate.longitude];
	}
	
	NSString *date = @"";
	if (_date != nil) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'hh:mm:ss'Z'";
		date = [dateFormatter stringFromDate:_date];
	}
	
	NSNumber *rating = @0;
	if (_rating != nil) {
		rating = _rating;
	}
	
	NSDictionary *jsonDictionary = @{@"reportingUser" : userDictionary,
									 @"latitude" : latitude,
									 @"longitude" : longitude,
									 @"date" : date,
									 @"rating" : rating};
	__autoreleasing NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
													   options:kNilOptions
														 error:&error];
	
	NSDictionary *headerDictionary = @{@"Content-Type" : @"application/json; charset=UTF-8"};
	
	NSMutableURLRequest *urlRequest = nil;
	if (jsonData != nil) {
		urlRequest = [[NSMutableURLRequest alloc] initWithURL:[self url]];
		urlRequest.HTTPMethod = @"POST";
		urlRequest.HTTPBody = jsonData;
		urlRequest.allHTTPHeaderFields = headerDictionary;
	}
	
	return urlRequest;
}

@end
