//
//  ViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error) {
            NSLog(@"Using Recommend as Anonymous");
        }
        else{
            NSLog(@"error logging in");
        }
    }];
}



@end
