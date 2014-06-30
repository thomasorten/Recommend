//
//  TabBarViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/21/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "TabBarViewController.h"
#import "SWRevealViewController.h"
#import "LocationViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

// a param to describe the state change, and an animated flag
// optionally add a completion block which matches UIView animation
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {

    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;

    // get a frame calculation ready
    CGRect frame = self.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;

    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;

    [UIView animateWithDuration:duration animations:^{
        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

@end
