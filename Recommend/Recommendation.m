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

- (void)reverseGeocode:(PFGeoPoint *)locationCord onComplete:(void(^)(NSMutableDictionary *location))completion {

    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCord.latitude longitude:locationCord.longitude];

    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *addressPlacmark = [placemarks firstObject];
            NSString *street = [NSString stringWithFormat:@"%@ %@",addressPlacmark.subThoroughfare, addressPlacmark.thoroughfare];
            NSString *city = [NSString stringWithFormat:@"%@",addressPlacmark.locality];

            NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] initWithObjects:@[street, city] forKeys:@[@"street", @"city"]];

            completion(addressDictionary);
        } else {
            completion(nil);
        }
    }];
}

-(void)geoLocateUser:(void (^)(PFGeoPoint *geoPoint))onComplete
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            self.userLocation = geoPoint;
            onComplete(geoPoint);
        } else {
            onComplete(nil);
        }
    }];
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
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:-1  nearPoint:nil];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user
{
    [self setupQuery];
    [self.query whereKey:@"creator" equalTo:user];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:-1  nearPoint:nil];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:@"creator" equalTo:user];
    [self.query whereKey:key containsString:string];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:-1  nearPoint:nil];
}

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column
{
    [self setupQuery];
    [self.query orderByDescending:column];
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearUser:NO withinKm:-1  nearPoint:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:YES withinKm:km  nearPoint:nil];
}

- (void)getRecommendationsByDistance:(int)limit withinRadius:(double)km
{
    [self setupQuery];
       [self loadRecommendations:limit orderByDescending:nil orderByDistance:YES nearUser:YES withinKm:km nearPoint:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearUser:YES withinKm:km nearPoint:nil];
}

-(void)getRecommendationsByDistance:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
    [self setupQuery];
     [self loadRecommendations:limit orderByDescending:column orderByDistance:YES nearUser:YES withinKm:km nearPoint:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string
{
    [self setupQuery];
    [self.query whereKey:key containsString:string];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:YES withinKm:km  nearPoint:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation
{
    [self setupQuery];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:km nearPoint:(PFGeoPoint *)recommendation[@"point"]];
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
    if (self.lastLoaded && self.userLocation) {
        [self.delegate recommendationsLoaded:nil forIdentifier:nil userLocation:self.userLocation];
    }
    if (self.lastLoaded) {
        [self.delegate recommendationsLoaded:nil forIdentifier:nil userLocation:nil];
    }
    [self.query cancel];
    self.query = nil;
    self.query = [PFQuery queryWithClassName:@"Recommendation"];
    if (!self.recommendations) {
        self.recommendations = [[NSMutableArray alloc] init];
    }
}

- (void)loadRecommendations:(int)limit orderByDescending:(NSString *)orderByColumn orderByDistance:(BOOL)orderByDistance nearUser:(bool)findUser withinKm:(double)km nearPoint:(PFGeoPoint *)point
{
    if (!self.userLocation && findUser) {
        [self geoLocateUser:^(PFGeoPoint *geoPoint) {
            if (geoPoint) {
                [self.delegate userLocationFound:geoPoint];
                [self loadRecommendations:limit orderByDescending:orderByColumn orderByDistance:orderByDistance nearUser:findUser withinKm:km nearPoint:geoPoint];
            } else {
                [self.delegate userLocationFound:nil];
                //[self loadRecommendations:limit orderByDescending:orderByColumn orderByDistance:orderByDistance nearUser:nil withinKm:-1 nearPoint:nil];
            }
        }];
        return;
    }

    if (limit) {
       self.query.limit = limit;
    }

    self.query.skip = self.recommendationsLoaded;

    if (findUser && km) {
        [self.query whereKey:@"point" nearGeoPoint:self.userLocation withinKilometers:km];
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
            if (objects) {
                [self.delegate onNoRecommendations:NO];
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
            }
            self.recommendations = (NSMutableArray *) objects;
            if (objects.count < limit) {
                self.lastLoaded = YES;
            }
            self.recommendationsLoaded += objects.count;
            self.query = nil;
            if (!objects && self.recommendationsLoaded == 0) {
                [self.delegate onNoRecommendations:YES];
            }
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
