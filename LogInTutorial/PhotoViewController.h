//
//  PhotoViewController.h
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PhotoViewController : UIViewController

@property (assign, nonatomic) BOOL ownProfile;
@property (strong, nonatomic) PFUser *selectedUserProfile;
@property (nonatomic) int startingIndexPathRow;

@end
