//
//  WebViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

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

- (void) webViewDidFinishLoad: (UIWebView *)myWebView
{
    [self.backButton setEnabled: [myWebView canGoBack]];
    [self.forwardButton setEnabled: [myWebView canGoForward]];
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self.webView goBack];
}

- (IBAction)onForwardButtonPressed:(id)sender {
    [self.webView goForward];
}

//- (IBAction)onStopLoadingButtonPressed:(id)sender {
//    [self.webView stopLoading];
//}

- (IBAction)onReloadButtonPressed:(id)sender {
    [self.webView reload];
}

@end
