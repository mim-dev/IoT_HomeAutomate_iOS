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

@interface MIMSecondViewController ()

@end

@implementation MIMSecondViewController

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

@end
