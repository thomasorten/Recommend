//
//  RecommendationDelegate.m
//  Recommend
//
//  Created by Thomas Orten on 6/20/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "Recommendation.h"

@implementation Recommendation

- (void)getRecommendations:(int)limit
{
    [self setupQuery];
    self.query.limit = limit;
    [self loadRecommendations:limit nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km
{
    [self setupQuery];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [self loadRecommendations:limit nearPoint:geoPoint withinKm:km];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:key containsString:string];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [self loadRecommendations:limit nearPoint:geoPoint withinKm:km];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation
{
    [self setupQuery];
    [self loadRecommendations:limit nearPoint:(PFGeoPoint *)recommendation[@"point"] withinKm:km];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofUser:(PFUser *)user
{
    [self setupQuery];
    [self.query whereKey:@"user" equalTo:user];
    [self loadRecommendations:limit nearPoint:nil withinKm:-1];
}

- (BOOL)recommendationAlreadyExists:(PFObject *)recommendation
{
    BOOL exists = NO;
    for (PFObject *currentRecommendation in self.recommendations) {
        if ([currentRecommendation.objectId isEqualToString:recommendation.objectId]) {
            exists = YES;
            break;
        }
    }
    return exists;
}

- (void)setupQuery
{
    [self.query cancel];
    self.query = nil;
    self.query = [PFQuery queryWithClassName:@"Recommendation"];
    if (!self.recommendations) {
        self.recommendations = [[NSMutableArray alloc] init];
    }
}

- (void)loadRecommendations:(int)limit nearPoint:(PFGeoPoint *)point withinKm:(double)km
{
    self.query.limit = limit;

    if (point && km) {
        [self.query whereKey:@"point" nearGeoPoint:point withinKilometers:km];
    } else if (point) {
        [self.query whereKey:@"point" nearGeoPoint:point];
    } else {}

    [self.query orderByDescending:@"createdAt"];

    [self.query includeKey:@"creator"];

    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count < self.recommendations.count) {
                self.recommendations = [[NSMutableArray alloc] initWithArray:objects];
            } else {
                for (PFObject *recommendation in objects) {
                    if (![self recommendationAlreadyExists:recommendation]) {
                        [self.recommendations addObject:recommendation];
                    }
                }
            }
            self.query = nil;
            [self.delegate recommendationsLoaded: (NSArray *) self.recommendations];
        }
    }];
}

@end
