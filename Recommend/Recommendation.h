//
//  RecommendationDelegate.h
//  Recommend
//
//  Created by Thomas Orten on 6/20/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ParseRecommendation.h"

@protocol RecommendationDelegate

@optional

- (void)recommendationLoved:(NSString *)error count:(NSNumber *)count recommendation:(PFObject *)recommendation;

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier userLocation:(PFGeoPoint *)location;

- (void)userLocationUnknown:(bool)unknown;

- (void)onNoRecommendations:(bool)noRecommendations;

@end

@interface Recommendation : NSObject

@property id <RecommendationDelegate> delegate;

@property NSMutableArray *recommendations;
@property ParseRecommendation *recommendation;
@property PFQuery *query;
@property NSString *identifier;
@property BOOL lovesPhoto;
@property BOOL lastLoaded;
@property PFGeoPoint *userLocation;
@property NSInteger recommendationsLoaded;

- (void)reverseGeocode:(PFGeoPoint *)locationCord onComplete:(void(^)(NSMutableDictionary *location))completion;

- (id)initWithIdentifier:(NSString *)identifier;

- (void)love:(PFObject *)recommendation;

- (void)getRecommendations:(int)limit;

- (void)getRecommendations:(int)limit byUser:(PFUser *)user;

- (void)getRecommendations:(int)limit byUser:(PFUser *)user whereKey:(NSString *)key containsString:(NSString *)string;

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column;

- (void)getRecommendations:(int)limit withinRadius:(double)km;

- (void)getRecommendationsByDistance:(int)limit withinRadius:(double)km;

- (void)getRecommendations:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column;

-(void)getRecommendationsByDistance:(int)limit withinRadius:(double)km orderByDescending:(NSString *)column;

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string;

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation;
@end
