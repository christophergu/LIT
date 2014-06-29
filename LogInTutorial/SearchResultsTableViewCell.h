//
//  SearchResultsTableViewCell.h
//  LIT
//
//  Created by Christopher Gu on 6/29/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *myExpertiseLabel;
@property (weak, nonatomic) IBOutlet UILabel *myUsernameLabel;

@end
