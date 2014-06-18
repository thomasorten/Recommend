//
//  LocationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@property CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation LocationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.setButton.layer.cornerRadius = 5;

    UIImageView *pinImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];
    [pinImage setCenter:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2 - pinImage.frame.size.height)];
    [self.mapView.superview addSubview:pinImage];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapView.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated{

    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    for (CLLocation *current in locations) {
        if (current.horizontalAccuracy < 150 && current.verticalAccuracy < 150) {
            [self.locationManager stopUpdatingLocation];
            [self setMapViewRegion];
            break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

    NSLog(@"%@",error);
}



- (void)setMapViewRegion{
    CLLocationCoordinate2D zoomCenter;
    zoomCenter = self.locationManager.location.coordinate;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomCenter, 500, 500);
    [self.mapView setRegion:viewRegion animated:YES];
}
- (IBAction)onSetButtonPressed:(id)sender {

    [self.setButton setHidden:YES];
    CLLocationCoordinate2D selectedLocation;
    selectedLocation = [self.mapView centerCoordinate];
    
    NSLog(@"%f,%f",selectedLocation.latitude, selectedLocation.longitude);
}

@end
