//
//  SearchResultsViewController.m
//  LIT
//
//  Created by Christopher Gu on 6/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultsTableViewCell.h"
#import "ProfileViewController.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@interface SearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (copy, nonatomic) NSArray *searchResultsArray;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSIndexPath *chosenIndexPath;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *locationCheckButton;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (strong, nonatomic) NSMutableArray *distanceMutableArray;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentUser = [PFUser currentUser];
    if (self.currentUser[@"latitude"] && self.currentUser[@"longitude"])
    {
        self.locationCheckButton.alpha = 0.0;
    }
    
    self.distanceMutableArray = [NSMutableArray new];
    
    // view all teachers or search using tags results
    if (self.viewAllChosen)
    {
        PFQuery *allUsersQuery = [PFUser query];
        [allUsersQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey: @"expertise"
                                                                     ascending: YES
                                                                      selector: @selector(caseInsensitiveCompare:)];
        [allUsersQuery orderBySortDescriptor: descriptor];
        [allUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.searchResultsArray = [objects sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
                NSString *expertise1 = [user1[@"expertise"] lowercaseString];
                NSString *expertise2 = [user2[@"expertise"] lowercaseString];
                
                if ([expertise1 compare: expertise2] == NSOrderedAscending)
                {
                    return NSOrderedAscending;
                }
                else{
                    return NSOrderedDescending;
                }
            }];
            
            [self addTheDistances];
            [self.myTableView reloadData];
        }];
    }
    else
    {
        PFQuery *usersWithMatchingTagsQuery = [PFUser query];
        [usersWithMatchingTagsQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
        [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:[self.selectedTagsDictionary allKeys]];
        [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.searchResultsArray = objects;
            NSArray *tempSearchResultsArray = self.searchResultsArray;
            
            self.searchResultsArray = [tempSearchResultsArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
                NSString *expertise1 = [user1[@"expertise"] lowercaseString];
                NSString *expertise2 = [user2[@"expertise"] lowercaseString];
                
                if ([expertise1 compare: expertise2] == NSOrderedAscending)
                {
                    return NSOrderedAscending;
                }
                else{
                    return NSOrderedDescending;
                }
            }];
            [self addTheDistances];
            [self.myTableView reloadData];
        }];
    }
}

#pragma mark - table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCellReuseID"];
    
    if (self.searchResultsArray[indexPath.row][@"avatar"])
    {
        [self.searchResultsArray[indexPath.row][@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                cell.myImageView.image = photo;
            }
        }];
    }
    else
    {
        cell.myImageView.image = [UIImage imageNamed:@"default_user"];
    }
    
    cell.myExpertiseLabel.text = self.searchResultsArray[indexPath.row][@"expertise"];
    cell.myUsernameLabel.text = self.searchResultsArray[indexPath.row][@"username"];
    
    if (self.distanceMutableArray && self.distanceMutableArray.count)
    {
        cell.myDistanceLabel.text = self.distanceMutableArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chosenIndexPath = indexPath;
    [self performSegueWithIdentifier:@"SearchToProfileSegue" sender:self];
}

#pragma mark - segmented control method

- (IBAction)onSegmentedControlChanged:(id)sender
{
    self.distanceMutableArray = nil;
    self.distanceMutableArray = [NSMutableArray new];
    
    if (self.mySegmentedControl.selectedSegmentIndex == 0)
    {
        NSArray *tempSearchResultsArray = self.searchResultsArray;
        
        self.searchResultsArray = [tempSearchResultsArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
            NSString *expertise1 = [user1[@"expertise"] lowercaseString];
            NSString *expertise2 = [user2[@"expertise"] lowercaseString];
            
            if ([expertise1 compare: expertise2] == NSOrderedAscending)
            {
                return NSOrderedAscending;
            }
            else{
                return NSOrderedDescending;
            }
        }];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex == 1)
    {
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:[self.currentUser[@"latitude"] doubleValue] longitude:[self.currentUser[@"longitude"] doubleValue]];
        
        self.searchResultsArray = [self.searchResultsArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
            float distance1 = [[[CLLocation alloc] initWithLatitude:[user1[@"latitude"] doubleValue] longitude:[user1[@"longitude"] doubleValue]] distanceFromLocation:locA];
            float distance2 = [[[CLLocation alloc] initWithLatitude:[user2[@"latitude"] doubleValue] longitude:[user2[@"longitude"] doubleValue]] distanceFromLocation:locA];
            if (distance1 < distance2) {
                return NSOrderedAscending;
            }
            else{
                return NSOrderedDescending;
            }
        }];
    }
    
    [self addTheDistances];
    [self.myTableView reloadData];
}

#pragma mark - helper methods

- (void)addTheDistances
{
    self.distanceMutableArray = nil;
    self.distanceMutableArray = [NSMutableArray new];
    
    
    
    for (PFUser *user in self.searchResultsArray)
    {
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:[self.currentUser[@"latitude"] doubleValue] longitude:[self.currentUser[@"longitude"] doubleValue]];
        
        if (user[@"latitude"] && user[@"longitude"])
        {
            float distance = [[[CLLocation alloc] initWithLatitude:[user[@"latitude"] doubleValue] longitude:[user[@"longitude"] doubleValue]] distanceFromLocation:userLocation];
            
            [self.distanceMutableArray addObject:[NSString stringWithFormat:@"%.1f miles",distance/1609.34]];
        }
        else
        {
            [self.distanceMutableArray addObject:@" "];
        }
    }
    
    NSLog(@"%@",self.distanceMutableArray);
}

#pragma mark - text field methods

- (IBAction)radiusTextFieldDidEndOnExit:(id)sender
{
    if (self.viewAllChosen)
    {
        PFQuery *allUsersQuery = [PFUser query];
        [allUsersQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey: @"expertise"
                                                                     ascending: YES
                                                                      selector: @selector(caseInsensitiveCompare:)];
        [allUsersQuery orderBySortDescriptor: descriptor];
        [allUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            self.searchResultsArray = [objects sortedArrayUsingComparator:^NSComparisonResult(PFUser *user1, PFUser *user2) {
                NSString *expertise1 = [user1[@"expertise"] lowercaseString];
                NSString *expertise2 = [user2[@"expertise"] lowercaseString];
                
                if ([expertise1 compare: expertise2] == NSOrderedAscending)
                {
                    return NSOrderedAscending;
                }
                else{
                    return NSOrderedDescending;
                }
            }];
            
            [self radiusHelper];
        }];

    }
    else
    {
        PFQuery *usersWithMatchingTagsQuery = [PFUser query];
        [usersWithMatchingTagsQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
        [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:[self.selectedTagsDictionary allKeys]];
        [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.searchResultsArray = objects;
            [self radiusHelper];
        }];
    }
}

-(void)radiusHelper
{
    NSMutableArray *radiusFilteredMutableArray = [NSMutableArray new];

    for (PFUser *user in self.searchResultsArray)
    {
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:[self.currentUser[@"latitude"] doubleValue] longitude:[self.currentUser[@"longitude"] doubleValue]];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[user[@"latitude"] doubleValue] longitude:[user[@"longitude"] doubleValue]];
        CLLocationDistance distance = [locA distanceFromLocation:locB]/1609.34;
        NSLog(@"user %@ distance %f",user.username, distance);
        
        if (![self.radiusTextField.text isEqualToString:@"0"] && ![allTrim(self.radiusTextField.text) isEqualToString:@""])
        {
            if (distance < [self.radiusTextField.text intValue])
            {
                [radiusFilteredMutableArray addObject:user];
            }
        }
    }

    if (radiusFilteredMutableArray.count)
    {
        self.searchResultsArray = [radiusFilteredMutableArray copy];
    }
    
    [self addTheDistances];
    [self.myTableView reloadData];
}

#pragma mark - button methods

- (IBAction)onLocationCheckButtonPressed:(id)sender
{
    if (self.currentUser)
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        UIAlertView *needToBeSignedInAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You must be signed in to search for experiences around you by radius." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [needToBeSignedInAlert show];
    }
    self.locationCheckButton.enabled = NO;
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

    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.locationCheckButton.alpha = 0.0;
        
        [self.radiusTextField becomeFirstResponder];
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

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProfileViewController *pvc = segue.destinationViewController;
    {
        pvc.selectedUserProfile = self.searchResultsArray[self.chosenIndexPath.row];
    }
}

@end
