//
//  VideoPlayViewController.m
//  LiveIt
//
//  Created by Christopher Gu on 9/21/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "VideoPlayViewController.h"

@interface VideoPlayViewController ()
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.navigationController.navigationItem.backBarButtonItem.enabled = NO;
//
//    [self performSelector:@selector(enableBackButton) withObject:nil afterDelay:1.5];

    NSString *videoIdentifierString = self.videoIdentifier;
    
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iframe-player" ofType:@"html"];
    NSString *embedHTML =
    [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSString *embedHTMLWithId = [NSString stringWithFormat:embedHTML, videoIdentifierString];
    
    self.webView = [[UIWebView alloc]
                    initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.webView loadHTMLString:embedHTMLWithId baseURL:[[NSBundle mainBundle] resourceURL]];
    [self.webView setDelegate:self];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    
    [self.view addSubview:_webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}

- (void) enableBackButton
{
    self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webView.frame = f;
}


@end
