//
//  LoginViewController.m
//  Recommend
//
//  Created by Dan Rudolf on 6/17/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    id permissions = @[@"permission"];

    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"User cancelled the facebook login.");
        } else if (user.isNew) {
            NSLog(@"Signed up and logged in through facebook");
        } else {
            NSLog(@"Logged in through facebook");
        }
    }];
}
@end
