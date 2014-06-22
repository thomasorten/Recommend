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

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, RecommendationDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *newestCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *popularCollectionView;
@property NSMutableArray *popularArray;
@property NSMutableArray *recentArray;
@property Recommendation *newestRecommendations;
@property (weak, nonatomic) IBOutlet UIScrollView *recommendationsScrollView;
@end

@implementation HomeViewController

- (void)viewDidLoad

{
    [super viewDidLoad];

    Recommendation *popularRecommendations = [[Recommendation alloc] initWithIdentifier:@"popular"];
    popularRecommendations.delegate = self;

    self.newestRecommendations = [[Recommendation alloc] initWithIdentifier:@"new"];
    self.newestRecommendations.delegate = self;

    self.recentArray = [NSMutableArray new];
    self.popularArray = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;

    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error) {
            NSLog(@"Using Recommend as Anonymous");
        }
        else{
            NSLog(@"error logging in");
        }
    }];

    [self reloadNew];

    [popularRecommendations getRecommendations:18 orderByDescending:@"numLikes"];
}


-(void)reloadNew{
    [self.recentArray removeAllObjects];
    [self.newestRecommendations getRecommendations:18];
}

-(void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"new"]) {
        [self.recentArray addObjectsFromArray:recommendations];
        [self.newestCollectionView reloadData];
    }
    if ([identifier isEqualToString:@"popular"]) {
        [self.popularArray addObjectsFromArray:recommendations];
        [self.popularCollectionView reloadData];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [UICollectionViewCell new];
    cell.backgroundView = nil;

    if ([collectionView isEqual:self.newestCollectionView]) {

        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"New" forIndexPath:indexPath];
        PFObject *new = [self.recentArray objectAtIndex:indexPath.row];
        PFFile *imageFile = new[@"file"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];

        }];


    }
    else if([collectionView isEqual:self.popularCollectionView]){

        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Popular" forIndexPath:indexPath];
        PFObject *popular = [self.popularArray objectAtIndex:indexPath.row];
        PFFile *imageFile = popular[@"file"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];

        }];

    }

    return cell;
}

- (void)viewDidLayoutSubviews {
    self.recommendationsScrollView.contentSize = CGSizeMake((self.newestCollectionView.frame.size.width*5), 1);
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



@end
