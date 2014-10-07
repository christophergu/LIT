//
//  IntermediateSearchResultsViewController.m
//  LiveIt
//
//  Created by Christopher Gu on 9/21/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "IntermediateSearchResultsViewController.h"
#import "SearchResultsViewController.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@interface IntermediateSearchResultsViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (copy, nonatomic) NSArray *searchResultsArray;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSIndexPath *chosenIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *locationCheckButton;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (strong, nonatomic) NSMutableArray *distanceMutableArray;

@property (nonatomic) NSMutableArray *categoryCheckerMutableArray;
@property (nonatomic) NSMutableArray *organizedByCategoryMutableArray;

@property (nonatomic) NSMutableArray *expertiseCheckerMutableArray;
@property (nonatomic) NSMutableArray *organizedByExpertiseMutableArray;


@end

@implementation IntermediateSearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"sel %@",self.selectedCategory);
    
    self.currentUser = [PFUser currentUser];
    if (self.currentUser[@"geoPoint"])
    {
        self.locationCheckButton.alpha = 0.0;
    }
    
    self.distanceMutableArray = [NSMutableArray new];
    self.categoryCheckerMutableArray = [NSMutableArray new];
    self.organizedByCategoryMutableArray = [NSMutableArray new];
    
    self.expertiseCheckerMutableArray = [NSMutableArray new];
    self.organizedByExpertiseMutableArray = [NSMutableArray new];

    PFQuery *usersWithMatchingTagsQuery = [PFUser query];
    [usersWithMatchingTagsQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
    [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:@[self.selectedCategory]];
    [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResultsArray = objects;
        NSArray *tempSearchResultsArray = self.searchResultsArray;
        
        // takes the returned users that have selected an expertise and also have a tag that matches the searched tag
        // alphabetizes them
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
        
        [self consolidateReturnedExperts];
        
        [self.myTableView reloadData];

        // this is to limit the returned users to within a 50 mile radius
        [self radiusHelper];
    }];
}

-(void)consolidateReturnedExperts
{
    // groups ppl with the same expertise into a single cell of that expertise's name
    for (PFUser *user in self.searchResultsArray)
    {
        NSString *currentMutableDictionaryKey = [user[@"expertise"] uppercaseString];
        
        if (![self.categoryCheckerMutableArray containsObject:[user[@"expertise"] uppercaseString]])
        {
            [self.categoryCheckerMutableArray addObject:[user[@"expertise"] uppercaseString]];
            NSMutableDictionary *categoryMutableDictionary = [NSMutableDictionary dictionaryWithObject:@[user] forKey:[user[@"expertise"] uppercaseString]];
            
            [self.categoryCheckerMutableArray addObject:[user[@"expertise"] uppercaseString]];
            [self.organizedByCategoryMutableArray addObject:categoryMutableDictionary];
        }
        else
        {
            for (NSMutableDictionary *existingMutableDictionary in self.organizedByCategoryMutableArray)
            {
                if ([[[existingMutableDictionary allKeys]firstObject]isEqualToString:currentMutableDictionaryKey])
                {
                    NSMutableArray *tempMutableArray = [NSMutableArray new];
                    [tempMutableArray addObjectsFromArray:existingMutableDictionary[currentMutableDictionaryKey]];
                    [tempMutableArray addObject:user];
                    [existingMutableDictionary setObject:tempMutableArray forKey:currentMutableDictionaryKey];
                }
            }
        }
    }
}

#pragma mark - table view methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.organizedByCategoryMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IntermediateCellReuseID"];
    
    cell.textLabel.text = [[[self.organizedByCategoryMutableArray[indexPath.row] allKeys] firstObject] uppercaseString];
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:22];
    int numberOfExperts = [self.organizedByCategoryMutableArray[indexPath.row][[[self.organizedByCategoryMutableArray[indexPath.row] allKeys] firstObject]] count];
    
    if (numberOfExperts < 2)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Expert in your area", numberOfExperts];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Experts in your area", numberOfExperts];
    }
    
    NSLog(@"lele %d",numberOfExperts);
    return cell;
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
- (IBAction)radiusChosenButtonTapped:(id)sender
{
    [self.radiusTextField resignFirstResponder];
    
    

    NSLog(@"radiusTextField");
    PFQuery *usersWithMatchingTagsQuery = [PFUser query];
    [usersWithMatchingTagsQuery whereKey:@"expertise" notEqualTo:[NSNull null]];
    [usersWithMatchingTagsQuery whereKey:@"tags" containsAllObjectsInArray:@[self.selectedCategory]];
    [usersWithMatchingTagsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResultsArray = objects;
        
        NSLog(@"obj %@",objects);
        [self radiusHelper];
    }];
}

-(void)radiusHelper
{
    NSMutableArray *radiusFilteredMutableArray = [NSMutableArray new];
    
    PFGeoPoint *userGeoPoint = [[PFGeoPoint alloc] init];
    userGeoPoint = self.currentUser[@"geoPoint"];
    
    for (PFUser *user in self.searchResultsArray)
    {
        PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
        geoPoint = user[@"geoPoint"];
        
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:userGeoPoint.latitude longitude:userGeoPoint.longitude];
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLLocationDistance distance = [locA distanceFromLocation:locB]/1609.34;
        NSLog(@"user %@ distance %f",user.username, distance);
        
        if (![self.radiusTextField.text isEqualToString:@"0"] && ![allTrim(self.radiusTextField.text) isEqualToString:@""])
        {
            if (distance < [self.radiusTextField.text intValue])
            {
                [radiusFilteredMutableArray addObject:user];
            }
        }
        else
        {
            if (distance < 50.0)
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
    
    self.categoryCheckerMutableArray = [NSMutableArray new];
    self.organizedByCategoryMutableArray = [NSMutableArray new];
    [self consolidateReturnedExperts];
    
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
                
                self.currentUser[@"city"] = city;
                self.currentUser[@"state"] = state;
                self.currentUser[@"latitude"] = @(self.locationManager.location.coordinate.latitude);
                self.currentUser[@"longitude"] = @(self.locationManager.location.coordinate.longitude);
                
                CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
                PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude];
                
                self.currentUser[@"geoPoint"] = geoPoint;
                
                [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    self.locationCheckButton.alpha = 0.0;
                    
                    [self.radiusTextField becomeFirstResponder];
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

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)senderCell
{
    SearchResultsViewController *srvc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:senderCell];
    NSMutableDictionary *dict = self.organizedByCategoryMutableArray[indexPath.row];
    srvc.selectedExpertiseUsersArray = dict[[[dict allKeys]firstObject]];
}
                                            

@end
