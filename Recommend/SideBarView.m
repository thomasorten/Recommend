//
//  SideBarView.m
//  Recommend
//
//  Created by Dan Rudolf on 6/26/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "SideBarView.h"
#import "LoginViewController.h"

@interface SideBarView () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableViewoutlet;
@property UIColor *backgroundColor;
@property NSArray *options;

@end

@implementation SideBarView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.options = @[@"", @"", @"", @"Log out"];
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2;
    self.profilePic.layer.masksToBounds = YES;


    if (FBSession.activeSession.isOpen == YES) {

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

                }];
            }
        }];

    }

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

}


#pragma mark Tableview Datasource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 3) {

        [FBSession.activeSession closeAndClearTokenInformation];
        self.profilePic.image = nil;
        self.nameLabel.text = @"";
    }
}

@end