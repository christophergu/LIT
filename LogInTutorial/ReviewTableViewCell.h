//
//  ReviewTableViewCell.h
//  LIT
//
//  Created by Christopher Gu on 9/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface ReviewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UILabel *reviewerLabel;
@property int ratingInt;

@end
