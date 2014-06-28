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
    
    self.delegate = self;
    self.signUpController.delegate = self;
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
