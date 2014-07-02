//
//  MyLikes.m
//  Recommend
//
//  Created by Dan Rudolf on 7/2/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "MyLikes.h"
#import "RecommendationsCollectionViewCell.h"
#import "SWRevealViewController.h"
#import "Recommendation.h"
#import "NSDate+TimeAgo.h"
#import "DetailViewController.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


@interface MyLikes () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RecommendationDelegate>

@property NSMutableArray *myLikes;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MyLikes

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myLikes = [NSMutableArray new];
    _showMenu.target = self.revealViewController;
    _showMenu.action = @selector(revealToggle:);

        [self.view setBackgroundColor:RGBA(177,177,177, 0.9)];

    Recommendation *myrecommendations = [[Recommendation alloc] init];
    [myrecommendations getRecommendations:30 thatUserHasLiked:[PFUser currentUser]];
    myrecommendations.delegate = self;

}

-(void)onNoRecommendations:(bool)noRecommendations
{

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)likesLoaded:(NSArray *)likes
{
    for (NSDictionary *love in likes) {
        PFObject *recommendation =[love objectForKey:@"recommendation"];
        recommendation[@"creator"] = [love objectForKey:@"user"];
        [self.myLikes addObject:recommendation];
    }
    
    [self.collectionView reloadData];
}


#pragma Mark - CollectionView Datasource/Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.myLikes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    RecommendationsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Like" forIndexPath:indexPath];
    ParseRecommendation *new = [self.myLikes objectAtIndex:indexPath.row];

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
    if ([segue.identifier isEqualToString:@"UserLiked"]) {
        DetailViewController *detailView = [[DetailViewController alloc] init];
        detailView = segue.destinationViewController;
        detailView.recommendation = [self.myLikes objectAtIndex:selected.row];
    }
}



@end
