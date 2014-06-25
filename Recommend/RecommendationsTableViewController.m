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

@interface RecommendationsTableViewController () <UITableViewDelegate, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, RecommendationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *closeToMeTableView;
@property NSMutableArray *recommendationsArray;
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
    [self getTableData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)userLocationFound:(PFGeoPoint *)geoPoint
{
    //
}

- (void)onNoRecommendations:(bool)noRecommendations
{
    //
}

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location
{
    self.userLocation = location;
    self.loadedRecommendations = recommendations.count;
    [self.recommendationsArray addObjectsFromArray:recommendations];
    [self.closeToMeTableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([searchText isEqualToString:@""]) {
        [self.searchBar resignFirstResponder];
        [self getTableData];
    } else {
        [self performSelector:@selector(doSearchQuery:) withObject:searchText afterDelay:0.5];
    }
}

- (void)doSearchQuery:(NSString *)searchString
{
    if (self.recommendation) {
        [self.recommendations getRecommendations:-1 byUser:[self.recommendation objectForKey:@"creator"] whereKey:@"title" containsString:searchString];
    } else {
        [self.recommendations getRecommendations:100 withinRadius:30 whereKey:@"title" containsString:searchString];
    }
}

- (void)refresh:(id)sender
{
    [self getTableData];
}

@end
