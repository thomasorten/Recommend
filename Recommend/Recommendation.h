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

- (void)recommendationsLoaded:(NSArray *)recommendations forIdentifier:(NSString *)identifier;

- (void)recommendationLoved:(NSString *)error count:(NSNumber *)count recommendation:(PFObject *)recommendation;

@end

@interface Recommendation : NSObject

@property id <RecommendationDelegate> delegate;

@property NSMutableArray *recommendations;
@property ParseRecommendation *recommendation;
@property PFQuery *query;
@property NSString *identifier;
@property BOOL lovesPhoto;

- (id)initWithIdentifier:(NSString *)identifier;

- (void)love:(PFObject *)recommendation;

- (void)getRecommendations:(int)limit;

- (void)getRecommendations:(int)limit byUser:(PFUser *)user;

- (void)getRecommendations:(int)limit orderByDescending:(NSString *)column;

- (void)getRecommendations:(int)limit withinRadius:(double)km;

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string;

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation;
@end
