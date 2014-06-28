//
//  TagsViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/26/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "TagsViewController.h"
#import "SearchResultsViewController.h"
#import "TagsCollectionViewCell.h"
#import <Parse/Parse.h>

@interface TagsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) NSArray *categoriesArray;
@property (copy, nonatomic) NSArray *categoriesKeysArray;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView01;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView02;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView03;
@property (strong, nonatomic) NSMutableArray *selectedTagsMutableArray;
@property (strong, nonatomic) PFUser *currentUser;




@end

@implementation TagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    
    NSDictionary *categoryArt = @{@"Art": [UIImage imageNamed:@"art"]};
    NSDictionary *categoryCooking = @{@"Cooking": [UIImage imageNamed:@"cooking"]};
    self.categoriesArray = @[categoryArt, categoryCooking];
    self.categoriesKeysArray = @[@"Art", @"Cooking"];
    self.selectedTagsMutableArray = [NSMutableArray new];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.categoriesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TagsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TagsReuseCellID" forIndexPath:indexPath];
    
    cell.myImageView.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
    cell.myLabel.text = self.categoriesKeysArray[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tagImageView01.image)
    {
        [self.selectedTagsMutableArray addObject:self.categoriesKeysArray[indexPath.row]];
        self.tagImageView01.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
    }
    else if (!self.tagImageView02.image)
    {
        [self.selectedTagsMutableArray addObject:self.categoriesKeysArray[indexPath.row]];
        self.tagImageView02.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
    }
    else if (!self.tagImageView03.image)
    {
        [self.selectedTagsMutableArray addObject:self.categoriesKeysArray[indexPath.row]];
        self.tagImageView03.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
    }
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    NSLog(@"%@",self.selectedTagsMutableArray);
    if (self.selectedTagsMutableArray && (self.selectedTagsMutableArray.count > 0))
    {
        if (self.choosingTagsForExpertise)
        {
            self.currentUser[@"tags"] = self.selectedTagsMutableArray;
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"UnwindFromTagsSegue" sender:self];
            }];
        }
        else
        {
            [self performSegueWithIdentifier:@"TagsToResultsSegue" sender:self];
        }
    }
    else
    {
        UIAlertView *tagsRequiredAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You need to select at least one tag." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [tagsRequiredAlert show];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagsToResultsSegue"])
    {
        SearchResultsViewController *srvc = segue.destinationViewController;
        srvc.selectedTagsArray = self.selectedTagsMutableArray;
    }
}

@end
