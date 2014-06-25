//
//  ViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import "ParseRecommendation.h"
#import "Recommendation.h"
#import "RecommendationsCollectionViewCell.h"
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, RecommendationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *newestCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *popularCollectionView;
@property NSMutableArray *popularArray;
@property NSMutableArray *recentArray;
@property NSInteger recentArrayCount;
@property NSInteger popularArrayCount;
@property Recommendation *newestRecommendations;
@property Recommendation *popularRecommendations;
@property UIRefreshControl *recentRefreshControl;
@property UIRefreshControl *popularRefreshControl;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@end

@implementation HomeViewController

- (void)viewDidLoad

{
    [super viewDidLoad];

    [self.view setBackgroundColor:RGB(224,224,224)];

    self.recentRefreshControl = [[UIRefreshControl alloc] init];
    self.recentRefreshControl.tintColor = [UIColor grayColor];
    [self.recentRefreshControl addTarget:self action:@selector(reloadNew) forControlEvents:UIControlEventValueChanged];
    [self.newestCollectionView addSubview:self.recentRefreshControl];
    self.newestCollectionView.alwaysBounceVertical = YES;

    self.popularRefreshControl = [[UIRefreshControl alloc] init];
    self.recentRefreshControl.tintColor = [UIColor grayColor];
    [self.popularRefreshControl addTarget:self action:@selector(reloadPopular) forControlEvents:UIControlEventValueChanged];
    [self.popularCollectionView addSubview:self.popularRefreshControl];
    self.popularCollectionView.alwaysBounceVertical = YES;

    self.popularRecommendations = [[Recommendation alloc] initWithIdentifier:@"popular"];
    self.popularRecommendations.delegate = self;

    self.newestRecommendations = [[Recommendation alloc] initWithIdentifier:@"new"];
    self.newestRecommendations.delegate = self;

    self.recentArray = [NSMutableArray new];
    self.popularArray = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadNew];
    [self reloadPopular];
}

-(void)reloadNew {
    [self.newestRecommendations getRecommendations:100 withinRadius:50];
}

-(void)reloadPopular {
    [self.popularRecommendations getRecommendations:100 withinRadius:50 orderByDescending:@"numLikes"];
}


-(void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location
{
    if (!recommendations) {
        [self.recentRefreshControl endRefreshing];
        [self.popularRefreshControl endRefreshing];
        return;
    }
    if ([identifier isEqualToString:@"new"]) {
        self.recentArrayCount = recommendations.count;
        [self.recentArray addObjectsFromArray:recommendations];
        [self.newestCollectionView reloadData];
        [self.recentRefreshControl endRefreshing];
    }
    if ([identifier isEqualToString:@"popular"]) {
        self.popularArrayCount = recommendations.count;
        [self.popularArray addObjectsFromArray:recommendations];
        [self.popularCollectionView reloadData];
        [self.popularRefreshControl endRefreshing];
    }
    [Recommendation reverseGeocode:location onComplete:^(NSMutableDictionary *address) {
        self.placeLabel.text = [NSString stringWithFormat:@"%@, %@", [address objectForKey:@"street"], [address objectForKey:@"city"]];
    }];
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
        pfImageView = [[PFImageView alloc] initWithFrame:CGRectMake(5, 5, cell.contentView.frame.size.width-10, cell.frame.size.height-10)];
        [cell.contentView addSubview:pfImageView];
    }

    pfImageView.file = (PFFile *)new.file;
    [pfImageView loadInBackground];

    UIBezierPath *path  = [UIBezierPath bezierPathWithRect:cell.bounds];
    cell.layer.shadowPath = [path CGPath];

    cell.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.layer.shadowOpacity = 0.6f;
    cell.layer.shadowOffset = CGSizeMake(-1.0f, 1.0f);
    cell.layer.shadowRadius = 0.6f;
    cell.layer.masksToBounds = NO;

    return cell;
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
