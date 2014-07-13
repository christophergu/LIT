//
//  WebViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url;

    if ([self.urlString hasPrefix:@"http://"])
    {
        url = [NSURL URLWithString:self.urlString];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.urlString]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

@end
