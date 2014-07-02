//
//  SearchResultsViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultsTableViewCell.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface SearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (copy, nonatomic) NSArray *searchResultsArray;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSIndexPath *chosenIndexPath;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.viewAllChosen)
    {
        PFQuery *allUsersQuery = [PFUser query];
//        [allUsersQuery orderByAscending:@"expertise"];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey: @"expertise"
                                                                     ascending: YES
                                                                      selector: @selector(caseInsensitiveCompare:)];
        [allUsersQuery orderBySortDescriptor: descriptor];
        [allUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            self.searchResultsArray = [objects sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
                NSString *expertise1 = [user1[@"expertise"] lowercaseString];
                NSString *expertise2 = [user2[@"expertise"] lowercaseString];

                if ([expertise1 compare: expertise2] == NSOrderedAscending)
                {
                    NSLog(@"1 %@",expertise1);
                    NSLog(@"2 %@",expertise2);
                    return NSOrderedAscending;
                }
                else{
                    return NSOrderedDescending;
                }
            }];
            
//            self.searchResultsArray = objects;
            [self.myTableView reloadData];
        }];
    }
    else
    {
        PFQuery *usersWithMatchingTagsQuery = [PFUser query];
        [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:[self.selectedTagsDictionary allKeys]];
        [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.searchResultsArray = objects;
            [self.myTableView reloadData];
        }];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chosenIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SearchToProfileSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileViewController *pvc = segue.destinationViewController;
    {
        pvc.selectedUserProfile = self.searchResultsArray[self.chosenIndexPath.row];
    }
}

@end
