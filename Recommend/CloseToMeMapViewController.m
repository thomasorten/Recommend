//
//  CloseToMeMapViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/18/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "CloseToMeMapViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface CloseToMeMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *allLocationsMapView;

@end

@implementation CloseToMeMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (NSDictionary *recommendation in self.recommendationsArray) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        PFGeoPoint *point = [recommendation objectForKey:@"point"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);

        annotation.coordinate = coordinate;
        annotation.title = [[recommendation objectForKey:@"photo"] objectForKey:@"title"];
        annotation.subtitle = [[recommendation objectForKey:@"photo"] objectForKey:@"description"];

        [self.allLocationsMapView addAnnotation:annotation];
    }

    [self.allLocationsMapView showAnnotations:self.allLocationsMapView.annotations animated:YES];
}

@end
