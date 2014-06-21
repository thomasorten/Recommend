//
//  DetailViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/18/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMapViewController.h"
#import "RecommendationsTableViewController.h"
#import "Recommendation.h"
#import "TabBarViewController.h"
#import <Parse/Parse.h>

@interface DetailViewController () <RecommendationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *recommendationImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIButton *personButton;
@property Recommendation *currentRecommendation;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentRecommendation = [[Recommendation alloc] init];
    self.currentRecommendation.delegate = self;

    self.titleLabel.text = [self.recommendation objectForKey:@"title"];
    self.descriptionLabel.text = [self.recommendation objectForKey:@"description"];
    [self.personButton setTitle: [[self.recommendation objectForKey:@"creator"] objectForKey:@"username"] forState:UIControlStateNormal];

    if ([self.recommendation objectForKey:@"numLikes"]) {
        NSNumber *numLikes = [self.recommendation objectForKey:@"numLikes"];
        self.likesLabel.text = [NSString stringWithFormat:@"%@", numLikes];
    }

    if ([self.recommendation objectForKey:@"street"]) {
        [self.addressButton setTitle:[NSString stringWithFormat:@"%@, %@", [self.recommendation objectForKey:@"street"], [self.recommendation objectForKey:@"city"]] forState:UIControlStateNormal];
    }

    // Get image file
    PFFile *userImageFile = [self.recommendation objectForKey:@"file"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.recommendationImageView.image = [UIImage imageWithData:imageData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
   [(TabBarViewController *)self.tabBarController setTabBarVisible:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [(TabBarViewController *)self.tabBarController setTabBarVisible:YES animated:YES];
}

- (IBAction)onRecommendButtonPressed:(id)sender
{
    [self.currentRecommendation love:self.recommendation];
}

- (IBAction)onLocationButtonPressed:(id)sender
{

}

- (IBAction)onPersonPressed:(id)sender
{

}

-(void)recommendationLoved:(NSString *)error count:(NSNumber *)count recommendation:(PFObject *)recommendation
{
    if (!error) {
        self.likesLabel.text = [NSString stringWithFormat:@"%@", count];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailToTableViewSegue"]) {
        RecommendationsTableViewController *vc = segue.destinationViewController;
        vc.recommendation = self.recommendation;
    } else {
        DetailMapViewController *vc = segue.destinationViewController;
        vc.recommendationsArray = @[self.recommendation];
    }
    [(TabBarViewController *)self.tabBarController setTabBarVisible:YES animated:YES];
}

@end
