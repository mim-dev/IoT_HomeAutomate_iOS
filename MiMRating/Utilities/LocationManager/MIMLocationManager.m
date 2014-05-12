//
//  MIMLocationManager.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMLocationManager.h"

NSString * const MIMLocaitonManagerResolvedNofitication = @"com.mim-development.locationManager.resolved";
NSString * const MIMLocationManagerErrorNotification = @"com.mim-development.locationManager.error";

@interface MIMLocationManager () <CLLocationManagerDelegate>

@end

@implementation MIMLocationManager  {
	CLLocationManager *_locationManager;
}

+ (MIMLocationManager *)sharedInstance
{
	static MIMLocationManager *sharedLocationManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedLocationManager = [MIMLocationManager new];
	});
	return sharedLocationManager;
}

- (void)dealloc
{
	[self stopUpdates];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
	
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 500; // meters
	
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdates
{
	if (_locationManager != nil) {
		[_locationManager stopUpdatingLocation];
		_locationManager = nil;
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	_location = nil;
	[self stopUpdates];
	[[NSNotificationCenter defaultCenter] postNotificationName:MIMLocationManagerErrorNotification
														object:self];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power.
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	if (abs(howRecent) < 15.0) {
		_location = location;
		[[NSNotificationCenter defaultCenter] postNotificationName:MIMLocaitonManagerResolvedNofitication
															object:self];
	}
}

@end
