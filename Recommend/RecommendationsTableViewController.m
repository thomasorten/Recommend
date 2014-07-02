//
//  MapViewViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "RecommendationsTableViewController.h"
#import "DetailMapViewController.h"
#import "DetailViewController.h"
#import "ParseRecommendation.h"
#import "Recommendation.h"
#import <Parse/Parse.h>
#import "SWRevealViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface RecommendationsTableViewController () <UITableViewDelegate, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, RecommendationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *closeToMeTableView;
@property NSMutableArray *recommendationsArray;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapViewButton;
@property NSMutableArray *allRecommendationsArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property PFGeoPoint *userLocation;
@property UIRefreshControl *refreshControl;
@property Recommendation *recommendations;
@property NSNumberFormatter *distanceFormatter;
@property NSInteger loadedRecommendations;
@property int initialNumberOfRecommendations;
@end

@implementation RecommendationsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapViewButton.tintColor = RGBA(2, 156, 188, 0);
    self.mapViewButton.enabled = NO;

    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);

    self.initialNumberOfRecommendations = 12;

    self.distanceFormatter = [[NSNumberFormatter alloc] init];
    [self.distanceFormatter setMaximumFractionDigits:1];
    [self.distanceFormatter setMinimumIntegerDigits:1];
    [self.distanceFormatter setRoundingMode: NSNumberFormatterRoundDown];

    self.recommendations = [[Recommendation alloc] init];
    self.recommendations.delegate = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.closeToMeTableView addSubview:self.refreshControl];

    self.recommendationsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self getTableData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.loadedRecommendations < self.initialNumberOfRecommendations ? self.recommendationsArray.count : self.recommendationsArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchCell"];

    if(indexPath.row == self.recommendationsArray.count)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Loading...";
        cell.imageView.image = nil;
        cell.detailTextLabel.text = nil;
       [self performSelector:@selector(getTableData) withObject:nil afterDelay:0.1];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ParseRecommendation *recommendation = [self.recommendationsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = recommendation.title;
        if (self.userLocation) {
            double distanceInKm = [self.userLocation distanceInKilometersTo:recommendation.point];
            NSString *numberString = [self.distanceFormatter stringFromNumber:[NSNumber numberWithFloat:distanceInKm]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %@ km", numberString];
        } else {
            cell.detailTextLabel.text = [recommendation objectForKey:@"description"];
        }
        PFFile *userImageFile = recommendation.thumbnail;
        if (userImageFile) {
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    cell.imageView.image = [[UIImage alloc] initWithData:imageData];
                    [cell setNeedsLayout];
                }
            }];
        } else {
            cell.imageView.image = nil;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TableToDetailSegue"]) {
        DetailViewController *destinationController = segue.destinationViewController;
        NSIndexPath *selectedRow = [self.closeToMeTableView indexPathForSelectedRow];
        destinationController.recommendation = [self.recommendationsArray objectAtIndex:selectedRow.row];
    }
    if ([segue.identifier isEqualToString:@"TableToMapSegue"]) {
        DetailMapViewController *destinationController = segue.destinationViewController;
        destinationController.recommendationsArray = self.recommendationsArray;
    }
}

- (void)getTableData
{
    if (self.recommendation) {
        [self getRecommendationsOfSpecificUser];
    } else if ([Recommendation getUserSelectedLocation]) {
        [self getRecommendationsByLocation];
    } else {
        [self getRecommendationsCloseToUser];
    }
}

- (void)getRecommendationsOfSpecificUser
{
    [self.recommendations getRecommendations:-1 byUser:[self.recommendation objectForKey:@"creator"]];
}

- (void)getRecommendationsCloseToUser
{
    [self.recommendations getRecommendationsByDistance:self.initialNumberOfRecommendations withinRadius:50];
}

- (void)getRecommendationsByLocation
{
    [self.recommendations getRecommendations:self.initialNumberOfRecommendations whereKey:@"city" equalTo:[Recommendation getUserSelectedLocation]];
}

- (void)userLocationFound:(PFGeoPoint *)geoPoint
{
    self.userLocation = geoPoint;
}

- (void)onNoRecommendations:(bool)noRecommendations
{
    //
}

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location
{
    self.loadedRecommendations = recommendations.count;
    [self.recommendationsArray addObjectsFromArray:recommendations];
    [self.closeToMeTableView reloadData];
    [self.refreshControl endRefreshing];
    if (recommendations.count > 0) {
        self.mapViewButton.tintColor = RGBA(255, 255, 255, 1);
        self.mapViewButton.enabled = YES;
    }
}

- (void)resetSearch
{
    [self.searchBar resignFirstResponder];
    self.recommendationsArray = [[NSMutableArray alloc] init];
    [self getTableData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([searchText isEqualToString:@""]) {
        [self resetSearch];
    }
    if ([searchText length] > 1) {
        [self performSelector:@selector(doSearchQuery:) withObject:searchText afterDelay:0.5];
    }
}

- (void)doSearchQuery:(NSString *)searchString
{
     self.recommendationsArray = [[NSMutableArray alloc] init];
    [self.recommendations reset];
    if (self.recommendation) {
        [self.recommendations getRecommendations:0 byUser:[self.recommendation objectForKey:@"creator"] whereKey:@"title" containsString:searchString];
    } else {
        [self.recommendations getRecommendations:0 whereKey:@"title" containsString:searchString];
    }
}

- (void)refresh:(id)sender
{
    [self getTableData];
}

@end
