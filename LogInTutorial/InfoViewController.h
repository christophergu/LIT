//
//  InfoViewController.h
//  LIT
//
//  Created by Christopher Gu on 8/12/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InfoViewController : UIViewController

@property (assign, nonatomic) BOOL ownProfile;
@property (strong, nonatomic) PFUser *selectedUserProfile;

@end
