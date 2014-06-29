//
//  ProfileViewController.h
//  LIT
//
//  Created by Christopher Gu on 6/27/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController
@property (assign, nonatomic) BOOL ownProfile;
@property (strong, nonatomic) PFUser *selectedUserProfile;

@end
