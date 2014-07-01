//
//  Recommendation.m
//  Recommend
//
//  Created by Thomas Orten on 6/19/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ParseRecommendation.h"
#import <Parse/PFObject+Subclass.h>

@implementation ParseRecommendation

+ (NSString *)parseClassName {
    return @"Recommendation";
}

@dynamic file;
@dynamic thumbnail;
@dynamic createdAt;
@dynamic title;
@dynamic description;
@dynamic city;
@dynamic street;
@dynamic creator;
@dynamic numLikes;
@dynamic point;
@dynamic category;
@dynamic category_id;

@end
