//
//  LocationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LocationViewController.h"
#import "TabBarViewController.h"
#import "Recommendation.h"
#import "ParseRecommendation.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LocationViewController () <CLLocationManagerDelegate,MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIView *categoryPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property NSMutableDictionary *categoriesDictionary;
@property NSMutableArray *categoriesArray;
@property NSString *chosenCategory;
@end

@implementation LocationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];

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

    [self.categoryPickerView setBackgroundColor:RGBA(255, 255, 255, 0.6)];
}

- (void)setupCategories
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        // Existst locally
        self.categoriesArray = [[NSMutableArray alloc] initWithContentsOfFile:[self dataFilePath]];
        [self.categoryPicker reloadAllComponents];
        [self attemptToAutoFillCategory];
    } else {
        [self fetchCategories];
    }
}

- (IBAction)onCategoryChoosePressed:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.categoryPickerView.alpha = 1;
    }];
}

- (IBAction)onCategoryPickerDonePressed:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.categoryPickerView.alpha = 0;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [(TabBarViewController *)self.tabBarController setTabBarVisible:NO animated:NO];
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [(TabBarViewController *)self.tabBarController setTabBarVisible:YES animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    for (CLLocation *current in locations) {
        if (current.horizontalAccuracy < 150 && current.verticalAccuracy < 150) {
            [self.locationManager stopUpdatingLocation];
            [self setMapViewRegion];
            [self setupCategories];
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
    newRecommend.category = self.chosenCategory;

    [newRecommend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            [Recommendation saveLocation:newRecommend.city];

            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recommendation Added!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self performSegueWithIdentifier:@"BackToMain" sender:self];

            NSLog(@"Success!");

        }
        else{

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS Something Went Wrong" message:nil delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alert show];
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            [self.setButton setHidden:NO];

            NSLog(@"Error");
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

- (void)addToCategory:(NSArray *)subCategory mainCategory:(NSString *)mainCategory
{
    for (NSDictionary *category in subCategory) {
        [[self.categoriesDictionary objectForKey:mainCategory] addObject:[category objectForKey:@"name"]];
        if ([category objectForKey:@"categories"]) {
            [self addToCategory:[category objectForKey:@"categories"] mainCategory:mainCategory];
        }
    }
}

- (void)fetchCategories
{
    NSURL *url = [NSURL URLWithString:@"https://api.foursquare.com/v2/venues/categories?client_id=YXWW5WMSINQCQLEMUYZSEPUC3OQWC4BSG3KA1CWJYHS4EOQW&client_secret=5ARBMRWGIW03LEFFT3TFFQMDWH0XMNQQZUHMZNYXZPQP35H1&v=20140729"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *categoryResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *categories = [[categoryResponse objectForKey:@"response"] objectForKey:@"categories"];
        self.categoriesDictionary = [[NSMutableDictionary alloc] init];
        for (NSDictionary *mainCategory in categories) {
            NSString *mainCategoryName = [mainCategory objectForKey:@"name"];
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            [self.categoriesDictionary setObject:subArray forKey:mainCategoryName];
            [self addToCategory:[mainCategory objectForKey:@"categories"] mainCategory:mainCategoryName];
        }
        NSMutableArray *categoriesArray = [[NSMutableArray alloc] init];
        for (id key in self.categoriesDictionary)
        {
            id value = [self.categoriesDictionary objectForKey:key];
            NSDictionary *category = [[NSMutableDictionary alloc] initWithObjects:@[key, value] forKeys:@[@"name", @"categories"]];
            [categoriesArray addObject:category];
        }
        [categoriesArray writeToFile:[self dataFilePath] atomically:YES];
        self.categoriesArray = categoriesArray;
        [self.categoryPicker reloadAllComponents];
        // Set default
        NSInteger row = 0;
        for (NSDictionary *category in self.categoriesArray) {
            if ([[category objectForKey:@"name"] isEqualToString:@"Residences"]) {
                break;
            }
            row ++;
        }
        [self.categoryPicker selectRow:row inComponent:0 animated:NO];
        [self attemptToAutoFillCategory];
    }];
}

- (void)attemptToAutoFillCategory
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=YXWW5WMSINQCQLEMUYZSEPUC3OQWC4BSG3KA1CWJYHS4EOQW&client_secret=5ARBMRWGIW03LEFFT3TFFQMDWH0XMNQQZUHMZNYXZPQP35H1&v=20140729", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *locationResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *venues = [[locationResponse objectForKey:@"response"] objectForKey:@"venues"];
        NSString *closestCategory;
        if (venues.count) {
            NSArray *categories = [[venues objectAtIndex:0] objectForKey:@"categories"];
            if (categories.count) {
                NSString *closestMatchSubCategory = [[categories objectAtIndex:0] objectForKey:@"name"];
                // Find match in array
                NSInteger row = 0;
                for (NSDictionary *category in self.categoriesArray) {
                    for (NSString *matchToCategory in [category objectForKey:@"categories"]) {
                        if ([closestMatchSubCategory isEqualToString:matchToCategory])
                        {
                            closestCategory = [category objectForKey:@"name"];
                            [self.categoryPicker selectRow:row inComponent:0 animated:NO];
                            [self.categoryButton setTitle:closestCategory forState:UIControlStateNormal];
                        }
                    }
                    row ++;
                }
            }
        }
    }];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"fsCat"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categoriesArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.categoriesArray objectAtIndex:row] objectForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *category = [[self.categoriesArray objectAtIndex:row] objectForKey:@"name"];
    self.chosenCategory = category;
    [self.categoryButton setTitle:category forState:UIControlStateNormal];
}

@end
