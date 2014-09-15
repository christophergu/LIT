//
//  AddAReviewViewController.m
//  LIT
//
//  Created by Christopher Gu on 9/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AddAReviewViewController.h"

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@interface AddAReviewViewController ()<UITextViewDelegate, DYRateViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UILabel *byReviewerLabel;
@property (nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIView *uiBigViewInsideScrollView;
@property int ratingInt;
@end

@implementation AddAReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    if (self.currentUser)
    {
        NSLog(@"is");
        self.byReviewerLabel.text = [NSString stringWithFormat:@"By: %@",self.currentUser.username];
    }
    else
    {
        self.byReviewerLabel.text = @"Anonymous";
    }

    self.reviewTextView.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    [self setUpEditableRateView];
}


- (void)setUpEditableRateView {
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 47, self.view.bounds.size.width, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    rateView.padding = 20;
    rateView.alignment = RateViewAlignmentCenter;
    rateView.editable = YES;
    rateView.delegate = self;
    
    rateView.rate = 5;
    [self.uiBigViewInsideScrollView addSubview:rateView];
}

#pragma mark - DYRateViewDelegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate
{
    self.ratingInt = rate.intValue;
}

-(void)dismissKeyboard
{
    [self.reviewTextView resignFirstResponder];
}

- (IBAction)doneButtonTapped:(id)sender
{
    PFObject *review = [PFObject objectWithClassName:@"Review"];
    
    if (self.currentUser)
    {
        [review setObject:self.currentUser.username forKey:@"reviewerName"];
    }
    else
    {
        [review setObject:@"Anonymous" forKey:@"reviewerName"];
    }
    [review setObject:self.selectedUserProfile.objectId forKey:@"reviewedObjectId"];
    [review setObject:self.selectedUserProfile.username forKey:@"reviewedUsername"];
    review[@"dateReviewed"] = [NSDate date];
    review[@"reviewText"] = self.reviewTextView.text;
    review[@"rating"] = @(self.ratingInt);

    if (!(allTrim(self.reviewTextView.text).length == 0))
    {
        [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please include a review."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
