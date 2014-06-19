//
//  DetailMapViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/18/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "DetailMapViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface DetailMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;
@end

@implementation DetailMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    PFGeoPoint *point = [self.recommendation objectForKey:@"point"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);

    annotation.coordinate = coordinate;
    annotation.title = [[self.recommendation objectForKey:@"photo"] objectForKey:@"title"];
    annotation.subtitle = [[self.recommendation objectForKey:@"photo"] objectForKey:@"description"];

    [self.detailMapView addAnnotation:annotation];

    [self.detailMapView showAnnotations:self.detailMapView.annotations animated:YES];
}

@end
