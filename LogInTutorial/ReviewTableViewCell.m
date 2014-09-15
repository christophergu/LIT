//
//  ReviewTableViewCell.m
//  LIT
//
//  Created by Christopher Gu on 9/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ReviewTableViewCell.h"

@implementation ReviewTableViewCell

- (void)setUpRightAlignedRateView:(int)rating
{
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(150, 3, 160, 14)];
    rateView.rate = rating;
    rateView.alignment = RateViewAlignmentRight;
    [self addSubview:rateView];
}

- (void)awakeFromNib
{
    NSLog(@"int %d",self.ratingInt);
    
    NSString *ratingString = [NSString stringWithFormat:@"%d",self.ratingInt];
    
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(starsUpdate:)
                                                 name:@"UpdateRatingStars"
                                               object:nil];
}

-(void)starsUpdate:(NSNotification *)notification
{
    NSLog(@"notif %@",notification);
    [self setUpRightAlignedRateView:[notification.object intValue]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
}

@end
