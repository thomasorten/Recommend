//
//  LocationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LocationViewController.h"
#import "ParseRecommendation.h"

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

}

- (void)uploadData{

    NSData *imageData = [self compressImage:[self.recommendation objectForKey:@"file"] width:720 height:1280];
    PFFile *imageFile = [PFFile fileWithData:imageData];

    NSData *thumbData = [self compressImage:[self.recommendation objectForKey:@"file"] width:180 height:320];
    PFFile *thumbFile = [PFFile fileWithData:thumbData];

    ParseRecommendation *newRecommend = [ParseRecommendation object];
    newRecommend.creator = [PFUser currentUser];
    newRecommend.description = [self.recommendation objectForKey:@"description"];
    newRecommend.title = [self.recommendation objectForKey:@"title"];
    newRecommend.file = imageFile;
    newRecommend.thumbnail = thumbFile;
    newRecommend.point = [self.recommendation objectForKey:@"location"];
    newRecommend.street = [self.recommendation objectForKey:@"street"];
    newRecommend.city = [self.recommendation objectForKey:@"city"];

    [newRecommend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recommendation Added!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self performSegueWithIdentifier:@"BackToMain" sender:self];

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

- (NSData *)compressImage:(UIImage *)image width:(float)width height:(float)height {
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = height;
    float maxWidth = width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.4;//40 percent compression

    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }

    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();

    return imageData;
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
        [self uploadData];
        NSLog(@"%@",self.recommendation);
    }];
}

@end
