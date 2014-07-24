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
    NSBundle *bundle = [NSBundle mainBundle];
    
    // retrieve the path from parse
    NSString *moviePath = [bundle pathForResource:@"disc" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    MPMoviePlayerController *theMoviPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    theMoviPlayer.controlStyle = MPMovieControlStyleFullscreen;
    theMoviPlayer.view.transform = CGAffineTransformConcat(theMoviPlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    [theMoviPlayer.view setFrame:backgroundWindow.frame];
    [backgroundWindow addSubview:theMoviPlayer.view];
    [theMoviPlayer play];
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
    
    PFFile *videoFile;
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:moviePath]];
        videoFile = [PFFile fileWithData:videoData];
        
        [self.currentUser addUniqueObject:videoFile forKey:@"video"];
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
