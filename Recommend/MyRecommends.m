//
//  MyProfileVC.m
//  Recommend
//
//  Created by Dan Rudolf on 7/1/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "MyRecommends.h"
#import "RecommendationsCollectionViewCell.h"
#import "SWRevealViewController.h"
#import "Recommendation.h"
#import "NSDate+TimeAgo.h"
#import "DetailViewController.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface MyRecommends () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RecommendationDelegate>

@property NSMutableArray *myRecommends;
@property UIRefreshControl *pullRefresh;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MyRecommends

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myRecommends = [NSMutableArray new];
    _showMenu.target = self.revealViewController;
    _showMenu.action = @selector(revealToggle:);

    [self.view setBackgroundColor:RGB(211,211,211)];

    [self refresh];

    self.pullRefresh = [[UIRefreshControl alloc] init];
    [self.pullRefresh addTarget:self
                     action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.pullRefresh];
    
}

- (void)refresh{
    Recommendation *myrecommendations = [[Recommendation alloc] init];
    [myrecommendations getRecommendations:30 byUser:[PFUser currentUser]];
    myrecommendations.delegate = self;
}

-(void)onNoRecommendations:(bool)noRecommendations
{

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location
{
    [self.myRecommends addObjectsFromArray:recommendations];
    [self.collectionView reloadData];
    [self.pullRefresh endRefreshing];
}


#pragma Mark - CollectionView Datasource/Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.myRecommends.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    RecommendationsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"New" forIndexPath:indexPath];
    ParseRecommendation *new = [self.myRecommends objectAtIndex:indexPath.row];
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
    cell.layer.shadowOpacity = 0.6f;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    cell.layer.shadowRadius = 0.6f;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSIndexPath *selected = [[self.collectionView indexPathsForSelectedItems] firstObject];
    if ([segue.identifier isEqualToString:@"UserAdded"]) {
        DetailViewController *detailView = [[DetailViewController alloc] init];
        detailView = segue.destinationViewController;
        detailView.recommendation = [self.myRecommends objectAtIndex:selected.row];
    }
}

@end
