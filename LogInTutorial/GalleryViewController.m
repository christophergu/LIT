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
        return 1;
    }
    else
    {
        return 0;
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
    UIImage *photo;
    
    NSArray *galleryArray = self.currentUser[@"gallery"];
    
    if (self.ownProfile)
    {
        photo = [UIImage imageWithData:galleryArray[indexPath.row]];
    }
//    else
//    {
//        photo = [UIImage imageWithData:self.selectedUserProfile[@"gallery"][indexPath.row]];
//    }
    cell.myImageView.image = photo;
    
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
