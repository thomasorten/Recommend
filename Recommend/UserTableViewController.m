//
//  UserTableViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/19/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "UserTableViewController.h"
#import "MultipleRecommendationsMapViewController.h"
#import <Parse/Parse.h>

@interface UserTableViewController ()
@property NSMutableArray *recommendationsArray;
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@end

@implementation UserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recommendationsArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"creator"];
    [query whereKey:@"creator" equalTo:[[self.recommendation objectForKey:@"photo"] objectForKey:@"creator"]];
    query.limit = 1000;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *recommendation in objects) {
                PFObject *photo = recommendation[@"parent"];
                [photo fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [self.recommendationsArray addObject:@{@"photo": photo, @"point": [recommendation objectForKey:@"point"]}];
                    [self.userTableView reloadData];
                }];
            }
        }
    }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRecommendationCell"];
    NSDictionary *recommendation = [self.recommendationsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[recommendation objectForKey:@"photo" ] objectForKey:@"title"];
    cell.detailTextLabel.text = [[recommendation objectForKey:@"photo" ] objectForKey:@"description"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MultipleRecommendationsMapViewController *destinationController = segue.destinationViewController;
    destinationController.recommendationsArray = self.recommendationsArray;
}

@end
