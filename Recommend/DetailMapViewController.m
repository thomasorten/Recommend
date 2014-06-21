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

@interface DetailMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;
@end

@implementation DetailMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.detailMapView.delegate = self;

    for (PFObject *recommendation in self.recommendationsArray) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        PFGeoPoint *point = [recommendation objectForKey:@"point"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);

        annotation.coordinate = coordinate;
        annotation.title = [recommendation objectForKey:@"title"];
        annotation.subtitle = [recommendation objectForKey:@"description"];

        [self.detailMapView addAnnotation:annotation];
    }

    [self.detailMapView showAnnotations:self.detailMapView.annotations animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"RecommendationPin"];

    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];

    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    annView.image = nil;

    [annView addSubview:imageView];
    return annView;
}

@end
