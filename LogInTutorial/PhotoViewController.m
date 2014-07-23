//
//  PhotoViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBarButton;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    
    __block UIImage *photo;
    
    PFFile *image;
    
    if (self.ownProfile)
    {
        self.trashBarButton.enabled = YES;
        self.trashBarButton.tintColor = [UIColor whiteColor];
        image = self.currentUser[@"gallery"][self.startingIndexPathRow];
    }
    else
    {
        self.trashBarButton.enabled = NO;
        self.trashBarButton.tintColor = [UIColor clearColor];
        image = self.selectedUserProfile[@"gallery"][self.startingIndexPathRow];
    }
    
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        photo = [UIImage imageWithData:data];
        self.myImageView.image = photo;
    }];
}

- (IBAction)onTrashButtonPressed:(id)sender
{
    [self.currentUser removeObject:self.currentUser[@"gallery"][self.startingIndexPathRow] forKey:@"gallery"];
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self performSegueWithIdentifier:@"UnwindToGallerySegue" sender:self];
    }];
}
@end
