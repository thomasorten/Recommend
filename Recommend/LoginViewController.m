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

-(void)viewDidLoad{
    [super viewDidLoad];
    [PFFacebookUtils initializeFacebook];
    NSArray *permissions = @[@"public_profile"];

    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];

    [super viewDidLoad];
    self.nameLabel.layer.cornerRadius = 3;
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skyline"]];
    background.frame = self.view.frame;
    [self.view insertSubview:background atIndex:0];


   [self performSelector:@selector(segue) withObject:nil afterDelay:2];
}

- (void)segue{

    [self performSegueWithIdentifier:@"isLoggedIn" sender:self];
}





@end
