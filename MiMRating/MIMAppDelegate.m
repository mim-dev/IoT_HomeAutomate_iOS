//
//  MIMAppDelegate.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMAppDelegate.h"
#import "MIMLocationManager.h"

@interface MIMAppDelegate ()

- (void)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)locationError;

@end

@implementation MIMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[self stopLocationUpdates];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self startLocationUpdates];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Location Management

- (void)startLocationUpdates
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationError)
												 name:MIMLocationManagerErrorNotification
											   object:nil];
	[[MIMLocationManager sharedInstance] startStandardUpdates];

}

- (void)stopLocationUpdates
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MIMLocationManagerErrorNotification
												  object:nil];
	[[MIMLocationManager sharedInstance] stopUpdates];
}

- (void)locationError
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Unable to determine your location"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}


@end
