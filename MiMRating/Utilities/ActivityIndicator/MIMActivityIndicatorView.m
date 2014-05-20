//
//  MIMActivityIndicatorView.m
//  MiMRating
//
//  Created by Jason George on 5/11/14.
//  Copyright (c) 2014 Moose In The Mist, INC. All rights reserved.
//

#import "MIMActivityIndicatorView.h"


static const CGFloat kViewWidth = 160.0f;
static const CGFloat kViewHeight = 100.0f;

@implementation MIMActivityIndicatorView {
    UILabel *_displayTextLabel;
    UIActivityIndicatorView *_activityIndicatorView;
}

#pragma mark - Instance Lifecycle Management
// desingated initializer
- (id)initWithParentFrame:(CGRect)parentFrame {

    self = [super init];
    if (self) {

        CGFloat parentHeight = parentFrame.size.height;
        CGFloat parentWidth = parentFrame.size.width;

        self.frame = CGRectMake(
                (parentWidth - kViewWidth) / 2,
                (parentHeight - kViewHeight) / 2,
                kViewWidth,
                kViewHeight);

        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8f;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;

        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect activityIndicatorViewFrame = _activityIndicatorView.frame;
        CGFloat activityIndicatorXOffset =  (kViewWidth - activityIndicatorViewFrame.size.width) / 2;
        activityIndicatorViewFrame.origin = CGPointMake(activityIndicatorXOffset, 10);
        _activityIndicatorView.frame = activityIndicatorViewFrame;
        [self addSubview:_activityIndicatorView];

        _displayTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kViewHeight - 30, kViewWidth - 20, 20)];
        // TODO remove after confirmation of iOS6 target
//        _displayTextLabel.textAlignment = UITextAlignmentCenter;
        _displayTextLabel.textAlignment = NSTextAlignmentCenter;
        _displayTextLabel.backgroundColor = [UIColor clearColor];
        _displayTextLabel.textColor = [UIColor whiteColor];
        _displayTextLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_displayTextLabel];
    }

    return self;
}

#pragma mark - Operations
- (void)startAnimating {
    [_activityIndicatorView startAnimating];
}

- (void)stopAnimating {
    [_activityIndicatorView stopAnimating];
}

- (void)setDisplayText:(NSString *)displayText {
    [_displayTextLabel setText:displayText];
}

#pragma mark - Operations (super overrides)

- (void)removeFromSuperview {
    [_activityIndicatorView stopAnimating];
    [super removeFromSuperview];
}

@end