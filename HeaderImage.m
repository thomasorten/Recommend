//
//  HeaderImage.m
//  Recommend
//
//  Created by Thomas Orten on 6/23/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "HeaderImage.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIImage (initWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);

    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end