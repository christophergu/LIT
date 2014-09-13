//
//  VideoViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "VideoViewController.h"
#import "RecordVideoViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "GTLYouTube.h"
#import "Utils.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface VideoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) PFUser *currentUser;
@property (nonatomic) AVPlayer *avPlayer;

@end

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.currentUser = [PFUser currentUser];
    
    _uploadVideo = [[YouTubeUploadVideo alloc] init];
    _uploadVideo.delegate = self;
    
    // Initialize the youtube service & load existing credentials from the keychain if available
    self.youtubeService = [[GTLServiceYouTube alloc] init];
    self.youtubeService.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
}


// Helper to check if user is authorized
- (BOOL)isAuthorized {
    return [((GTMOAuth2Authentication *)self.youtubeService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to YouTube.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the YouTube service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [Utils showAlert:@"Authentication Error" message:error.localizedDescription];
        self.youtubeService.authorizer = nil;
    } else {
        self.youtubeService.authorizer = authResult;
        [self pickAndProcessAVideoToSave];
    }
}


- (IBAction)onRecordVideoPressed:(id)sender
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Profile"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];

    [self performSegueWithIdentifier:@"RecordVideoSegue" sender:self];
}

- (IBAction)onPlayButtonPressed:(id)sender
{
    [[self navigationController] pushViewController:[self createAuthController] animated:NO];

//    if (self.currentUser[@"video"])
//    {
////        PFFile *parseVideo = self.currentUser[@"video"];
////        NSURL *parseVideoURL = [NSURL URLWithString:parseVideo.url];
////        NSLog(@"parse url %@", parseVideo.url);
//        
////        NSString *filePath = [parseVideo url];
////        
////        //play audiofile streaming
////        self.avPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:filePath]];
////        self.avPlayer.volume = 1.0f;
////        [self.avPlayer play];
//        
//        MPMoviePlayerViewController *moviePlayer;
//        
////        moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:parseVideoURL];
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:moviePlayer  name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(videoFinished:)
//                                                     name:MPMoviePlayerPlaybackDidFinishNotification
//                                                   object:moviePlayer.moviePlayer];
//        moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//        [moviePlayer.moviePlayer prepareToPlay];
//        
//        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
//        
//        [moviePlayer.moviePlayer play];
//    }
//    else
//    {
//        NSLog(@"there is no video");
//    }
}

//- (IBAction)onPlayButtonPressed:(id)sender
//{
//    //    NSBundle *bundle = [NSBundle mainBundle];
//    //    NSString *moviePath = [bundle pathForResource:@"disc" ofType:@"mp4"];
//    if (self.currentUser[@"video"])
//    {
//        PFFile *parseVideo = self.currentUser[@"video"];
//        NSURL *parseVideoURL = [NSURL URLWithString:parseVideo.url];
//        NSLog(@"data string %@", parseVideoURL);
//        
//        MPMoviePlayerController * moviePlayer;
//        
//        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:parseVideoURL];
//        [moviePlayer prepareToPlay];
//        
//        [self.view addSubview:moviePlayer.view];
//        moviePlayer.fullscreen = YES;
//        moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//        [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
//        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        
//        [moviePlayer play];
//    }
//    else
//    {
//        NSLog(@"there is no video");
//    }
//    
//}

-(void)videoFinished:(NSNotification*)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

#pragma mark - image picker delegate methods

- (IBAction)onSaveButtonPressed:(id)sender
{
    if (![self isAuthorized]) {
        NSLog(@"not authorized");
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        //        [[self navigationController] pushViewController:[self createAuthController] animated:NO];
        
//        [self performSelector:@selector(createAndPushAuthController:) withObject:self afterDelay:2];
        
        [[self navigationController] pushViewController:[self createAuthController] animated:NO];
    }
    else
    {
        [self pickAndProcessAVideoToSave];
    }
}

-(void) pickAndProcessAVideoToSave
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    
    [self presentViewController:picker animated:YES completion:nil];
}

//- (void)createAndPushAuthController:(UIViewController *)controller
//{
//    [[self navigationController] pushViewController:[self createAuthController] animated:NO];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        self.videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"%@",self.videoUrl);
        NSData *videoData = [NSData dataWithContentsOfURL:self.videoUrl];
        
        [self.uploadVideo uploadYouTubeVideoWithService:_youtubeService
                                               fileData:videoData
                                                  title:@"test"
                                            description:@"test"];
    }
    else
    {
        // maybe alertView that it is not a video, test what happens first
    }
}

#pragma mark - uploadYouTubeVideo

- (void)uploadYouTubeVideo:(YouTubeUploadVideo *)uploadVideo
      didFinishWithResults:(GTLYouTubeVideo *)video {
    NSLog(@"ya?");
    [Utils showAlert:@"Video Uploaded" message:video.identifier];
}

- (IBAction)unwindToVideoVC:(UIStoryboardSegue *)unwindSegue
{

}


@end
