//
//  Recommendation.h
//  Recommend
//
//  Created by Thomas Orten on 6/19/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <Parse/Parse.h>

@protocol RecommendationDelegate

- (void)recommendationsLoaded:(NSMutableArray *)recommendations;

@end

@interface Recommendation : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property id <RecommendationDelegate> delegate;

@property PFFile *file;
@property (retain, nonatomic) NSDate *createdAt;
@property NSString *title;
@property NSString *description;
@property PFObject *creator;
@property NSNumber *numLikes;

@property PFGeoPoint *location;
@property NSMutableArray *recommendations;

@end
