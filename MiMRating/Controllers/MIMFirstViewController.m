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
#import "MIMActivityIndicatorView.h"

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

@implementation MIMFirstViewController {
	
	MIMActivityIndicatorView *_activityIndicator;
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_activityIndicator = [[MIMActivityIndicatorView alloc] initWithParentFrame:self.view.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button1_touchUpInside:(id)sender
{
	[self reportMoodRating:5];
}

- (IBAction)button2_touchUpInside:(id)sender
{
	[self reportMoodRating:4];
}

- (IBAction)button3_touchUpInside:(id)sender
{
	[self reportMoodRating:3];
}

- (IBAction)button4_touchUpInside:(id)sender
{
	[self reportMoodRating:2];
}

- (IBAction)button5_touchUpInside:(id)sender
{
	[self reportMoodRating:1];
}

- (void)reportMoodRating:(NSInteger)aRating
{
	MIMLocationManager *locationManager = [MIMLocationManager sharedInstance];
	if (locationManager.location != nil) {
		
		MIMReportingUser *user = [MIMReportingUser new];
		
		__weak id weakSelf = self;
		NSError * __autoreleasing error = nil;
		MIMUserService *service = [MIMUserService sharedInstance];
		NSString *instanceIdentifier = [service postMoodWithUsername:user.username
															password:user.password
															location:locationManager.location
																date:[NSDate date]
															  rating:[NSNumber numberWithInteger:aRating]
															   error:&error
													 completionBlock:^(NSError *error){
														 MIMFirstViewController *strongSelf = weakSelf;
														 [strongSelf.view setUserInteractionEnabled:YES];
														 [_activityIndicator removeFromSuperview];
														 
														 if (error == nil) {
															 [self displayAlertWithTitle:nil
																				 message:kSuccessMessage];
														 } else {
															 [self displayAlertWithTitle:kErrorTitle
																				 message:kFailureMessage];
														 }
													 }];
		
		if (instanceIdentifier != nil && [instanceIdentifier length] > 0) {
			[self.view setUserInteractionEnabled:NO];
			[self.view addSubview:_activityIndicator];
			[_activityIndicator setDisplayText:@"Recording Rating"];
			[_activityIndicator startAnimating];
		} else {
			[self displayAlertWithTitle:kErrorTitle
								message:kFailureMessage];
		}
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
