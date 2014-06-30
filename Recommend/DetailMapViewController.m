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
#import "Recommendation.h"

@interface DetailMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;

@property CLLocationManager *locationManager;

@end

@implementation DetailMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];

    self.detailMapView.delegate = self;
    [self.detailMapView setShowsUserLocation:YES];

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

- (void)viewWillAppear:(BOOL)animated{

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    for (CLLocation *current in locations) {
        if (current.horizontalAccuracy < 150 && current.verticalAccuracy < 150) {
            [self.locationManager stopUpdatingLocation];
            [self setMapRegion];
            break;
        }
    }
}

- (void)setMapRegion{
    CLLocationCoordinate2D zoomCenter = self.locationManager.location.coordinate;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomCenter, 500, 500);
    [self.detailMapView setRegion:viewRegion animated:YES];
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
