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
@property UIImage *profilePic;
@end

@implementation LoginViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [PFFacebookUtils initializeFacebook];
    self.nameLabel.layer.cornerRadius = 3;


    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skyline"]];
    background.frame = self.view.frame;
    [self.view insertSubview:background atIndex:0];

    NSArray *permissions = @[@"public_profile"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        else {
            NSLog(@"User logged in through Facebook!");

            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {

                    NSDictionary *userData = (NSDictionary *)result;

                    NSString *facebookID = userData[@"id"];
                    NSString *name = userData[@"name"];
//                    NSString *location = userData[@"location"][@"name"];
//                    NSString *gender = userData[@"gender"];
//                    NSString *birthday = userData[@"birthday"];
//                    NSString *relationship = userData[@"relationship_status"];
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1", facebookID]];

                    NSURLRequest *profilePicRequest = [NSURLRequest requestWithURL:pictureURL];
                    [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        self.profilePic = [[UIImage alloc] initWithData:data];
                        self.nameLabel.text = name;
                    }];
                }
            }];
        }
    }];

//  [self performSelector:@selector(segue) withObject:nil afterDelay:2];
}

- (void)segue{

    [self performSegueWithIdentifier:@"isLoggedIn" sender:self];
}





@end
