//
//  RootViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/26/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "RootViewController.h"
#import "ProfileViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];//[UIColor colorWithRed:195/255.0f green:140/255.0f blue:69/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Futura" size:21.0f]}];
    
//    NSShadow* shadow = [NSShadow new];
//    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    shadow.shadowColor = [UIColor redColor];
//    [[UINavigationBar appearance] setTitleTextAttributes: @{
//                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
//                                                            NSFontAttributeName: [UIFont fontWithName:@"Futura" size:20.0f],
//                                                            NSShadowAttributeName: shadow
//                                                            }];
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
    else if ([segue.identifier isEqualToString:@"RootToLogInSegue"])
    {
        LogInViewController *livc = segue.destinationViewController;
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBackgroundWithLogo"]];
        [livc.view addSubview:backgroundImage];
        [livc.view sendSubviewToBack:backgroundImage];
        livc.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        
        [livc.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [livc.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        [livc.logInView.logInButton setBackgroundColor:[UIColor colorWithRed:247/255.0f green:102/255.0f blue:38/255.0f alpha:1.0f]];
        livc.logInView.logInButton.titleLabel.font = [UIFont fontWithName:@"Futura" size:23.0];
        livc.logInView.logInButton.titleLabel.shadowOffset = CGSizeMake(0, 0);
//        [livc.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        [livc.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
//        [livc.logInView.facebookButton setBackgroundColor:[UIColor colorWithRed:0.22f green:0.42f blue:0.58f alpha:0.8f]];
        
        [livc.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [livc.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        [livc.logInView.signUpButton setBackgroundColor:[UIColor colorWithRed:0.07f green:0.48f blue:0.07f alpha:1.0f]];
        livc.logInView.signUpButton.titleLabel.font = [UIFont fontWithName:@"Futura" size:23.0];
        livc.logInView.signUpButton.titleLabel.shadowOffset = CGSizeMake(0, 0);

    }
}


@end
