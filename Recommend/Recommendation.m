//
//  Recommendation.m
//  Recommend
//
//  Created by Thomas Orten on 6/19/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "Recommendation.h"
#import <Parse/PFObject+Subclass.h>

@implementation Recommendation

@dynamic delegate;

+ (NSString *)parseClassName {
    return @"Recommendation";
}

@dynamic file;
@dynamic createdAt;
@dynamic title;
@dynamic description;
@dynamic creator;
@dynamic numLikes;

@dynamic location;
@dynamic recommendations;

- (void)getAllRecommendations:(int)limit withinRadius:(double)km ofPoint:(PFGeoPoint *)point forUser:(PFUser *)user withPredicate:(NSPredicate *)predicate
{
    PFQuery *query;

    if (predicate) {
        query = [PFQuery queryWithClassName:@"Recommendation" predicate:predicate];
    } else {
        query = [PFQuery queryWithClassName:@"Recommendation"];
    }

    if (point && km) {
        [query whereKey:@"point" nearGeoPoint:point withinKilometers:km];
    } else if (point) {
        [query whereKey:@"point" nearGeoPoint:point];
    } else {}

    if (user) {
        [query whereKey:@"creator" equalTo:user];
    }

    if (limit) {
        query.limit = limit;
    }

    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *recommendation in objects) {
                if (![self.recommendations containsObject:recommendation]) {
                    [self.recommendations addObject:recommendation];
                }
            }
            [self.delegate recommendationsLoaded:self.recommendations];
        }
    }];

}

@end
