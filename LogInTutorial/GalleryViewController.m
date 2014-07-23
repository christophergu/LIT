//
//  GalleryViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryCollectionViewCell.h"

@interface GalleryViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *instructionsUIView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@end

@implementation GalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.instructionsUIView.alpha = 0.0;
    self.currentUser = [PFUser currentUser];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.ownProfile)
    {
        return [self.currentUser[@"gallery"] count];
    }
    else
    {
        return [self.selectedUserProfile[@"gallery"] count];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![self.currentUser[@"gallery"] isEqual:[NSNull null]] && !(self.currentUser[@"gallery"] == nil))
    {
        NSLog(@"there is a gallery");
        self.instructionsUIView.alpha = 0.0;
    }
    else
    {
        NSLog(@"there isn't a gallery");
        self.instructionsUIView.alpha = 1.0;
    }
    
    [self.myCollectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryReuseCellID" forIndexPath:indexPath];
    __block UIImage *photo;
    
    PFFile *image;
    
    if (self.ownProfile)
    {
        image = self.currentUser[@"gallery"][indexPath.row];
    }
    else
    {
        image = self.selectedUserProfile[@"gallery"][indexPath.row];
    }

    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        photo = [UIImage imageWithData:data];
        cell.myImageView.image = photo;
    }];

    return cell;
}

#pragma mark - image picker delegate methods

- (IBAction)onAddButtonPressed:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;

    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    // saving a uiimage to pffile
    UIImage *pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData* data = UIImageJPEGRepresentation(pickedImage,1.0f);
    PFFile *imageFile = [PFFile fileWithData:data];
    [self.currentUser addUniqueObject:imageFile forKey:@"gallery"];
    
    [self.currentUser saveInBackground];
}

@end
