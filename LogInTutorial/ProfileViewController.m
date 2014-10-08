//
//  ProfileViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/27/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ProfileViewController.h"
#import "WebViewController.h"
#import "TagsViewController.h"
#import "ReviewTableViewCell.h"
#import "AddAReviewViewController.h"
#import "CRTableViewController.h"
#import "GalleryViewController.h"
#import "InfoViewController.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "VideoViewController.h"
#import "VideoPlayViewController.h"

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *expertiseTextField;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *uiViewForScrollView;
@property (weak, nonatomic) IBOutlet UIView *achievementUIView;
@property (weak, nonatomic) IBOutlet UIView *aboutMeUIView;
@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *avatarChangeButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundChangeButton;
@property BOOL avatarButtonPressed;
@property BOOL backgroundButtonPressed;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *ratingsView;
@property (nonatomic) NSArray *ratingsArray;
@property (weak, nonatomic) IBOutlet UITableView *ratingsTableView;

@property (weak, nonatomic) IBOutlet UIButton *findLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *addAReviewButton;

@property (weak, nonatomic) IBOutlet UILabel *findLocationLabel;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagsListingLabel;
@property CGFloat containerViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expertiseLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.currentUser = [PFUser currentUser];
    PFGeoPoint *lat = [[PFGeoPoint alloc] init];
    lat = self.currentUser[@"geoPoint"];
    
    NSLog(@"there  %@",self.currentUser[@"latitude"]);

    NSLog(@"eee %@",self.currentUser[@"geoPoint"]);
    NSLog(@"lat man %f",lat.latitude);

    
    
    
    self.photoImageView.clipsToBounds = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    if (!self.ownProfile)
    {
        // if this is not your profile, but someone you searched
        
        // set up new search bar button
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.numberOfLines = 0;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.titleLabel.font = [UIFont fontWithName:@"Futura" size:11.0];
        [button setTitleColor:[UIColor colorWithRed:247/255.0 green:102/255.0 blue:38/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(unwindToInitialSearch) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"NEW\nSEARCH", nil) forState:UIControlStateNormal];
        [button sizeToFit];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        
        [self.logoutBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
        self.logoutBarButtonItem.enabled = NO;
        self.aboutMeTextView.editable = NO;
        self.usernameTextField.borderStyle = UITextBorderStyleNone;
        self.usernameTextField.enabled = NO;
        self.expertiseTextField.borderStyle = UITextBorderStyleNone;
        self.expertiseTextField.enabled = NO;
        self.findLocationButton.alpha = 0.0;
        self.findLocationLabel.alpha = 0.0;
        self.locationTextField.borderStyle = UITextBorderStyleNone;
        self.locationTextField.enabled = NO;
        self.websiteTextField.borderStyle = UITextBorderStyleNone;
        self.websiteTextField.enabled = NO;
        self.saveChangesButton.alpha = 0.0;


        
        if (self.selectedUserProfile[@"avatar"])
        {
            [self.selectedUserProfile[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.avatarImageView.image = photo;
                }
            }];
        }
        
        if (self.selectedUserProfile[@"backgroundImage"])
        {
            [self.selectedUserProfile[@"backgroundImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.backgroundImageView.image = photo;
                }
            }];
        }
        
        self.usernameTextField.alpha = 0;
        self.expertiseTextField.alpha = 0;
        self.locationTextField.alpha = 0;
        
        self.usernameLabel.text = self.selectedUserProfile.username;
        self.expertiseLabel.text = self.selectedUserProfile[@"expertise"];
        
        if ([self.selectedUserProfile[@"aboutMe"] isEqualToString:@"About Me"])
        {
            NSLog(@"ya");
            self.aboutMeTextView.text = @"This user has not yet provided \"About Me\" details.";
            self.aboutMeTextView.textColor = [UIColor colorWithWhite: 0.8 alpha:1];
        }
        else if (self.selectedUserProfile[@"aboutMe"])
        {
            self.aboutMeTextView.text = self.selectedUserProfile[@"aboutMe"];
        }
        
        if (self.selectedUserProfile[@"city"] && self.selectedUserProfile[@"state"])
        {
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",self.selectedUserProfile[@"city"],self.selectedUserProfile[@"state"]];
        }
        else
        {
            self.locationTextField.text = @"This use has not yet provided \"Location\" details.";
        }
        
        if (self.selectedUserProfile[@"website"])
        {
            NSLog(@"website");
            self.websiteTextField.alpha = 0.0;
            self.websiteButton.alpha = 1.0;
            [self.websiteButton setTitle:self.selectedUserProfile[@"website"] forState:UIControlStateNormal];
        }
        else
        {
            NSLog(@"no website");
            self.websiteButton.alpha = 0.0;
            self.websiteTextField.placeholder = @"";
        }
        
        if ([self.selectedUserProfile[@"gallery"] firstObject]) {
            [[self.selectedUserProfile[@"gallery"] firstObject] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.photoImageView.image = photo;
                }
            }];
        }
        
        self.addAReviewButton.alpha = 1;
    }
    else
    {
        // this is if it's your own profile
        
        self.usernameLabel.alpha = 0;
        self.expertiseLabel.alpha = 0;
        self.locationLabel.alpha = 0;
        
        self.currentUser = [PFUser currentUser];

        if (self.currentUser[@"avatar"])
        {
            [self.currentUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.avatarImageView.image = photo;
                }
            }];
        }
        
        if (self.currentUser[@"backgroundImage"])
        {
            [self.currentUser[@"backgroundImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.backgroundImageView.image = photo;
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

        }
        
        if ([self.aboutMeTextView.text isEqualToString:@"About Me"])
        {
            self.aboutMeTextView.textColor = [UIColor colorWithWhite: 0.8 alpha:1]; //optional
        }
        
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
        
        if (self.currentUser[@"website"])
        {
            self.websiteTextField.text = self.currentUser[@"website"];
        }
        self.websiteButton.alpha = 0.0;
        self.contactButton.enabled = NO;
        self.addAReviewButton.alpha = 0;
        
        if ([self.currentUser[@"gallery"] firstObject]) {
            
            NSLog(@"shoudl get thumbnail");
            [[self.currentUser[@"gallery"] firstObject] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *photo = [UIImage imageWithData:data];
                    self.photoImageView.image = photo;
                }
            }];
        }
        else
        {
            NSLog(@"no photo gallery");
        }
        
    }
    
    
    // tests if you find yourself on search
    // make sure the current user is in the right place
//    if ([self.currentUser.objectId isEqualToString: self.selectedUserProfile.objectId])
//    {
//        self.addAReviewButton.alpha = 0;
//    }
//    else
//    {
//        self.addAReviewButton.alpha = 1;
//    }
}

-(void) unwindToInitialSearch
{
    [self performSegueWithIdentifier:@"UnwindToInitialSearchSegue" sender:self];
}

 -(void)viewWillAppear:(BOOL)animated
{
    if (self.ownProfile)
    {
        NSArray *tempTagArray = self.currentUser[@"tags"];
        
        if (tempTagArray && (tempTagArray.count > 0))
        {
            self.tagsListingLabel.text = [tempTagArray componentsJoinedByString:@", "];
            [self.tagsListingLabel setNumberOfLines:0];
            [self.tagsListingLabel sizeToFit];
        }
        
        [self retrieveAndProcessRatings:self.currentUser];
    }
    else
    {
        NSArray *tempTagArray = self.selectedUserProfile[@"tags"];
        
        if (tempTagArray && (tempTagArray.count > 0))
        {
            self.tagsListingLabel.text = [tempTagArray componentsJoinedByString:@", "];
            [self.tagsListingLabel setNumberOfLines:0];
            [self.tagsListingLabel sizeToFit];
        }
        
        [self retrieveAndProcessRatings:self.selectedUserProfile];
    }
}

- (void)retrieveAndProcessRatings:(PFUser *)user
{
    PFQuery *cumulativeReviewQuery = [PFQuery queryWithClassName:@"Review"];
    [cumulativeReviewQuery whereKey:@"reviewedObjectId" equalTo:user.objectId];
    [cumulativeReviewQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objob for reviews %@",[[objects firstObject] class]);
        self.ratingsArray = objects;
        
        int ratingSum = 0;
        int ratingCount = 0;
        
        for (PFObject *review in objects)
        {
            ratingSum += [review[@"rating"]intValue];
            ratingCount++;
        }
        
        if (ratingCount > 0) {
            int ratingAverage = ratingSum / ratingCount;
            
            [self setUpLeftAlignedRateView:ratingAverage];
            
            [self.ratingsTableView reloadData];
        }
    }];
}

- (void)setUpLeftAlignedRateView:(int) rating
{
    
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(4, 27, 160, 14)];
    rateView.rate = rating;
    rateView.alignment = RateViewAlignmentLeft;
    [self.ratingsView addSubview:rateView];
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

-(void)dismissKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.expertiseTextField resignFirstResponder];
    [self.aboutMeTextView resignFirstResponder];
//    [self.achievementsTextView resignFirstResponder];
    [self.websiteTextField resignFirstResponder];

}

#pragma mark - about me text view delegate methods (for placehoder text to exist)

//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    if ([self.aboutMeTextView.text isEqualToString:@"About Me"]) {
//        self.aboutMeTextView.text = @"";
//        self.aboutMeTextView.textColor = [UIColor blackColor]; //optional
////        self.aboutMeTextView.textAlignment = NSTextAlignmentLeft;
//        //        [self.aboutMeTextView becomeFirstResponder];
//    }
//}
//
- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if ([self.aboutMeTextView.text isEqualToString:@""]) {
//        self.aboutMeTextView.text = @"About Me";
//        self.aboutMeTextView.textColor = [UIColor colorWithWhite: 0.8 alpha:1]; //optional
////        self.aboutMeTextView.textAlignment = NSTextAlignmentCenter;
//        [self.aboutMeTextView resignFirstResponder];
//    }
    if (!(allTrim(self.aboutMeTextView.text).length == 0))
    {
        NSLog(@"save about me pls");
        self.currentUser[@"aboutMe"] = self.aboutMeTextView.text;
    }
//    if (!(allTrim(self.achievementsTextView.text).length == 0))
//    {
//        NSLog(@"save achievements pls");
//        self.currentUser[@"achievements"] = self.achievementsTextView.text;
//    }
    [self.currentUser saveInBackground];

}

#pragma mark - table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ratingsArray.count;
}

-(ReviewTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewReuseCellID"];
    cell.ratingInt = [self.ratingsArray[indexPath.row][@"rating"]intValue];
    NSLog(@"ratinge %d",[self.ratingsArray[indexPath.row][@"rating"]intValue]);
    
    NSString *ratingString = [NSString stringWithFormat:@"%d",[self.ratingsArray[indexPath.row][@"rating"]intValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRatingStars" object:ratingString];

    
    cell.reviewerLabel.text = [NSString stringWithFormat:@"Reviewed by %@", self.ratingsArray[indexPath.row][@"reviewerName"]];
    cell.reviewerLabel.font = [UIFont italicSystemFontOfSize:13.0f];
    cell.reviewerLabel.textColor = [UIColor darkGrayColor];
    cell.reviewTextView.text = self.ratingsArray[indexPath.row][@"reviewText"];
    return cell;
}

#pragma mark - location methods
// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"ore here");
    // this creates a CLGeocoder to find a placemark using the found coordinates
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(),^ {
                           // do stuff with placemarks on the main thread
                           
                           if (placemarks.count == 1) {
                               MKPlacemark * myPlacemark = [placemarks firstObject];
                               // with the placemark you can now retrieve the city name
                               NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
                               NSString *state = [myPlacemark.addressDictionary objectForKey:(NSString*) kABPersonAddressStateKey];
                               
                               [self.locationManager stopUpdatingLocation];
                               
                               if (city && state)
                               {
                                   self.currentUser[@"city"] = city;
                                   self.currentUser[@"state"] = state;
                               }
                               self.currentUser[@"latitude"] = @(self.locationManager.location.coordinate.latitude);
                               self.currentUser[@"longitude"] = @(self.locationManager.location.coordinate.longitude);
                               
                               CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
                               PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                                             longitude:coordinate.longitude];
                               
                               self.currentUser[@"geoPoint"] = geoPoint;
                               
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
                    });
    }];
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
    [manager stopUpdatingLocation];
}

#pragma mark - text view related methods

- (IBAction)onUsernameDidEndOnExit:(id)sender
{
    [self.usernameTextField endEditing:YES];
}


- (IBAction)onWebsiteTextFieldDidEndOnExit:(id)sender
{
    self.currentUser[@"website"] = self.websiteTextField.text;
    [self.currentUser saveInBackground];
    [self.websiteTextField endEditing:YES];
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
    
    // so the following action only happens when you change your expertise, prompting you to choose new tags
    // the action sheets title is and must be Thanks for this to work currently
    if ([actionSheet.title isEqualToString:@"Thanks!"])
    {
        if (buttonIndex == 0)
        {
            CRTableViewController *crTableViewController = [[CRTableViewController alloc] initWithStyle:UITableViewStylePlain];
            //CRTableViewController *tableView = [[CRTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:crTableViewController];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

#pragma mark - button methods

- (IBAction)videoButtonTapped:(id)sender
{
    NSLog(@"own? %hhd", self.ownProfile);
    
    if (self.ownProfile)
    {
        [self performSegueWithIdentifier:@"ToOwnVideoVC" sender:self];
    }
    else
    {
        if (self.selectedUserProfile[@"videoIdentifier"])
        {
            [self performSegueWithIdentifier:@"ToOthersVideoViewVC" sender:self];
        }
        else
        {
            NSLog(@"no video");
            UIAlertView *noVideoAlert = [[UIAlertView alloc] initWithTitle:@"Video Unavailable" message:@"This Expert has not shared a video." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noVideoAlert show];
        }
    }
}


- (IBAction)onFindLocationButtonPressed:(id)sender
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"pressed");
}

- (IBAction)onGalleryButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"ToGallerySegue" sender:self];
}

- (IBAction)addAReviewButtonTapped:(id)sender {
}

#pragma mark - image picker methods

- (IBAction)onAvatarChangeButtonPressed:(id)sender
{
    self.avatarButtonPressed = 1;
    [self presentPicker:sender];
}

- (IBAction)onBackgroundChangeButtonPressed:(id)sender
{
    self.backgroundButtonPressed = 1;
    [self presentPicker:sender];
}

- (void)presentPicker:(UIButton *)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	if(((UIButton *) sender == self.avatarChangeButton) || ((UIButton *) sender == self.backgroundChangeButton))
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

    if (self.avatarButtonPressed)
    {
        NSLog(@"avatar pressed");
        user[@"avatar"] = imageFile;
        
        // getting a uiimage from pffile
        [user[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
            }
        }];
    }
    else if (self.backgroundButtonPressed)
    {
        NSLog(@"background pressed");
        user[@"backgroundImage"] = imageFile;
        
        // getting a uiimage from pffile
        [user[@"backgroundImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.backgroundImageView.image = photo;
            }
        }];
    }
    
    self.avatarButtonPressed = 0;
    self.backgroundButtonPressed = 0;
    
    [user saveInBackground];
}
#pragma mark - email methods

- (IBAction)showEmail:(id)sender {
    // Email Subject
    NSString *emailTitle;
    // Email Content
    NSString *messageBody;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:self.selectedUserProfile.email];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - segue methods

- (IBAction)unwindFromTags:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToWebSegue"])
    {
        WebViewController *wvc = segue.destinationViewController;
        wvc.urlString = self.websiteButton.titleLabel.text;
    }
    else if ([segue.identifier isEqualToString:@"ToGallerySegue"])
    {
        GalleryViewController *gvc = segue.destinationViewController;
        gvc.ownProfile = self.ownProfile;
        gvc.selectedUserProfile = self.selectedUserProfile;
    }
    else if ([segue.identifier isEqualToString:@"ToMoreInfoSegue"])
    {
        InfoViewController *ivc = segue.destinationViewController;
        ivc.ownProfile = self.ownProfile;
        ivc.selectedUserProfile = self.selectedUserProfile;
    }
    else if ([segue.identifier isEqualToString:@"AddAReviewSegue"])
    {
        AddAReviewViewController *aarvc = segue.destinationViewController;
        aarvc.selectedUserProfile = self.selectedUserProfile;
    }
    else if ([segue.identifier isEqualToString:@"ToOwnVideoVC"])
    {

    }
    else if ([segue.identifier isEqualToString:@"ToOthersVideoViewVC"])
    {
        VideoPlayViewController *vpvc = segue.destinationViewController;
        vpvc.videoIdentifier = self.selectedUserProfile[@"videoIdentifier"];
    }
}

@end
