//
//  TabBarViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/21/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "TabBarViewController.h"
#import "SWRevealViewController.h"
#import "HeaderImage.h"
#import "HomeViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface TabBarViewController () <UITabBarDelegate, UITabBarControllerDelegate>

@end

@implementation TabBarViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Home"]) {
        UINavigationController *navVC = (UINavigationController *) [self.viewControllers objectAtIndex:0];
        HomeViewController *vc = (HomeViewController *) navVC.visibleViewController;
        if (vc.scrollOffset > 0) {
            [vc.newestCollectionView setContentOffset:CGPointZero animated:YES];
            [vc.popularCollectionView setContentOffset:CGPointZero animated:YES];
        }
    }
}

@end
