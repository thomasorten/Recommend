//
//  LoginViewController.m
//  Recommend
//
//  Created by Dan Rudolf on 6/17/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()<FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) FBProfilePictureView *profilePic;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.layer.cornerRadius = 3;
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skyline"]];
    background.frame = self.view.frame;
    [self.view insertSubview:background atIndex:0];


    FBLoginView *login = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile"]];
    self.profilePic = [[FBProfilePictureView alloc] init];
    self.profilePic.frame = CGRectMake(self.view.center.x - 40, self.view.center.y, 80, 80);
    self.profilePic.center = CGPointMake(self.view.center.x, self.view.center.y);
    self.profilePic.backgroundColor = [UIColor blackColor];
    self.profilePic.layer.cornerRadius = 40;
    [self.view addSubview:self.profilePic];
    [self.profilePic setHidden:YES];
    login.delegate = self;
    [login setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height * .85)];
    [self.view addSubview:login];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user{
    [self.profilePic setHidden:NO];
    [self.nameLabel setHidden:NO];
    self.profilePic.profileID = [user objectID];
    self.nameLabel.text = user.name;
   // [self performSelector:@selector(segue) withObject:nil afterDelay:2];
}

- (void)segue{

    [self performSegueWithIdentifier:@"isLoggedIn" sender:self];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    [self.profilePic setHidden:YES];
    [self.nameLabel setHidden:YES];
}




@end
