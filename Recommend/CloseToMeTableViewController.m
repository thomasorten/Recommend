//
//  MapViewViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "CloseToMeTableViewController.h"
#import "MultipleRecommendationsMapViewController.h"
#import "DetailViewController.h"
#import "ParseRecommendation.h"
#import "Recommendation.h"
#import <Parse/Parse.h>

@interface CloseToMeTableViewController () <UITableViewDelegate, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, RecommendationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *closeToMeTableView;
@property NSArray *recommendationsArray;
@property NSMutableArray *allRecommendationsArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property PFGeoPoint *userLocation;
@property UIRefreshControl *refreshControl;
@property Recommendation *recommendations;
@end

@implementation CloseToMeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.recommendations = [[Recommendation alloc] init];
    self.recommendations.delegate = self;

    [self getRecommendationsCloseToUser];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.closeToMeTableView addSubview:self.refreshControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.closeToMeTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchCell"];
    NSDictionary *recommendation = [self.recommendationsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [recommendation objectForKey:@"title"];
    cell.detailTextLabel.text = [recommendation objectForKey:@"description"];

    PFFile *image = [recommendation objectForKey:@"file"];
    [image getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.imageView.image = [UIImage imageWithData:imageData];
        }
    }];

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
        MultipleRecommendationsMapViewController *destinationController = segue.destinationViewController;
        destinationController.recommendationsArray = self.recommendationsArray;
    }
}

- (void)getRecommendationsCloseToUser
{
    [self.recommendations getRecommendations:50 withinRadius:10];
}

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier
{
    self.recommendationsArray = recommendations;
    [self.closeToMeTableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([searchText isEqualToString:@""]) {
        [self.searchBar resignFirstResponder];
        [self getRecommendationsCloseToUser];
    } else {
        [self performSelector:@selector(doSearchQuery:) withObject:searchText afterDelay:0.5];
    }
}

- (void)doSearchQuery:(NSString *)searchString
{
    [self.recommendations getRecommendations:100 withinRadius:30 whereKey:@"title" containsString:searchString];
}

- (void)refresh:(id)sender
{
    [self getRecommendationsCloseToUser];
}

@end
