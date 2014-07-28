//
//  SideBarView.m
//  Recommend
//
//  Created by Dan Rudolf on 6/26/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "SideBarView.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"
#import "MyRecommends.h"
#import "MyLikes.h"

@interface SideBarView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *logoutActivity;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableViewoutlet;

@property UIColor *backgroundColor;
@property NSMutableArray *options;
@property NSMutableArray *logOut;
@property NSMutableArray *images;
@property NSMutableArray *logoutImage;
@property MyRecommends *myRecommends;
@property MyLikes *myLikes;

@end

@implementation SideBarView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.images = [NSMutableArray new];
    self.options = [NSMutableArray new];
    self.logOut = [NSMutableArray new];
    self.logoutImage = [NSMutableArray new];
    [self.logoutActivity setHidden:YES];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2;
    self.profilePic.layer.masksToBounds = YES;

    //remember to convert RGB values to < 1
    float red = 0.2549;
    float green = 0.3019;
    float blue = 0.3686;
    self.backgroundColor = [[UIColor alloc] initWithRed:red
                                                  green:green
                                                   blue:blue
                                                  alpha:1];
    
    self.view.backgroundColor = self.backgroundColor;
    self.tableViewoutlet.backgroundColor = self.backgroundColor;

    self.myRecommends = [self.storyboard instantiateViewControllerWithIdentifier:@"myRecommends"];
    self.myLikes = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLikes"];


}

- (void)viewWillAppear:(BOOL)animated{
    
    [FBSession openActiveSessionWithAllowLoginUI:NO];

    if ([PFUser currentUser] && FBSession.activeSession.isOpen == YES && self.options.count ==0) {

        [self.logoutActivity setHidesWhenStopped:NO];
        [self.logoutActivity startAnimating];
        [self.options addObjectsFromArray:@[@"Home",@"Kudos", @"Favorites"]];
        [self.logOut addObjectsFromArray:@[@"Log Out"]];
        [self.images addObjectsFromArray:@[[UIImage imageNamed:@"home"], [UIImage imageNamed:@"slr"], [UIImage imageNamed:@"heart64"]]];
        [self.logoutImage addObject:[UIImage imageNamed:@"logoutwhite"]];
        [self.tableViewoutlet reloadData];

        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {

                NSDictionary *userData = (NSDictionary *)result;

                NSString *facebookID = userData[@"id"];
                self.nameLabel.text = userData[@"name"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

                NSURLRequest *profilePicRequest = [NSURLRequest requestWithURL:pictureURL];
                [NSURLConnection sendAsynchronousRequest:profilePicRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    self.profilePic.image = [[UIImage alloc] initWithData:data];
                    [self.logoutActivity setHidden:YES];
                    [self.logoutActivity stopAnimating];


                }];
            }
        }];
        
    }
}


#pragma mark Tableview Datasource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 55)];

    footer.backgroundColor = self.backgroundColor;

    return footer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {

        return self.options.count;
    }

    else
        return self.logOut.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.backgroundColor = [UIColor clearColor];

    if (indexPath.section == 0) {
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];
    }

    else if (indexPath.section == 1){
        cell.textLabel.text = [self.logOut objectAtIndex:indexPath.row];
        cell.imageView.image = [self.logoutImage objectAtIndex:indexPath.row];

    }

    return cell;
}

- (void)logedOut{

    SWRevealViewController *revealvc = (id) self.view.window.rootViewController;
    self.nameLabel.text = @"";
    [self.options removeAllObjects];
    [self.logOut removeAllObjects];
    [self.images removeAllObjects];
    [self.logoutImage removeAllObjects];
    [self.logoutActivity stopAnimating];
    [self.logoutActivity setHidden:YES];
    [self.tableViewoutlet reloadData];
    UIViewController *homeTab = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    [revealvc pushFrontViewController:homeTab animated:YES];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    SWRevealViewController *revealvc = (id) self.view.window.rootViewController;

    if (indexPath.section == 0) {

        if (indexPath.row == 0 && ![revealvc.frontViewController isKindOfClass:[UITabBarController class]]) {

            UIViewController *homeTab = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            [revealvc pushFrontViewController:homeTab animated:YES];
        }

        else if (indexPath.row == 0){

            [self.tabBarController setSelectedIndex:0];

        }
        else if (indexPath.row == 1) {

            [revealvc pushFrontViewController:self.myRecommends animated:YES];
        }

        else if(indexPath.row == 2) {

            [revealvc pushFrontViewController:self.myLikes animated:YES];

        }
    }

     if (indexPath.section == 1) {

        [FBSession.activeSession closeAndClearTokenInformation];
        [PFUser logOut];
        [self.logoutActivity setHidden:NO];
        [self.logoutActivity startAnimating];
        self.profilePic.image = nil;
        [self performSelector:@selector(logedOut) withObject:nil afterDelay:.5];
       }
}





@end