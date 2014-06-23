//
//  LoginViewController.m
//  Recommend
//
//  Created by Dan Rudolf on 6/17/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()<FBLoginViewDelegate>



@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FBLoginView *login = [[FBLoginView alloc] init];
    login.delegate = self;
    [login setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [self.view addSubview:login];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user{

    NSLog(@"derp");
}


@end
