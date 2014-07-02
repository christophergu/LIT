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
#import "TagsSelectButton.h"
#import <Parse/Parse.h>

@interface TagsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) NSArray *categoriesArray;
@property (copy, nonatomic) NSArray *categoriesKeysArray;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView01;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView02;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView03;
@property (strong, nonatomic) NSMutableDictionary *selectedTagsMutableDictionary;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet TagsSelectButton *tagSelectButton01;
@property (weak, nonatomic) IBOutlet TagsSelectButton *tagSelectButton02;
@property (weak, nonatomic) IBOutlet TagsSelectButton *tagSelectButton03;


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
    self.selectedTagsMutableDictionary = [NSMutableDictionary new];
    
    self.tagImageView01.clipsToBounds = YES;
    self.tagImageView02.clipsToBounds = YES;
    self.tagImageView03.clipsToBounds = YES;
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
    if (![[self.selectedTagsMutableDictionary allKeys] containsObject:[self.categoriesArray[indexPath.row] allKeys].firstObject])
    {
        if (!self.tagImageView01.image)
        {
            
            [self.selectedTagsMutableDictionary addEntriesFromDictionary:self.categoriesArray[indexPath.row]];
            self.tagSelectButton01.selectedCategoryDictionary = self.categoriesArray[indexPath.row];
            self.tagImageView01.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
        }
        else if (!self.tagImageView02.image)
        {
            [self.selectedTagsMutableDictionary addEntriesFromDictionary:self.categoriesArray[indexPath.row]];
            self.tagSelectButton02.selectedCategoryDictionary = self.categoriesArray[indexPath.row];
            self.tagImageView02.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
        }
        else if (!self.tagImageView03.image)
        {
            [self.selectedTagsMutableDictionary addEntriesFromDictionary:self.categoriesArray[indexPath.row]];
            self.tagSelectButton03.selectedCategoryDictionary = self.categoriesArray[indexPath.row];
            self.tagImageView03.image = self.categoriesArray[indexPath.row][self.categoriesKeysArray[indexPath.row]];
        }
    }
}

- (IBAction)onTagImageView01ButtonPressed:(id)sender
{
    if (self.tagImageView01.image)
    {
        [self.selectedTagsMutableDictionary removeObjectsForKeys: [self.tagSelectButton01.selectedCategoryDictionary allKeys]];
        self.tagImageView01.image = nil;
        NSLog(@"%@",self.selectedTagsMutableDictionary);
    }
}

- (IBAction)onTagImageView02ButtonPressed:(id)sender
{
    if (self.tagImageView01.image)
    {
        [self.selectedTagsMutableDictionary removeObjectsForKeys: [self.tagSelectButton02.selectedCategoryDictionary allKeys]];
        self.tagImageView02.image = nil;
        NSLog(@"%@",self.selectedTagsMutableDictionary);
    }
}

- (IBAction)onTagImageView03ButtonPressed:(id)sender
{
    if (self.tagImageView01.image)
    {
        [self.selectedTagsMutableDictionary removeObjectsForKeys: [self.tagSelectButton03.selectedCategoryDictionary allKeys]];
        self.tagImageView03.image = nil;
        NSLog(@"%@",self.selectedTagsMutableDictionary);
    }
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    NSLog(@"%@",self.selectedTagsMutableDictionary);
    if (self.selectedTagsMutableDictionary && (self.selectedTagsMutableDictionary.count > 0))
    {
        if (self.choosingTagsForExpertise)
        {
            self.currentUser[@"tags"] = [self.selectedTagsMutableDictionary allKeys];
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
    SearchResultsViewController *srvc = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"TagsToResultsSegue"])
    {
        srvc.selectedTagsDictionary = self.selectedTagsMutableDictionary;
    }
    if ([segue.identifier isEqualToString:@"ViewAllSegue"])
    {
        srvc.viewAllChosen = 1;
    }
}

@end
