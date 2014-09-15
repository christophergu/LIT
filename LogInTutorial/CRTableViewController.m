//
//  CRTableViewController.m
//  CRMultiRowSelector
//
//  Created by Christian Roman on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import "CRTableViewController.h"
#import "CRTableViewCell.h"
#import <Parse/Parse.h>

@interface CRTableViewController ()

@end

@implementation CRTableViewController

@synthesize dataSource;

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        self.title = @"Please select 1 or 2 tags";
        
//        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];//[UIColor colorWithRed:195/255.0f green:140/255.0f blue:69/255.0f alpha:1.0f];
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
//        [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Futura" size:21.0f]}];
        
//        [self.navigationController.navigationBar setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [UIFont fontWithName:@"Futura" size:21],
//          NSFontAttributeName, nil]];
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                        style:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
        [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont fontWithName:@"Futura" size:25.0], NSFontAttributeName,
                                                                [UIColor orangeColor], NSForegroundColorAttributeName,
                                                                nil]
                                                      forState:UIControlStateNormal];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        
        dataSource = [[NSArray alloc] initWithObjects:
                      @"ACADEMICS",
                      @"ART",
                      @"BUSINESS",
                      @"CULINARY",
                      @"FASHION & BEAUTY",
                      @"FITNESS & NUTRITION",
                      @"MILITARY",
                      @"MUSIC",
                      @"SPORTS",
                      @"TECHNOLOGY",
                      @"OTHER",
                      nil];
        
        selectedMarks = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Methods
- (void)done:(id)sender
{
    NSLog(@"%@", selectedMarks);
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"tags"] = selectedMarks;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
}

#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CRTableViewCellIdentifier = @"cellIdentifier";
    
    // init the CRTableViewCell
    CRTableViewCell *cell = (CRTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CRTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[CRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CRTableViewCellIdentifier];
    }
    
    // Check if the cell is currently selected (marked)
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    cell.isSelected = [selectedMarks containsObject:text] ? YES : NO;
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:20];
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [dataSource objectAtIndex:[indexPath row]];
    
    if ([selectedMarks containsObject:text])// Is selected?
        [selectedMarks removeObject:text];
    else
        if (selectedMarks.count < 2)
        {
            [selectedMarks addObject:text];
        }
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
