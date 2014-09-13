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

@interface TagsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (copy, nonatomic) NSArray *categoriesArray;
@property (copy, nonatomic) NSArray *categoriesKeysArray;

@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *browseRandomBarButtonItem;



@end

@implementation TagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.browseRandomBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Futura" size:11.0], NSFontAttributeName,
                                        [UIColor orangeColor], NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];
    
    self.currentUser = [PFUser currentUser];
    
//    NSDictionary *categoryAcademics = @{@"Academics": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryAdventure = @{@"Adventure": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryArt = @{@"Art": [UIImage imageNamed:@"art"]};
//    NSDictionary *categoryBusiness = @{@"Business": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryCooking = @{@"Cooking": [UIImage imageNamed:@"cooking"]};
//    NSDictionary *categoryCreative = @{@"Creative": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryExtreme = @{@"Extreme": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryFitness = @{@"Fitness": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryGaming = @{@"Gaming": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryMusic = @{@"Music": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryOutdoors = @{@"Outdoors": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryPhysical = @{@"Physical": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryRelaxation = @{@"Relaxation": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categorySocial = @{@"Social": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categorySpiritual = @{@"Spiritual": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categorySports = @{@"Sports": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categorySupport = @{@"Support": [UIImage imageNamed:@"tagBackground"]};
//    NSDictionary *categoryTechnology = @{@"Technology": [UIImage imageNamed:@"tagBackground"]};
    
    
//    self.categoriesArray = @[categoryAcademics,
//                             categoryAdventure,
//                             categoryArt,
//                             categoryBusiness,
//                             categoryCooking,
//                             categoryCreative,
//                             categoryExtreme,
//                             categoryFitness,
//                             categoryGaming,
//                             categoryMusic,
//                             categoryOutdoors,
//                             categoryPhysical,
//                             categoryRelaxation,
//                             categorySocial,
//                             categorySpiritual,
//                             categorySports,
//                             categorySupport,
//                             categoryTechnology];
    
    self.categoriesKeysArray = @[@"ACADEMICS",
                                 @"ART",
                                 @"BUSINESS",
                                 @"CULINARY",
                                 @"FASHION & BEAUTY",
                                 @"FITNESS & NUTRITION",
                                 @"MILITARY",
                                 @"MUSIC",
                                 @"SPORTS",
                                 @"TECHNOLOGY",
                                 @"OTHER"];
}

-(void)viewWillAppear:(BOOL)animated
{

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesKeysArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectReuseCellID"];
    cell.textLabel.text = self.categoriesKeysArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:25];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SearchResultsViewController *srvc = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"TagsToResultsSegue"])
    {
    }
    if ([segue.identifier isEqualToString:@"ViewAllSegue"])
    {
        srvc.viewAllChosen = 1;
    }
}

@end
