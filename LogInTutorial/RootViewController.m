//
//  RootViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/26/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "RootViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onLoginButtonPressed:(id)sender
{
    PFUser *userNow = [PFUser currentUser];
    if (userNow)
    {
        [self performSegueWithIdentifier:@"RootToProfileSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"RootToLogInSegue" sender:self];
    }
}

- (IBAction)unwindToBeginning:(UIStoryboardSegue *)unwindSegue
{
    [PFUser logOut];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RootToProfileSegue"])
    {
        ProfileViewController *pvc = segue.destinationViewController;
        pvc.ownProfile = 1;
    }
}


@end
