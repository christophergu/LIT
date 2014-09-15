//
//  VideoViewController.m
//  LIT
//
//  Created by Christopher Gu on 7/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "VideoViewController.h"
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
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property BOOL recordButtonTappedBOOL;
@property BOOL uploadButtonTappedBOOL;

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

- (IBAction)signInForNowButtonTapped:(id)sender
{
    [[self navigationController] pushViewController:[self createAuthController] animated:NO];
}

- (IBAction)onPlayButtonPressed:(id)sender
{
    
}

- (IBAction)onRecordVideoPressed:(id)sender
{
    self.recordButtonTappedBOOL = 1;
    [self startCameraControllerFromViewController:self usingDelegate:self];
    
//    UIBarButtonItem *newBackButton =
//    [[UIBarButtonItem alloc] initWithTitle:@"Profile"
//                                     style:UIBarButtonItemStyleBordered
//                                    target:nil
//                                    action:nil];
//    [[self navigationItem] setBackBarButtonItem:newBackButton];
//
//    [self performSegueWithIdentifier:@"RecordVideoSegue" sender:self];
}

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                 usingDelegate:(id )delegate {
    // 1 - Validattions
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Get image picker
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:cameraUI animated:YES completion:^{
        
    }];
    return YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}






-(void)videoFinished:(NSNotification*)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

#pragma mark - image picker delegate methods

- (IBAction)onSaveButtonPressed:(id)sender
{
    self.uploadButtonTappedBOOL = 1;
    
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.recordButtonTappedBOOL)
    {
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        // Handle a movie capture
        if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self,
                                                    @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        }
    }
    else if (self.uploadButtonTappedBOOL)
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
    
    self.recordButtonTappedBOOL = 0;
    self.uploadButtonTappedBOOL = 0;
    
    NSLog(@"record bool %hhd",self.recordButtonTappedBOOL);
    NSLog(@"upload bool %hhd",self.uploadButtonTappedBOOL);
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
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
