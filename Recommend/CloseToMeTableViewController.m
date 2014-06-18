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

@interface CloseToMeTableViewController () <UITableViewDelegate, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *closeToMeTableView;
@property CLLocationManager *locationManager;
@property NSMutableArray *matchesArray;
@end

@implementation CloseToMeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchCell"];
    NSDictionary *recommendation = [self.matchesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [recommendation objectForKey:@"title"];
    cell.detailTextLabel.text = [recommendation objectForKey:@"description"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TableToDetailSegue"]) {
        DetailViewController *destinationController = segue.destinationViewController;
        NSIndexPath *selectedRow = [self.closeToMeTableView indexPathForSelectedRow];
        destinationController.recommendation = [self.matchesArray objectAtIndex:selectedRow.row];
    }
    if ([segue.identifier isEqualToString:@"TableToMapSegue"]) {
        CloseToMeMapViewController *destinationController = segue.destinationViewController;
        destinationController.matchesArray = self.matchesArray;
    }
}

@end
