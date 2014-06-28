//
//  ProfileViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/27/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *expertiseTextField;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *uiViewForScrollView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *avatarChangeButton;
@property (weak, nonatomic) IBOutlet UIButton *findLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *findLocationLabel;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagsListingLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if (self.fromSearch || self.fromSearchEnthusiast)
//    {
//        [self.leaderChosenFromSearch[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!error) {
//                UIImage *photo = [UIImage imageWithData:data];
//                self.avatarImageView.image = photo;
//            }
//        }];
//    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    if (!self.ownProfile)
    {
        [self.logoutBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
        self.logoutBarButtonItem.enabled = NO;
        self.aboutMeTextView.editable = NO;
        self.usernameTextField.borderStyle = UITextBorderStyleNone;
        self.usernameTextField.enabled = NO;
        self.locationTextField.borderStyle = UITextBorderStyleNone;
        self.locationTextField.enabled = NO;
        self.saveChangesButton.alpha = 0.0;

        // choose what to call the searched leader
        // deal with the website button check
        
        self.contactButton.layer.cornerRadius = 5.0f;
    }
    else
    {
        // this is if it's your own profile
        self.currentUser = [PFUser currentUser];

        self.websiteButton.alpha = 0.0;
        self.contactButton.alpha = 0.0;
        
        self.findLocationLabel.layer.cornerRadius = 5.0f;
        self.findLocationButton.alpha = 1.0;
        self.findLocationButton.layer.cornerRadius = 5.0f;
        
        // check if you already have a location before assigning findlocationlabel's alpha
        if (self.currentUser[@"city"] && self.currentUser[@"state"]) {
            self.findLocationLabel.alpha = 0.0;
            self.locationTextField.text = [NSString stringWithFormat:@"%@, %@",self.currentUser[@"city"],self.currentUser[@"state"]];
        }
        else
        {
            self.findLocationLabel.alpha = 1.0;
        }
        
        if (self.currentUser[@"avatar"])
        {
            [self.currentUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.avatarImageView.image = photo;
                }
            }];
        }

        self.usernameTextField.text = self.currentUser.username;
        self.expertiseTextField.text = self.currentUser[@"expertise"];
        
        if (self.currentUser[@"aboutMe"])
        {
            self.aboutMeTextView.text = self.currentUser[@"aboutMe"];
        }
        else
        {
            self.aboutMeTextView.text = @"About Me";
            self.aboutMeTextView.textAlignment = NSTextAlignmentCenter;
        }
        
        self.aboutMeTextView.textColor = [UIColor colorWithWhite: 0.8 alpha:1]; //optional
        [self.aboutMeTextView.layer setBorderColor:[[UIColor colorWithWhite: 0.8 alpha:1] CGColor]];
        [self.aboutMeTextView.layer setBorderWidth:0.5];
        self.aboutMeTextView.layer.cornerRadius = 5;
        self.aboutMeTextView.clipsToBounds = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize = CGSizeMake(320, 720);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.uiViewForScrollView];
}

-(void)dismissKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.expertiseTextField resignFirstResponder];
    [self.aboutMeTextView resignFirstResponder];
}

#pragma mark - about me text view delegate methods (for placehoder text to exist)

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.aboutMeTextView.text isEqualToString:@"About Me"]) {
        self.aboutMeTextView.text = @"";
        self.aboutMeTextView.textColor = [UIColor blackColor]; //optional
        self.aboutMeTextView.textAlignment = NSTextAlignmentLeft;
        //        [self.aboutMeTextView becomeFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.aboutMeTextView.text isEqualToString:@""]) {
        self.aboutMeTextView.text = @"About Me";
        self.aboutMeTextView.textColor = [UIColor colorWithWhite: 0.8 alpha:1]; //optional
        self.aboutMeTextView.textAlignment = NSTextAlignmentCenter;
        [self.aboutMeTextView resignFirstResponder];
    }
}


#pragma mark - location methods
// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // this creates a MKReverseGeocoder to find a placemark using the found coordinates
    MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geoCoder.delegate = self;
    [geoCoder start];
}


// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}

// update these deprecated with CLGeocoder

// this delegate is called when the reverseGeocoder finds a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    // with the placemark you can now retrieve the city name
    NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
    NSString *state = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressStateKey];
    
    [self.locationManager stopUpdatingLocation];
    
    self.currentUser[@"city"] = city;
    self.currentUser[@"state"] = state;
    self.currentUser[@"latitude"] = @(self.locationManager.location.coordinate.latitude);
    self.currentUser[@"longitude"] = @(self.locationManager.location.coordinate.longitude);
    [self.currentUser saveInBackground];
    
    // findLocationLabel animations
    [UIView animateKeyframesWithDuration:2.0f delay:0.0f options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.25 animations:^{
            self.findLocationLabel.text = @"Searching...";
            self.findLocationLabel.alpha = 1.0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.5 animations:^{
            // do nothing
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            self.locationTextField.text = [NSString stringWithFormat:@"%@, %@",city, state];
            self.findLocationLabel.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        
    }];
    
    
}

// this delegate is called when the reversegeocoder fails to find a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"reverseGeocoder:%@ didFailWithError:%@", geocoder, error);
    
    // put an alert here that says they aren't connected to the internet or something to that effect
    UIAlertView *noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You must have an internet connection to find your location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [noConnectionAlert show];
}

#pragma mark - text view related methods

- (IBAction)onUsernameDidEndOnExit:(id)sender
{
    [self.usernameTextField endEditing:YES];
}

- (IBAction)onExpertiseTextViewDidEndOnExit:(id)sender
{
    [self.expertiseTextField endEditing:YES];
}

- (IBAction)onExpertiseTextViewEditingDidEnd:(id)sender
{
    NSLog(@"ya");
    if (![self.expertiseTextField.text isEqualToString:self.currentUser[@"expertise"]])
    {
        NSLog(@"different");
        self.currentUser[@"expertise"] = self.expertiseTextField.text;
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            UIAlertView *needTagsAlert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Please add one or more tags to this Expertise so users can better find you!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [needTagsAlert show];
        }];
    }
    [self.expertiseTextField endEditing:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"ExpertiseEditedSegue" sender:self];
    }
}

#pragma mark - button methods

- (IBAction)onFindLocationButtonPressed:(id)sender
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
}

- (IBAction)onContactButtonPressed:(id)sender
{
    
}

- (IBAction)onSaveChangesButtonPressed:(id)sender
{
    self.currentUser.username = self.usernameTextField.text;
    self.currentUser[@"expertise"] = self.expertiseTextField.text;
//    self.currentUser.password = self.passwordTextField.text;
//    self.currentUser.email = self.emailTextField.text;
    self.currentUser[@"aboutMe"] = self.aboutMeTextView.text;
    self.currentUser[@"website"] = self.websiteTextField.text;
    
    [self.currentUser saveInBackground];
}

- (IBAction)onAvatarChangeButtonPressed:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	if((UIButton *) sender == self.avatarChangeButton)
    {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else
    {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    // saving a uiimage to pffile
    UIImage *pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData* data = UIImagePNGRepresentation(pickedImage);// UIImageJPEGRepresentation(pickedImage,1.0f);
    PFFile *imageFile = [PFFile fileWithData:data];
    PFUser *user = [PFUser currentUser];
    
    user[@"avatar"] = imageFile;
    
    // getting a uiimage from pffile
    [user[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            self.avatarImageView.image = photo;
        }
    }];
    
    [user saveInBackground];
}

@end
