//
//  MapViewViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "CloseToMeTableViewController.h"
#import "CloseToMeMapViewController.h"
#import "DetailViewController.h"
#import <Parse/Parse.h>

@interface CloseToMeTableViewController () <UITableViewDelegate, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *closeToMeTableView;
@property NSMutableArray *recommendationsArray;
@property NSMutableArray *allRecommendationsArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property PFGeoPoint *userLocation;
@end

@implementation CloseToMeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allRecommendationsArray = [[NSMutableArray alloc] init];
    self.recommendationsArray = [[NSMutableArray alloc] init];
    [self locateUser];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchCell"];
    NSDictionary *recommendation = [self.recommendationsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[recommendation objectForKey:@"photo" ] objectForKey:@"title"];
    cell.detailTextLabel.text = [[recommendation objectForKey:@"photo" ] objectForKey:@"description"];
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
        CloseToMeMapViewController *destinationController = segue.destinationViewController;
        destinationController.recommendationsArray = self.recommendationsArray;
    }
}

- (void)locateUser
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.userLocation = geoPoint;
            PFQuery *query = [PFQuery queryWithClassName:@"Location"];
            [query includeKey:@"parent"];
            [query whereKey:@"point" nearGeoPoint:geoPoint withinKilometers:10];
            query.limit = 50;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *recommendation in objects) {
                        PFObject *photo = recommendation[@"parent"];
                        [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            [self.recommendationsArray addObject:@{@"photo": photo, @"point": [recommendation objectForKey:@"point"]}];
                            [self.allRecommendationsArray addObject:@{@"photo": photo, @"point" : [recommendation objectForKey:@"point"]}];
                            [self.closeToMeTableView reloadData];
                        }];
                    }
                }
            }];
        }
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([searchText isEqualToString:@""]) {
        [self.searchBar resignFirstResponder];
        self.recommendationsArray = self.allRecommendationsArray;
        [self.closeToMeTableView reloadData];
    } else {
        [self performSelector:@selector(doSearchQuery:) withObject:searchText afterDelay:0.3];
    }
}

- (void)doTheQuery:(PFQuery *)query
{
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.recommendationsArray = [[NSMutableArray alloc] initWithArray:objects];
            for (PFObject *recommendation in objects) {
                PFObject *photo = recommendation[@"parent"];
                [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [self.recommendationsArray addObject:@{@"photo": photo, @"point" : [recommendation objectForKey:@"point"]}];
                    [self.allRecommendationsArray addObject:@{@"photo": photo, @"point" : [recommendation objectForKey:@"point"]}];
                    [self.closeToMeTableView reloadData];
                }];
            }
        }
    }];
}

- (void)doSearchQuery:(NSString *)searchString
{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query includeKey:@"parent"];
    [query whereKey:@"point" nearGeoPoint:self.userLocation withinKilometers:50];
    query.limit = 100;
    [self doTheQuery:query];
}

@end
