//
//  DetailViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/18/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMapViewController.h"
#import "UserTableViewController.h"
#import "Recommendation.h"
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
    [self setTabBarVisible:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setTabBarVisible:YES animated:YES];
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
        UserTableViewController *vc = segue.destinationViewController;
        vc.recommendation = self.recommendation;
    } else {
        DetailMapViewController *vc = segue.destinationViewController;
        vc.recommendation = self.recommendation;
    }
    [self setTabBarVisible:YES animated:YES];
}

// a param to describe the state change, and an animated flag
// optionally add a completion block which matches UIView animation
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {

    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;

    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;

    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;

    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

@end
