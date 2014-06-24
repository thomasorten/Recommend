//
//  RecommendationDelegate.m
//  Recommend
//
//  Created by Thomas Orten on 6/20/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "Recommendation.h"

@implementation Recommendation

@synthesize lovesPhoto;
@synthesize lastLoaded;
@synthesize userLocation;
@synthesize recommendationsLoaded;

-(void)geoLocateUser:(PFGeoPoint *)userLocation andCompletionHandler:(void (^)(PFGeoPoint *geoPoint))completionHandler
{
    if (!self.userLocation) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                completionHandler(geoPoint);
            } else {
                completionHandler(NO);
            }
            self.userLocation = geoPoint;
        }];
    } else {
        completionHandler(self.userLocation);
    }
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if( !self ) return nil;
    self.identifier = identifier;
    self.recommendationsLoaded = 0;
    return self;
}

- (void)getRecommendations:(int)limit
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user
{
    [self setupQuery];
    [self.query whereKey:@"creator" equalTo:user];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:@"creator" equalTo:user];
    [self.query whereKey:key containsString:string];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column
{
    [self setupQuery];
    [self.query orderByDescending:column];
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearPoint:nil withinKm:-1];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km
{
    [self setupQuery];
    [self geoLocateUser:self.userLocation andCompletionHandler:^(PFGeoPoint *geoPoint) {
        if (geoPoint) {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:geoPoint withinKm:km];
        } else {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:nil withinKm:-1];
        }
    }];
}

- (void)getRecommendationsByDistance:(int)limit withinRadius:(double)km
{
    [self setupQuery];
    [self geoLocateUser:self.userLocation andCompletionHandler:^(PFGeoPoint *geoPoint) {
        if (geoPoint) {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:YES nearPoint:geoPoint withinKm:km];
        } else {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:YES nearPoint:nil withinKm:-1];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
    [self setupQuery];
    [self geoLocateUser:self.userLocation andCompletionHandler:^(PFGeoPoint *geoPoint) {
        if (geoPoint) {
            [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearPoint:geoPoint withinKm:km];
        } else {
            [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearPoint:nil withinKm:-1];
        }
    }];
}

-(void)getRecommendationsByDistance:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
    [self setupQuery];
    [self geoLocateUser:self.userLocation andCompletionHandler:^(PFGeoPoint *geoPoint) {
        if (geoPoint) {
            [self loadRecommendations:limit orderByDescending:column orderByDistance:YES nearPoint:geoPoint withinKm:km];
        } else {
            [self loadRecommendations:limit orderByDescending:column orderByDistance:YES nearPoint:nil withinKm:-1];
        }
    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:key containsString:string];
    [self geoLocateUser:self.userLocation andCompletionHandler:^(PFGeoPoint *geoPoint) {
        if (geoPoint) {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:geoPoint withinKm:km];
        } else {
            [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:nil withinKm:-1];
        }

    }];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearPoint:(PFGeoPoint *)recommendation[@"point"] withinKm:km];
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
    if (self.lastLoaded) {
        return;
    }
    [self.query cancel];
    self.query = nil;
    self.query = [PFQuery queryWithClassName:@"Recommendation"];
    if (!self.recommendations) {
        self.recommendations = [[NSMutableArray alloc] init];
    }
}

- (void)loadRecommendations:(int)limit orderByDescending:(NSString *)orderByColumn orderByDistance:(BOOL)orderByDistance nearPoint:(PFGeoPoint *)point withinKm:(double)km
{
    if (limit) {
       self.query.limit = limit;
    }

    self.query.skip = self.recommendationsLoaded;

    if (point && km) {
        [self.query whereKey:@"point" nearGeoPoint:point withinKilometers:km];
    } else if (point) {
        [self.query whereKey:@"point" nearGeoPoint:point];
    } else {
        point = nil;
    }

    if (!orderByDistance && !orderByColumn) {
        [self.query orderByDescending:@"createdAt"];
    }

    if (orderByColumn) {
        [self.query orderByDescending:orderByColumn];
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
            self.recommendations = (NSMutableArray *) objects;
            if (objects.count < limit) {
                self.lastLoaded = YES;
            }
            self.recommendationsLoaded += objects.count;
            self.query = nil;
            [self.delegate recommendationsLoaded:(NSArray *)self.recommendations forIdentifier:(NSString *)self.identifier userLocation:(PFGeoPoint *)point];
        }
    }];
}

- (void)love:(PFObject *)recommendation
{
    // Check if user has liked
    if (self.lovesPhoto) {
        [self.delegate recommendationLoved:@"User already liked." count:0 recommendation:nil];
        return;
    }

    PFQuery *loveQuery = [PFQuery queryWithClassName:@"Love"];
    [loveQuery whereKey:@"recommendation" equalTo:recommendation];
    [loveQuery whereKey:@"user" equalTo:[PFUser currentUser]];

    [loveQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            [recommendation incrementKey:@"numLikes"];
            [recommendation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.delegate recommendationLoved:nil count:recommendation[@"numLikes"] recommendation:recommendation];
                    self.lovesPhoto = YES;
                } else {
                    [self.delegate recommendationLoved:@"Network error." count:0 recommendation:recommendation];
                }
            }];
            // Save in likes table
            PFObject *userLike = [PFObject objectWithClassName:@"Love"];
            userLike[@"recommendation"] = recommendation;
            userLike[@"user"] = [PFUser currentUser];
            [userLike saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                self.lovesPhoto = YES;
            }];
        } else {
            // The find succeeded.
            [self.delegate recommendationLoved:@"User already liked." count:0 recommendation:nil];
        }
    }];

}

@end
