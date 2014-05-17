//
//  MIMFirstViewController.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMFirstViewController.h"
#import "MIMLocationManager.h"
#import "MIMUserService.h"
#import "MIMReportingUser.h"

static NSString * const kErrorTitle = @"Error";
static NSString * const kCancelTitle = @"OK";
static NSString * const kFailureMessage = @"Unable to report mood rating";
static NSString * const kSuccessMessage = @"Mood rating successfully reported";
static NSString * const kLocationMessage = @"Unable to determine your location";

@interface MIMFirstViewController ()

- (void)reportMoodRating:(NSInteger)rating;
- (void)displayAlertWithTitle:(NSString *)aTitle
					  message:(NSString *)aMessage;

@end

@implementation MIMFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_touchUpInside:(id)sender
{
	[self reportMoodRating:3];
}

- (void)reportMoodRating:(NSInteger)aRating
{
	MIMLocationManager *locationManager = [MIMLocationManager sharedInstance];
	if (locationManager.location != nil) {
		
		MIMReportingUser *user = [MIMReportingUser new];
		
		NSError * __autoreleasing error = nil;
		MIMUserService *service = [MIMUserService sharedInstance];
		[service postMoodWithUsername:user.username
							 password:user.password
							 location:locationManager.location
								 date:[NSDate date]
							   rating:[NSNumber numberWithInteger:aRating]
								error:&error
					  completionBlock:^(NSError *error){
						  
						  if (error == nil) {
							  [self displayAlertWithTitle:nil
												  message:kSuccessMessage];
						  } else {
							  [self displayAlertWithTitle:kErrorTitle
												  message:kFailureMessage];
						  }
						  
						  NSLog(@"error");
					  }];
	} else {
		[self displayAlertWithTitle:kErrorTitle
							message:kLocationMessage];
	}
}

- (void)displayAlertWithTitle:(NSString *)aTitle
					  message:(NSString *)aMessage
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aTitle
														message:aMessage
													   delegate:nil
											  cancelButtonTitle:kCancelTitle
											  otherButtonTitles:nil];
	[alertView show];
}

@end
