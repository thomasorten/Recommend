//
//  RecommendationDelegate.m
//  Recommend
//
//  Created by Thomas Orten on 6/20/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "Recommendation.h"

@implementation Recommendation

- (id)initWithIdentifier:(NSString *)identifier
{
    self.identifier = identifier;
    return self;
}

- (void)getRecommendations:(int)limit
{
    [self setupQuery];
    self.query.limit = limit;
    [self loadRecommendations:limit orderByDescending:nil nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user
{
    [self setupQuery];
    [self.query whereKey:@"creator" equalTo:user];
    [self loadRecommendations:limit orderByDescending:nil nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column
{
    [self setupQuery];
    self.query.limit = limit;
    [self.query orderByDescending:column];
    [self loadRecommendations:limit orderByDescending:column nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km
{
    [self setupQuery];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [self loadRecommendations:limit orderByDescending:nil nearPoint:geoPoint withinKm:km];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:key containsString:string];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [self loadRecommendations:limit orderByDescending:nil nearPoint:geoPoint withinKm:km];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:nil nearPoint:(PFGeoPoint *)recommendation[@"point"] withinKm:km];
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

- (void)loadRecommendations:(int)limit orderByDescending:(NSString *)column nearPoint:(PFGeoPoint *)point withinKm:(double)km
{
    if (limit) {
        self.query.limit = limit;
    }

    if (point && km) {
        [self.query whereKey:@"point" nearGeoPoint:point withinKilometers:km];
    } else if (point) {
        [self.query whereKey:@"point" nearGeoPoint:point];
    } else {}

    if (column) {
        [self.query orderByDescending:column];
    } else {
        [self.query orderByDescending:@"createdAt"];
    }

    [self.query includeKey:@"creator"];

    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count < self.recommendations.count) {
                [self.recommendations removeAllObjects];
                [self.recommendations addObjectsFromArray:objects];
            } else {
                for (PFObject *recommendation in objects) {
                    if (![self recommendationAlreadyExists:recommendation]) {
                        [self.recommendations addObject:recommendation];
                    }
                }
            }
            self.query = nil;
            [self.delegate recommendationsLoaded:(NSArray *)self.recommendations forIdentifier:(NSString *)self.identifier];
        }
    }];
}

@end
