//
//  RecommendationsCollectionViewCell.h
//  Recommend
//
//  Created by Thomas Orten on 6/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendationsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lovesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
