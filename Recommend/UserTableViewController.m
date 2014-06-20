//
//  UserTableViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/19/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "UserTableViewController.h"
#import "MultipleRecommendationsMapViewController.h"
#import "DetailViewController.h"
#import "ParseRecommendation.h"
#import "Recommendation.h"
#import <Parse/Parse.h>

@interface UserTableViewController () <RecommendationDelegate>
@property NSMutableArray *recommendationsArray;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@end

@implementation UserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recommendationsArray = [[NSMutableArray alloc] init];

    Recommendation *userRecommendations = [[Recommendation alloc] init];
    userRecommendations.delegate = self;

    [userRecommendations getRecommendations:-1 byUser:[self.recommendation objectForKey:@"creator"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.userTableView reloadData];
}

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier
{
    [self.recommendationsArray addObjectsFromArray:recommendations];
    [self.userTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recommendationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRecommendationCell"];
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
    if ([segue.identifier isEqualToString:@"UserTableToDetailSegue"]) {
        DetailViewController *destinationController = segue.destinationViewController;
        NSIndexPath *selectedRow = [self.userTableView indexPathForSelectedRow];
        destinationController.recommendation = [self.recommendationsArray objectAtIndex:selectedRow.row];
    }
    if ([segue.identifier isEqualToString:@"UserTableToMapSegue"]) {
        MultipleRecommendationsMapViewController *destinationController = segue.destinationViewController;
        destinationController.recommendationsArray = self.recommendationsArray;
    }
}

@end
