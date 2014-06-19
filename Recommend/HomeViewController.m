//
//  ViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *newestCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *popularCollectionView;
@property NSMutableArray *popularArray;
@property NSMutableArray *recentArray;

@end

@implementation HomeViewController

- (void)viewDidLoad

{
    [super viewDidLoad];
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

    PFQuery *popular = [PFQuery queryWithClassName:@"Photo"];
    [popular orderByDescending:@"numLikes"];
    [popular findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFObject *photo in objects) {
            [self.popularArray addObject:photo];
        }
        [self.popularCollectionView reloadData];
    }];

}


-(void)reloadNew{
    [self.recentArray removeAllObjects];
    PFQuery *new = [PFQuery queryWithClassName:@"Photo"];
    [new orderByDescending:@"createdAt"];
    [new findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFObject *photo in objects) {
            [self.recentArray addObject:photo];
        }
        [self.newestCollectionView reloadData];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UICollectionViewCell *)sender{

    DetailViewController *destination = [segue destinationViewController];


    if ([segue.identifier isEqualToString:@"NewestSegue"]) {
        NSIndexPath *selected = [self.newestCollectionView indexPathForCell:sender];
        destination.recommendation = @{@"photo": [self.recentArray objectAtIndex:selected.row]};
    }
    else if ([segue.identifier isEqualToString:@"PopularSegue"]){
        NSIndexPath *selected = [self.popularCollectionView indexPathForCell:sender];
        destination.recommendation = @{@"photo":[self.popularArray objectAtIndex:selected.row]};
    }

}



@end
