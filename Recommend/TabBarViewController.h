//
//  TabBarViewController.h
//  Recommend
//
//  Created by Thomas Orten on 6/21/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated;
- (BOOL)tabBarIsVisible;

@end
