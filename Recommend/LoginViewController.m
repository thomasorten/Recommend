//
//  LoginViewController.m
//  Recommend
//
//  Created by Dan Rudolf on 6/17/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()<FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *homeButton;
@property (strong, nonatomic) IBOutlet UILabel *homeLabel;
@property (strong, nonatomic) IBOutlet UILabel *orLable;
@property (strong, nonatomic) IBOutlet UIImageView *loggedIn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fbImageView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatior;

@end

@implementation LoginViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [PFFacebookUtils initializeFacebook];
    [self.loggedIn setHidden:YES];
    [self.activityIndicatior setHidden:YES];
    [self.fbImageView setHidden:YES];
    [self.nameLabel setHidden:YES];
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.layer.masksToBounds = YES;
    self.fbImageView.layer.cornerRadius = 40;
    self.fbImageView.layer.masksToBounds = YES;
    self.nameLabel.layer.cornerRadius = 5;
    self.nameLabel.layer.masksToBounds = YES;
    self.loggedIn.layer.cornerRadius = 5;
    self.loggedIn.layer.masksToBounds = YES;
    self.homeLabel.layer.cornerRadius = 5;
    self.homeLabel.layer.masksToBounds = YES;
    self.orLable.layer.cornerRadius = 5;
    self.orLable.layer.masksToBounds = YES;


    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skyline"]];
    background.frame = self.view.frame;
    [self.view insertSubview:background atIndex:0];

   }
- (IBAction)homeButton:(id)sender {
   [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:nil afterDelay:0.0];

}

- (IBAction)onloginPressed:(UIButton *)sender {
    NSArray *permissions = @[@"public_profile"];
    [self.activityIndicatior setHidden:NO];
    [self.activityIndicatior startAnimating];
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
                    self.name = userData[@"name"];
                    user[@"username"] = self.name;
                    [user saveInBackground];
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

                    NSURLRequest *profilePicRequest = [NSURLRequest requestWithURL:pictureURL];
                    [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        [self.homeButton setHidden:YES];
                        [self.orLable setHidden:YES];
                        [self.homeLabel setHidden:YES];
                        
                        self.profilePic = [[UIImage alloc] initWithData:data];
                        self.fbImageView.image = self.profilePic;
                        [self.activityIndicatior setHidden:YES];
                        [self.activityIndicatior stopAnimating];
                        [self.fbImageView setHidden:NO];
                        self.nameLabel.text = self.name;
                        [self.nameLabel setHidden:NO];
                        [self.loginButton setHidden:YES];
                        [self.loggedIn setHidden:NO];
                        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:nil afterDelay:0.0];
                    }];
                }
            }];
        }
    }];
    
}


@end
