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

- (void)recommendationsLoaded:(NSArray *)recommendations;

@end

@interface Recommendation : NSObject

@property id <RecommendationDelegate> delegate;

@property NSMutableArray *recommendations;
@property ParseRecommendation *recommendation;
@property PFQuery *query;

- (void)getRecommendations:(int)limit;

- (void)getRecommendations:(int)limit withinRadius:(double)km;

- (void)getRecommendations:(int)limit withinRadius:(double)km whereKey:(NSString *)key containsString:(NSString *)string;

- (void)getRecommendations:(int)limit withinRadius:(double)km ofRecommendation:(PFObject *)recommendation;

- (void)getRecommendations:(int)limit withinRadius:(double)km ofUser:(PFUser *)user;

@end
