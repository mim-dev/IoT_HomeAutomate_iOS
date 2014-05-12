//
//  MIMLocationManager.h
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const MIMLocaitonManagerResolvedNofitication;
extern NSString * const MIMLocationManagerErrorNotification;

@interface MIMLocationManager : NSObject

@property (nonatomic, strong, readonly) CLLocation *location;

+ (MIMLocationManager *)sharedInstance;

- (void)startStandardUpdates;
- (void)stopUpdates;


@end
