//
//  RecommendationsCollectionViewCell.h
//  Recommend
//
//  Created by Thomas Orten on 6/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendationsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *recentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *popularImageView;
@property (weak, nonatomic) IBOutlet UIView *recentCollectionViewCellView;
@property (weak, nonatomic) IBOutlet UIView *popularCollectionViewCellView;

@end
