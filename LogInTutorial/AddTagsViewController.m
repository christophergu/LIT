//
//  AddTagsViewController.m
//  LIT
//
//  Created by Christopher Gu on 9/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AddTagsViewController.h"

@interface AddTagsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tagsSelectTableView;
@property (copy, nonatomic) NSArray *categoriesKeysArray;

@end

@implementation AddTagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tagsSelectTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesKeysArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagCellReuseID"];
    cell.textLabel.text = self.categoriesKeysArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
