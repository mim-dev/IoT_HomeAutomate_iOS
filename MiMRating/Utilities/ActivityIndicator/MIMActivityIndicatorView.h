//
//  MIMActivityIndicatorView.h
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface MIMActivityIndicatorView : UIView

#pragma mark - Instance Lifecycle Management
// designated initializer
- (id)initWithParentFrame:(CGRect)parentFrame;

#pragma mark - Operations
- (void)startAnimating;
- (void)stopAnimating;

- (void)setDisplayText:(NSString *)displayText;

@end