//
//  RecommendationTabBarItem.m
//  Recommend
//
//  Created by Thomas Orten on 6/21/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "RecommendationTabBarItem.h"

@implementation RecommendationTabBarItem

- (void)awakeFromNib {
    [self setImage:self.image]; // calls setter below to adjust image from storyboard / nib file
}

- (void)setImage:(UIImage *)image {
   // [super setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    //self.selectedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
