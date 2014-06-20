//
//  CloseToMeMapViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/18/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "MultipleRecommendationsMapViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface MultipleRecommendationsMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *allLocationsMapView;

@end

@implementation MultipleRecommendationsMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.allLocationsMapView.delegate = self;

    for (NSDictionary *recommendation in self.recommendationsArray) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];

        PFGeoPoint *point = [recommendation objectForKey:@"point"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);

        annotation.coordinate = coordinate;
        annotation.title = [recommendation objectForKey:@"title"];
        annotation.subtitle = [recommendation objectForKey:@"description"];

        [self.allLocationsMapView addAnnotation:annotation];
    }

    [self.allLocationsMapView showAnnotations:self.allLocationsMapView.annotations animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"RecommendationPin"];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];

    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    annView.image = nil;

    [annView addSubview:imageView];
    return annView;
}

@end
