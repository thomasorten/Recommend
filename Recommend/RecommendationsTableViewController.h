//
//  MapViewViewController.h
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface RecommendationsTableViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property PFObject *recommendation;
@property NSString *selectedLocation;
@end
