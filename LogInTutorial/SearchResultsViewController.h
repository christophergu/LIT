//
//  SearchResultsViewController.h
//  LIT
//
//  Created by Christopher Gu on 6/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UIViewController
@property (copy, nonatomic) NSDictionary *selectedTagsDictionary;
@property (assign, nonatomic) BOOL viewAllChosen;
@property (nonatomic) NSArray *selectedExpertiseUsersArray;

@end
