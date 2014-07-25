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


@interface VideoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) PFUser *currentUser;


@end

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.currentUser = [PFUser currentUser];
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
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *moviePath = [bundle pathForResource:@"disc" ofType:@"mp4"];
    if (self.currentUser[@"video"])
    {
        PFFile *parseVideo = self.currentUser[@"video"];
        NSURL *parseVideoURL = [NSURL URLWithString:parseVideo.url];
        NSLog(@"data string %@", parseVideo.url);
        
        MPMoviePlayerController * moviePlayer;
        
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:parseVideoURL];
        [moviePlayer prepareToPlay];

        [self.view addSubview:moviePlayer.view];
        moviePlayer.fullscreen = YES;
        moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [moviePlayer play];
    }
    else
    {
        NSLog(@"there is no video");
    }

}

#pragma mark - image picker delegate methods

- (IBAction)onSaveButtonPressed:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        PFFile *videoFile = [PFFile fileWithData:videoData];
        self.currentUser[@"video"] = videoFile;
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        }];
    }
    else
    {
        // maybe alertView that it is not a video, test what happens first
    }
}


- (IBAction)unwindToVideoVC:(UIStoryboardSegue *)unwindSegue
{

}


@end
