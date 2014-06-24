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

@property (weak, nonatomic) IBOutlet UICollectionView *newestCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *popularCollectionView;
@property NSMutableArray *popularArray;
@property NSMutableArray *recentArray;
@property NSInteger recentArrayCount;
@property NSInteger popularArrayCount;
@property Recommendation *newestRecommendations;
@property Recommendation *popularRecommendations;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@end

@implementation HomeViewController

- (void)viewDidLoad

{
    [super viewDidLoad];

    [self.view setBackgroundColor:RGB(224,224,224)];

    self.popularRecommendations = [[Recommendation alloc] initWithIdentifier:@"popular"];
    self.popularRecommendations.delegate = self;

    self.newestRecommendations = [[Recommendation alloc] initWithIdentifier:@"new"];
    self.newestRecommendations.delegate = self;

    self.recentArray = [NSMutableArray new];
    self.popularArray = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;

//
//    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
//        if (!error) {
//            NSLog(@"Using Recommend as Anonymous");
//        }
//        else{
//            NSLog(@"error logging in");
//        }
//    }];


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
    if ([identifier isEqualToString:@"new"]) {
        self.recentArrayCount = recommendations.count;
        [self.recentArray addObjectsFromArray:recommendations];
        [self.newestCollectionView reloadData];
    }
    if ([identifier isEqualToString:@"popular"]) {
        self.popularArrayCount = recommendations.count;
        [self.popularArray addObjectsFromArray:recommendations];
        [self.popularCollectionView reloadData];
    }
}

#pragma mark - CollectionView Datasource/Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    long count;

    if ([collectionView isEqual:self.popularCollectionView]) {
        count = self.popularArrayCount < 10 ? self.popularArray.count : self.popularArray.count+1;
    }
    else if ([collectionView isEqual:self.newestCollectionView]){
        count = self.recentArrayCount < 10 ? self.recentArray.count : self.recentArray.count+1;
    }

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    RecommendationsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:([collectionView isEqual:self.newestCollectionView] ? @"New" : @"Popular") forIndexPath:indexPath];

    NSMutableArray *arrayToUse = [collectionView isEqual:self.newestCollectionView] ? self.recentArray : self.popularArray;

    if(indexPath.row > arrayToUse.count) {
        return nil;
    }

    if(indexPath.row == arrayToUse.count)
    {
        if ([collectionView isEqual:self.newestCollectionView]) {
            [self performSelector:@selector(reloadNew) withObject:nil afterDelay:0.1];
        } else {
            [self performSelector:@selector(reloadPopular) withObject:nil afterDelay:0.1];
        }
    } else {
        ParseRecommendation *new = [arrayToUse objectAtIndex:indexPath.row];
        PFFile *imageFile = new.file;
//        if ([collectionView isEqual:self.newestCollectionView]) {
//            PFImageView *imageView = [[PFImageView alloc] initWithFrame:CGRectMake(cell.recentCollectionViewCellView.bounds.origin.x, cell.recentCollectionViewCellView.bounds.origin.y, cell.recentCollectionViewCellView.bounds.size.width, cell.recentCollectionViewCellView.bounds.size.height)];
//            imageView.file = (PFFile *)new.file;
//            [imageView loadInBackground];
//            [cell.recentCollectionViewCellView addSubview:imageView];
//        }

        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if ([collectionView isEqual:self.newestCollectionView]) {
                    cell.recentImageView.image = [UIImage imageWithData:data];
            } else {
                    cell.popularImageView.image = [UIImage imageWithData:data];
            }
        }];
    }

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
