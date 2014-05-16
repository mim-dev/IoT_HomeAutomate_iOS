//
//  MIMConnectivity.h
//  MiMRating
//
//  Created by Jason George on 5/12/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MIMConnectivityErrorDomain;
extern NSString * const MIMConnectivityHost;
extern NSString * const MIMConnectivityPath;
extern const BOOL MIMConnectivitySecure;
extern const NSTimeInterval MIMConnectivityTimeout;

@interface MIMConnectivity : NSObject

@end
