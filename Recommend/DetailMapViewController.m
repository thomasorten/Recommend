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


    MKPointAnnotation *mapRecommendation = [[MKPointAnnotation alloc] init];
    PFGeoPoint *point = [self.recommendation objectForKey:@"location"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);

    mapRecommendation.coordinate = coordinate;
    mapRecommendation.title = [self.recommendation objectForKey:@"title"];
    mapRecommendation.subtitle = [self.recommendation objectForKey:@"description"];

    [self.detailMapView addAnnotation:mapRecommendation];

    [self.detailMapView showAnnotations:self.detailMapView.annotations animated:YES];
}

@end
