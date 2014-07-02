//
//  ViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "DetailViewController.h"
#import "ParseRecommendation.h"
#import "Recommendation.h"
#import "RecommendationsCollectionViewCell.h"
#import "SWRevealViewController.h"
#import "NSDate+TimeAgo.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, RecommendationDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITabBarControllerDelegate, UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *placeButton;
@property (weak, nonatomic) IBOutlet UIButton *closePickerButton;
@property (weak, nonatomic) IBOutlet UIPickerView *placePickerView;
@property NSMutableArray *pickerPlacesArray;
@property (weak, nonatomic) IBOutlet UIView *placeView;
@property NSMutableArray *popularArray;
@property NSMutableArray *recentArray;
@property NSInteger recentArrayCount;
@property NSInteger popularArrayCount;
@property Recommendation *newestRecommendations;
@property Recommendation *popularRecommendations;
@property UIRefreshControl *recentRefreshControl;
@property UIRefreshControl *popularRefreshControl;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *locationNotFoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *noRecommendationsLabel;
@property NSMutableDictionary *categoriesDictionary;
@property NSString *userLocationString;
@end

@implementation HomeViewController

- (void)viewDidLoad

{
    [super viewDidLoad];

    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);


    [self.view setBackgroundColor:RGBA(177,177,177, 0.9)];
    [self.placeView setBackgroundColor:RGBA(255, 255, 255, 0.6)];

    self.recentRefreshControl = [[UIRefreshControl alloc] init];
    self.recentRefreshControl.tintColor = [UIColor lightGrayColor];
    [self.recentRefreshControl addTarget:self action:@selector(reloadNew) forControlEvents:UIControlEventValueChanged];
    [self.newestCollectionView addSubview:self.recentRefreshControl];
    self.newestCollectionView.alwaysBounceVertical = YES;

    [self.recentRefreshControl setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin)];
    [[self.recentRefreshControl.subviews objectAtIndex:0] setFrame:CGRectMake(65, 55, 30, 30)];


    self.popularRefreshControl = [[UIRefreshControl alloc] init];
    self.recentRefreshControl.tintColor = [UIColor lightGrayColor];
    [self.popularRefreshControl addTarget:self action:@selector(reloadPopular) forControlEvents:UIControlEventValueChanged];
    [self.popularCollectionView addSubview:self.popularRefreshControl];
    self.popularCollectionView.alwaysBounceVertical = YES;

    [self.popularRefreshControl setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin)];
    [[self.popularRefreshControl.subviews objectAtIndex:0] setFrame:CGRectMake(65, 55, 30, 30)];

    self.popularRecommendations = [[Recommendation alloc] initWithIdentifier:@"popular"];
    self.popularRecommendations.delegate = self;

    self.newestRecommendations = [[Recommendation alloc] initWithIdentifier:@"new"];
    self.newestRecommendations.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = YES;

    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:nil forState:UIControlStateDisabled];

    self.recentArray = [NSMutableArray new];
    self.popularArray = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];



    if ([Recommendation getUserSelectedLocation]) {
        [self reloadByCity:[Recommendation getUserSelectedLocation]];
    } else {
        [self reloadNew];
        [self reloadPopular];
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerPlacesArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerPlacesArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row == 0) {
        [self reloadNew];
        [self reloadPopular];
        [self.placeButton setTitle:[NSString stringWithFormat:@"Close to you in %@", self.userLocationString] forState:UIControlStateNormal];
        [Recommendation setNewLocation:nil];
    } else {
        [self reloadByCity:[self.pickerPlacesArray objectAtIndex:row]];
    }
}

- (IBAction)onClosePlacePressed:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.placeView.alpha = 0;
    }];
}

- (void)reloadNew {
    [self.newestRecommendations reset];
    [self.newestRecommendations getRecommendations:270 withinRadius:50];
}

- (void)reloadPopular {
    [self.popularRecommendations reset];
    [self.popularRecommendations getRecommendations:270 withinRadius:50 orderByDescending:@"numLikes"];
}

- (void)reloadByCity:(NSString *)city
{
    [self.newestRecommendations reset];
    [self.popularRecommendations reset];
    [self.recentArray removeAllObjects];
    [self.popularArray removeAllObjects];
    [self.newestRecommendations getRecommendations:100 whereKey:@"city" equalTo:city];
    [self.popularRecommendations getRecommendations:100 whereKey:@"city" equalTo:city  orderByDescending:@"numLikes"];
    [self.placeButton setTitle:[NSString stringWithFormat:@"In %@", city] forState:UIControlStateNormal];
    [Recommendation setNewLocation:city];
}

- (IBAction)onPlaceButtonPressed:(id)sender
{
    [Recommendation getLocations:^(NSArray *locations) {
        self.pickerPlacesArray = [[NSMutableArray alloc] initWithArray:locations];
        [self.placePickerView reloadAllComponents];
        [UIView animateWithDuration:0.2 animations:^{
            self.placeView.alpha = 1;
        }];
    }];
}

- (void)userLocationFound:(PFGeoPoint *)geoPoint
{
    if (geoPoint) {
        self.locationNotFoundLabel.hidden = YES;
        self.noRecommendationsLabel.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.errorView.alpha = 0;
        }];
        [self.newestRecommendations reverseGeocode:geoPoint onComplete:^(NSMutableDictionary *address) {
                if (address) {
                    NSString *where = [address objectForKey:@"city"] ? [address objectForKey:@"city"] : [address objectForKey:@"street"];
                    self.userLocationString = where;
                    [self.placeButton setTitle:[NSString stringWithFormat:@"Close to you in %@", self.userLocationString] forState:UIControlStateNormal];
                }
        }];
    } else {
        [self.placeButton setTitle:@"Choose location" forState:UIControlStateNormal];
        self.locationNotFoundLabel.hidden = NO;
        self.noRecommendationsLabel.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.errorView.alpha = 0.6;
        }];
    }
}

- (void)onNoRecommendations:(bool)noRecommendations
{
    if (noRecommendations) {
        self.locationNotFoundLabel.hidden = YES;
        self.noRecommendationsLabel.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.errorView.alpha = 0.6;
        }];
    } else {
        self.locationNotFoundLabel.hidden = YES;
        self.noRecommendationsLabel.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.errorView.alpha = 0;
        }];
    }
}

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location
{
    if (!recommendations) {
        [self.recentRefreshControl endRefreshing];
        [self.popularRefreshControl endRefreshing];
        return;
    }
    if ([identifier isEqualToString:@"new"]) {
        [self.recentArray removeAllObjects];
        self.recentArrayCount = recommendations.count;
        [self.recentArray addObjectsFromArray:recommendations];
        [self.newestCollectionView reloadData];
        [self.recentRefreshControl endRefreshing];
    }
    if ([identifier isEqualToString:@"popular"]) {
        [self.popularArray removeAllObjects];
        self.popularArrayCount = recommendations.count;
        [self.popularArray addObjectsFromArray:recommendations];
        [self.popularCollectionView reloadData];
        [self.popularRefreshControl endRefreshing];
    }
}

#pragma mark - CollectionView Datasource/Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    long count;

    if ([collectionView isEqual:self.popularCollectionView]) {
        count = self.popularArray.count;
    }
    else if ([collectionView isEqual:self.newestCollectionView]){
        count = self.recentArray.count;
    }

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    RecommendationsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:([collectionView isEqual:self.newestCollectionView] ? @"New" : @"Popular") forIndexPath:indexPath];

    NSMutableArray *arrayToUse = [collectionView isEqual:self.newestCollectionView] ? self.recentArray : self.popularArray;

    ParseRecommendation *new = [arrayToUse objectAtIndex:indexPath.row];

    PFImageView *pfImageView = nil;
    for (UIView *subview in cell.contentView.subviews)
    {
        if ([subview isKindOfClass:[PFImageView class]])
        {
            pfImageView = (PFImageView *) subview;
            break;
        }
    }
    if (pfImageView == nil)
    {
        pfImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.frame.size.width)];
        [cell.contentView insertSubview:pfImageView belowSubview:cell.timeView];
    }

    pfImageView.contentMode = UIViewContentModeScaleAspectFill;
    pfImageView.clipsToBounds = YES;

    pfImageView.file = (PFFile *)new.thumbnail;
    [pfImageView loadInBackground];

    cell.timeLabel.text = [new.createdAt timeAgo];
    cell.titleLabel.text = new.title;
    cell.lovesLabel.text = new.numLikes > 0 ? (new.numLikes).description : @"0";

    cell.iconImageView.image = nil;
    UIImage *categoryIcon = [Recommendation getCategoryIcon:new.category];
    if (categoryIcon) {
        cell.iconImageView.image = categoryIcon;
    }

    UIBezierPath *path  = [UIBezierPath bezierPathWithRect:cell.bounds];
    cell.layer.shadowPath = [path CGPath];

    cell.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    cell.layer.shadowRadius = 1.0f;
    cell.layer.masksToBounds = NO;

    cell.alpha = 0.0f;

    [UIView transitionWithView:cell.contentView
                      duration:0.5f
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{

                        //any animatable attribute here.
                        cell.alpha = 1.0f;

                    } completion:^(BOOL finished) {
                    }];

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollOffset = scrollView.contentOffset.y;
}

- (void)viewDidLayoutSubviews {
    self.recommendationsScrollView.contentSize = CGSizeMake((self.newestCollectionView.frame.size.width + self.popularCollectionView.frame.size.width + 30), 1);
    [self.recommendationsScrollView setDirectionalLockEnabled:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UICollectionViewCell *)sender{

    DetailViewController *destination = [segue destinationViewController];


    if ([segue.identifier isEqualToString:@"NewestSegue"]) {
        NSIndexPath *selected = [self.newestCollectionView indexPathForCell:sender];
        destination.recommendation = [self.recentArray objectAtIndex:selected.row];
    }
    else if ([segue.identifier isEqualToString:@"PopularSegue"]){
        NSIndexPath *selected = [self.popularCollectionView indexPathForCell:sender];
        destination.recommendation = [self.popularArray objectAtIndex:selected.row];
    }

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{

}

@end
