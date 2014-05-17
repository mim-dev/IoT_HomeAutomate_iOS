//
//  MIMReportingUser.m
//  MiMRating
//
//  Created by Jason George on 5/16/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMReportingUser.h"

static NSString * const kUsername = @"tuser";
static NSString * const kPassword = @"Password1!";

@implementation MIMReportingUser

- (instancetype)init
{
	self = [super init];
	if (self) {
		_username = kUsername;
		_password = kPassword;
	}
	return self;
}

@end
