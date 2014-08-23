//
//  InfoViewController.m
//  LIT
//
//  Created by Christopher Gu on 8/12/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "InfoViewController.h"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *uiViewForScrollView;
@property (weak, nonatomic) IBOutlet UITextView *achievementsTextView;

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.ownProfile)
    {
        // if this is not your profile, but someone you searched
        self.achievementsTextView.editable = NO;
        if (self.selectedUserProfile[@"achievements"])
        {
             self.achievementsTextView.text = self.selectedUserProfile[@"achievements"];
        }
    }
    else
    {
        
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    if (isiPhone5)
    {
        // this is iphone 4 inch
        self.scrollView.contentSize = CGSizeMake(320, 466 + 216);
    }
    else
    {
        NSLog(@"small");
        self.scrollView.contentSize = CGSizeMake(320, 466 + 216 + 88);
    }
    self.scrollView.scrollEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.uiViewForScrollView];
}

@end
