//
//  SearchResultsViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultsTableViewCell.h"
#import <Parse/Parse.h>

@interface SearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (copy, nonatomic) NSArray *searchResultsArray;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFQuery *usersWithMatchingTagsQuery = [PFUser query];
    [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:self.selectedTagsArray];
    [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResultsArray = objects;
        [self.myTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCellReuseID"];
    
    if (self.searchResultsArray[indexPath.row][@"avatar"])
    {
        [self.searchResultsArray[indexPath.row][@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                cell.myImageView.image = photo;
            }
        }];
    }
    
    cell.myExpertiseLabel.text = self.searchResultsArray[indexPath.row][@"expertise"];
    cell.myUsernameLabel.text = self.searchResultsArray[indexPath.row][@"username"];
    return cell;
}

@end
