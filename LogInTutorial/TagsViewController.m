//
//  TagsViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/26/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "TagsViewController.h"
#import "TagsCollectionViewCell.h"

@interface TagsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) NSArray *categoriesArray;
@property (copy, nonatomic) NSArray *categoriesKeysArray;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView01;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView02;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView03;
@property (strong, nonatomic) NSMutableArray *selectedTagsMutableArray;




@end

@implementation TagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self performSegueWithIdentifier:@"TagsToResultsSegue" sender:self];
}

@end
