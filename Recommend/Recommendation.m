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

- (void)reset
{
    self.lastLoaded = NO;
    self.recommendationsLoaded = 0;
}

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if( !self ) return nil;
    self.identifier = identifier;
    self.lastLoaded = NO;
    self.recommendationsLoaded = 0;
    return self;
}

- (void)reverseGeocode:(PFGeoPoint *)locationCord onComplete:(void(^)(NSMutableDictionary *location))completion {

    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCord.latitude longitude:locationCord.longitude];

    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *addressPlacmark = [placemarks firstObject];
            NSString *street = [NSString stringWithFormat:@"%@ %@",addressPlacmark.thoroughfare, addressPlacmark.thoroughfare];
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

+ (void)saveLocation:(NSDictionary *)location
{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"country" equalTo:[location objectForKey:@"country"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            PFObject *newLocation = [PFObject objectWithClassName:@"Location"];
            newLocation[@"country"] = [location objectForKey:@"country"];
            [newLocation addObject:[location objectForKey:@"city"] forKey:@"city"];
            [newLocation saveInBackground];
        } else {
            // The find succeeded.
            [object addUniqueObject:[location objectForKey:@"city"] forKey:@"city"];
            [object saveInBackground];
        }
    }];
}

+ (void)getLocations:(void (^)(NSMutableArray *locations))onComplete
{
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query orderByAscending:@"country"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:@"Close to me"];
        for (PFObject *country in objects) {
            NSArray *sortedCityArray = [[country objectForKey:@"city"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [array addObject: [NSString stringWithFormat:@"- %@ -", [country objectForKey:@"country"]]];
            [array addObjectsFromArray:sortedCityArray];
        }
        onComplete(array);
    }];
}

- (void)getRecommendations:(int)limit
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

- (void)getRecommendations:(int)limit whereKey:(NSString *)key equalTo:(NSString *)string
{
    [self.query whereKey:key equalTo:string];
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:@{key:string} whereContainsString:nil];
}

- (void)getRecommendations:(int)limit whereKey:(NSString *)key equalTo:(NSString *)string orderByDescending:(NSString *)column
{
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:@{key:string} whereContainsString:nil];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:@{@"creator":user} whereContainsString:nil];
}

- (void)getRecommendations:(int)limit byUser:(PFUser *)user whereKey:(NSString *)key containsString:(NSString *)string
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:@{@"creator" : user} whereContainsString:@{key: string}];
}

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column
{
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearUser:NO withinKm:0  nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:YES withinKm:km  nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

- (void)getRecommendationsByDistance:(int)limit withinRadius:(double)km
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:YES nearUser:YES withinKm:km nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
    [self loadRecommendations:limit orderByDescending:column orderByDistance:NO nearUser:YES withinKm:km nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

-(void)getRecommendationsByDistance:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column
{
     [self loadRecommendations:limit orderByDescending:column orderByDistance:YES nearUser:YES withinKm:km nearPoint:nil whereEqualTo:nil whereContainsString:nil];
}

- (void)getRecommendations:(int)limit whereKey:(NSString *)key containsString:(NSString *)string
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:0 nearPoint:nil whereEqualTo:nil whereContainsString:@{key:string}];
}

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation
{
    [self loadRecommendations:limit orderByDescending:nil orderByDistance:NO nearUser:NO withinKm:km nearPoint:(PFGeoPoint *)recommendation[@"point"] whereEqualTo:nil whereContainsString:nil];
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

+ (UIImage *)getCategoryIcon:(NSString *)category
{
    UIImage *icon = nil;
    if ([category isEqualToString:@"Travel & Transport"]) {
        icon = [UIImage imageNamed:@"travel_64"];
    } else if ([category isEqualToString:@"Residence"]) {
        icon = [UIImage imageNamed:@"residences_64"];
    } else if ([category isEqualToString:@"Nightlife Spot"]) {
        icon = [UIImage imageNamed:@"nightlife_64"];
    } else if ([category isEqualToString:@"Shop & Service"]) {
        icon = [UIImage imageNamed:@"shops_64"];
    } else if ([category isEqualToString:@"College & University"]) {
        icon = [UIImage imageNamed:@"education_64"];
    } else if ([category isEqualToString:@"Event"]) {
        icon = [UIImage imageNamed:@"event_64"];
    } else if ([category isEqualToString:@"Professional & Other Places"]) {
        icon = [UIImage imageNamed:@"professional_other_64"];
    } else if ([category isEqualToString:@"Food"]) {
        icon = [UIImage imageNamed:@"food_64"];
    } else if ([category isEqualToString:@"Arts & Entertainment"]) {
        icon = [UIImage imageNamed:@"arts_entertainment_64"];
    }  else if ([category isEqualToString:@"Outdoors & Recreation"]) {
        icon = [UIImage imageNamed:@"outdoors_64"];
    } else {}
    return icon;
}

+ (NSString *)getUserSelectedLocation
{
    NSString *savedLocation;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        savedLocation = [[[NSDictionary alloc] initWithContentsOfFile:[self dataFilePath]] objectForKey:@"manualLocation"];
    }
    return savedLocation;
}

+ (void)setNewLocation:(NSString *)location
{
    if (location) {
        [@{@"manualLocation" : location} writeToFile:[self dataFilePath] atomically:YES];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:[self dataFilePath] error:nil];
    }
}

+ (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"manualLocation"];
}

- (void)loadRecommendations:(int)limit orderByDescending:(NSString *)orderByColumn orderByDistance:(BOOL)orderByDistance nearUser:(bool)findUser withinKm:(double)km nearPoint:(PFGeoPoint *)point whereEqualTo:(NSDictionary *)whereEqualTo whereContainsString:(NSDictionary *)whereContainsString
{
    if (self.lastLoaded && self.userLocation) {
        [self.delegate recommendationsLoaded:nil forIdentifier:nil userLocation:self.userLocation];
    }
    if (self.lastLoaded) {
        [self.delegate recommendationsLoaded:nil forIdentifier:nil userLocation:nil];
    }

    PFQuery *query = [PFQuery queryWithClassName:@"Recommendation"];
    self.recommendations = [[NSMutableArray alloc] init];

    if (!self.userLocation && findUser) {
        [self geoLocateUser:^(PFGeoPoint *geoPoint) {
            if (geoPoint) {
                [self.delegate userLocationFound:geoPoint];
                [self loadRecommendations:limit orderByDescending:orderByColumn orderByDistance:orderByDistance nearUser:findUser withinKm:km nearPoint:geoPoint whereEqualTo:whereEqualTo whereContainsString:whereContainsString];
            } else {
                [self.delegate userLocationFound:nil];
                [self loadRecommendations:limit orderByDescending:orderByColumn orderByDistance:orderByDistance nearUser:nil withinKm:0 nearPoint:nil whereEqualTo:whereEqualTo whereContainsString:whereContainsString];
            }
        }];
        return;
    }

    if (whereEqualTo) {
        for (id key in whereEqualTo)
        {
            id value = [whereEqualTo objectForKey:key];
            [query whereKey:key equalTo:value];
        }
    }

    if (whereContainsString) {
        for (id key in whereContainsString)
        {
            id value = [whereContainsString objectForKey:key];
            [query whereKey:key matchesRegex:value modifiers:@"i"];
        }
    }

    if (limit) {
       query.limit = limit;
    }

    if (self.recommendationsLoaded) {
        query.skip = self.recommendationsLoaded;
    }

    if (findUser && km) {
        [query whereKey:@"point" nearGeoPoint:self.userLocation withinKilometers:km];
    } else if (point) {
        [query whereKey:@"point" nearGeoPoint:point];
    } else {
        point = nil;
    }

    [query whereKey:@"thumbnail" notEqualTo:[NSNull null]];
    [query whereKey:@"flags" equalTo:[NSNull null]];

    if (!orderByDistance && !orderByColumn) {
        [query orderByDescending:@"createdAt"];
    }

    if (orderByColumn) {
        [query orderByDescending:orderByColumn];
    }

    [query includeKey:@"creator"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count) {
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
            [self.delegate recommendationsLoaded:(NSArray *)self.recommendations forIdentifier:(NSString *)self.identifier userLocation:(PFGeoPoint *)point];
            }
            if (objects.count == 0 && self.recommendationsLoaded == 0) {
                [self.delegate onNoRecommendations:YES];
            }
    }];
}

- (void)love:(PFObject *)recommendation
{
    // Check if user has liked
    if (self.lovesPhoto) {
        [self.delegate recommendationLoved:@"You have already given a kudos." count:0 recommendation:recommendation];
        return;
    }

    if (![PFUser currentUser]) {
        // The find succeeded.
        [self.delegate recommendationLoved:@"You have to log in to give kudos." count:0 recommendation:nil];
        return;
    }

    self.lovesPhoto = YES;

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
            [self.delegate recommendationLoved:@"You have already given a kudos." count:0 recommendation:recommendation];
        }
    }];

}

- (void)getRecommendations:(int)limit thatUserHasLiked:(PFUser *)user{

    PFQuery *userLikes = [PFQuery queryWithClassName:@"Love"];
    [userLikes whereKey:@"user" equalTo:[PFUser currentUser]];
    [userLikes includeKey:@"recommendation"];
    [userLikes includeKey:@"user"];
    [userLikes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        for (PFObject *object in objects) {
            PFObject *recommendation = [object objectForKey:@"recommendation"];
            recommendation[@"creator"] = [object objectForKey:@"user"];
            if (recommendation && !recommendation[@"flags"]) {
                [tmpArray addObject:recommendation];
            }
        }
        [self.delegate likesLoaded:(NSArray *) tmpArray];
    }];
}


@end
