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

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface DetailViewController () <RecommendationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *recommendationImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIButton *personButton;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property Recommendation *currentRecommendation;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.addressButton setTintColor:RGB(2, 156, 188)];
    [self.personButton setTintColor:RGB(2, 156, 188)];

    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];

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

    // Get user profile image
    PFFile *profilePic = [[self.recommendation objectForKey:@"creator"] objectForKey:@"profilepic"];
    if (profilePic) {
        [profilePic getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                self.userProfileImageView.image = [UIImage imageWithData:imageData];
            }
        }];
    }

    // Icon
    UIImage *categoryIcon = [Recommendation getCategoryIcon:[self.recommendation objectForKey:@"category"]];
    if (categoryIcon) {
        self.iconImageView.image = categoryIcon;
    }

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

-(void)fadeinError
{
    self.errorMessageLabel.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    //don't forget to add delegate.....
    [UIView setAnimationDelegate:self];

    [UIView setAnimationDuration:0.5];
    self.errorMessageLabel.alpha = 1;

    //also call this before commit animations......
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:4];
    self.errorMessageLabel.alpha = 0;
    [UIView commitAnimations];
}

-(void)recommendationLoved:(NSString *)error count:(NSNumber *)count recommendation:(PFObject *)recommendation
{
    if (!error) {
        self.likesLabel.text = [NSString stringWithFormat:@"%@", count];
    } else {
        self.errorMessageLabel.text = error;
        [self fadeinError];
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
