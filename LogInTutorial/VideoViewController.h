//
//  VideoViewController.h
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoData.h"
#import "YouTubeUploadVideo.h"

@interface VideoViewController : UIViewController<YouTubeUploadVideoDelegate>
//@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSURL *videoUrl;
@property(nonatomic, retain) GTLServiceYouTube *youtubeService;
//@property(nonatomic, retain) MPMoviePlayerController *player;
//@property(nonatomic, retain) UIScrollView *scrollView;
//@property(nonatomic, retain) UITextField *activeField;
@property(nonatomic, strong) YouTubeUploadVideo *uploadVideo;

@end
