//
//  MyProfileVC.m
//  Recommend
//
//  Created by Dan Rudolf on 7/1/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "MyProfileVC.h"
#import "RecommendationsCollectionViewCell.h"
#import "Recommendation.h"

@interface MyProfileVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation MyProfileVC



- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma Mark - CollectionView Datasource/Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    RecommendationsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    return cell;

}

@end
