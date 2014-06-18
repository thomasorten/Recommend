//
//  LocationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController () <CLLocationManagerDelegate,MKMapViewDelegate>

@property CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LocationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator setHidden:YES];

    self.setButton.layer.cornerRadius = 5;
    self.imageView.image = [self.recommendation objectForKey:@"file"];
    self.titleLabel.text = [self.recommendation objectForKey:@"title"];
    self.descriptionLabel.text = [self.recommendation objectForKey:@"description"];

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
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];

    CLLocationCoordinate2D selectedLocation = [self.mapView centerCoordinate];

    PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];

    NSMutableDictionary *locationDictionary = [[NSMutableDictionary alloc] initWithObjects:@[location] forKeys:@[@"location"]];
    [self.recommendation addEntriesFromDictionary:locationDictionary];
    [self reverseGeocode:selectedLocation];
    NSData *imageData = UIImageJPEGRepresentation([self.recommendation objectForKey:@"file"], 0.7);
    PFFile *imageFile = [PFFile fileWithData:imageData];

    PFObject *newRecommend = [PFObject objectWithClassName:@"Photo"];
    newRecommend[@"creator"] = [PFUser currentUser];
    newRecommend[@"description"] = [self.recommendation objectForKey:@"description"];
    newRecommend[@"title"] = [self.recommendation objectForKey:@"title"];
    newRecommend[@"file"] = imageFile;

    PFObject *newLocation = [PFObject objectWithClassName:@"Location"];
    newLocation[@"point"] = [self.recommendation objectForKey:@"location"];
    newLocation[@"parent"] = newRecommend;

    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recomendation Added!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        NSLog(@"Sucess!");


        }
        else{

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS Something Went Wrong" message:nil delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alert show];
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            [self.setButton setHidden:NO];

            NSLog(@"Fuck");
        }
    }];

    


}


- (void)reverseGeocode:(CLLocationCoordinate2D)locationCord{

    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCord.latitude longitude:locationCord.longitude];

    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *addressPlacmark = [placemarks firstObject];
        NSString *street = [NSString stringWithFormat:@"%@ %@",addressPlacmark.subThoroughfare, addressPlacmark.thoroughfare];
        NSString *city = [NSString stringWithFormat:@"%@",addressPlacmark.locality];

        NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] initWithObjects:@[street, city] forKeys:@[@"street", @"city"]];

        [self.recommendation addEntriesFromDictionary:addressDictionary];
        NSLog(@"%@",self.recommendation);
    }];
}

@end
