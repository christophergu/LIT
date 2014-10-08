//
//  LogInViewController.m
//  LogInTutorial
//
//  Created by Christopher Gu on 5/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "LogInViewController.h"
#import "ProfileViewController.h"

@interface LogInViewController ()<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation LogInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

//    PFUser *userNow = [PFUser currentUser];
//    if (userNow)
//    {
//        [self performSegueWithIdentifier:@"LogInToProfileSegue" sender:self];
//    }
    
    self.logInView.signUpLabel.shadowOffset = CGSizeMake(0, 0);
    self.logInView.dismissButton.alpha = 0;
    
    self.delegate = self;
    self.signUpController.delegate = self;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBackgroundWithLogo"]];
    [self.signUpController.view addSubview:backgroundImage];
    [self.signUpController.view sendSubviewToBack:backgroundImage];
    
    [self.signUpController.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.signUpController.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [self.signUpController.signUpView.signUpButton setBackgroundColor:[UIColor colorWithRed:0.07f green:0.48f blue:0.07f alpha:1.0f]];
    self.signUpController.signUpView.signUpButton.titleLabel.font = [UIFont fontWithName:@"Futura" size:23.0];
    self.signUpController.signUpView.signUpButton.titleLabel.shadowOffset = CGSizeMake(0, 0);

    self.signUpController.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
//    if (self.becauseLoginRequired)
//    {
//        
//        
//        [self performSegueWithIdentifier:@"LoginToConversationVCSegue" sender:self];
//        
//        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//        [navigationArray removeObjectAtIndex:4];
//        self.navigationController.viewControllers = navigationArray;
//    }
//    else
//    {
        [self performSegueWithIdentifier:@"LogInToProfileSegue" sender:self];
        [self removeLogInSignUpFromStack];
//    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
//    if (self.becauseLoginRequired)
//    {
//        [self performSegueWithIdentifier:@"LoginToConversationVCSegue" sender:self];
//        
//        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//        [navigationArray removeObjectAtIndex:4];
//        self.navigationController.viewControllers = navigationArray;
//    }
//    else
//    {
        [self dismissViewControllerAnimated:NO completion:^{
            [self performSegueWithIdentifier:@"LogInToProfileSegue" sender:self];
        }];
        
        [self removeLogInSignUpFromStack];
//    }
}

- (void)removeLogInSignUpFromStack
{
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [navigationArray removeObjectAtIndex:1];
    self.navigationController.viewControllers = navigationArray;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LogInToProfileSegue"])
    {
        ProfileViewController *pvc = segue.destinationViewController;
        pvc.ownProfile = 1;
    }
}


@end
