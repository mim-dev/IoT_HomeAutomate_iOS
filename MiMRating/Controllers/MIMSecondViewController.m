//
//  MIMSecondViewController.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMSecondViewController.h"
#import "MIMLocationManager.h"
#import "MIMUserService.h"
#import "MIMReportingUser.h"
#import "MIMActivityIndicatorView.h"

static NSString * const kErrorTitle = @"Error";
static NSString * const kCancelTitle = @"OK";
static NSString * const kFailureMessage = @"Unable to report physical rating";
static NSString * const kSuccessMessage = @"Physical rating successfully reported";
static NSString * const kLocationMessage = @"Unable to determine your location";

@interface MIMSecondViewController ()

- (void)reportPhysicalRating:(NSInteger)rating;
- (void)displayAlertWithTitle:(NSString *)aTitle
					  message:(NSString *)aMessage;

@end

@implementation MIMSecondViewController {
	
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

- (IBAction)button_touchUpInside:(id)sender
{
	MIMLocationManager *locationManager = [MIMLocationManager sharedInstance];
	if (locationManager.location != nil) {
		
		NSError * __autoreleasing error = nil;
		MIMUserService *service = [MIMUserService sharedInstance];
		[service postPhysicalWithUsername:@"tuser"
								 password:@"Password1!"
								 location:locationManager.location
									 date:[NSDate date]
								   rating:[NSNumber numberWithInt:5]
									error:&error
						  completionBlock:^(NSError *error){
							  NSLog(@"error");
						  }];
	}
}

- (IBAction)button1_touchUpInside:(id)sender
{
	[self reportPhysicalRating:5];
}

- (IBAction)button2_touchUpInside:(id)sender
{
	[self reportPhysicalRating:4];
}

- (IBAction)button3_touchUpInside:(id)sender
{
	[self reportPhysicalRating:3];
}

- (IBAction)button4_touchUpInside:(id)sender
{
	[self reportPhysicalRating:2];
}

- (IBAction)button5_touchUpInside:(id)sender
{
	[self reportPhysicalRating:1];
}

- (void)reportPhysicalRating:(NSInteger)aRating
{
	MIMLocationManager *locationManager = [MIMLocationManager sharedInstance];
	if (locationManager.location != nil) {
		
		MIMReportingUser *user = [MIMReportingUser new];
		
		__weak id weakSelf = self;
		NSError * __autoreleasing error = nil;
		MIMUserService *service = [MIMUserService sharedInstance];
		NSString *instanceIdentifier = [service postPhysicalWithUsername:user.username
																password:user.password
																location:locationManager.location
																	date:[NSDate date]
																  rating:[NSNumber numberWithInteger:aRating]
																   error:&error
														 completionBlock:^(NSError *error){
															 MIMSecondViewController *strongSelf = weakSelf;
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
