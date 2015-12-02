//
//  ViewController.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "VenueTableView.h"

@interface VenueTableView ()
@property (strong, nonatomic) IBOutlet UITableView *venuesTableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *venues;


@end

@implementation VenueTableView
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *textViewLocation;
    BOOL reachableConnection;
    int *isLinkedToFacebook;
    NSString *administrativeAreaLock;
    NSString *thoroughfare;
    dispatch_group_t resolveGPSAddress;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [self configureRestKit];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    resolveGPSAddress = dispatch_group_create();
    [self refreshTable];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:true];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectedVenueSegue"])
    {
        SelectedVenueVC *nextViewController = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        //Push the -> objectAtIndex:indexPath.row <- to the new VC
        //You must push an object from this VC to the nextViewController
    }
}

//Initialize GPS and find location
-(void)gpsInitialize
{
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Can change the GPS Accurancy
}


#pragma mark - CLLocationManagerDelegate
//In case of error resolving the address
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alertVC addAction:defaultAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        //Για άμεση ενημέρωση, προβολή των δεδομένων  όσο το στίγμα του GPS είναι ανοικτό
        
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             
             //Βοηθητικές μεταβλητές που περιέχουν τις συντεταγμένες που πήραμε από το GPS
             self.longitude = [[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] doubleValue];
             self.latitude = [[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude] doubleValue];
             
         }
         else
         {
             NSLog(@"%@", error.debugDescription);
         }
         dispatch_group_leave(resolveGPSAddress);
     }];
    
    
}

#pragma mark - UITableViewDataSource
- (void)refreshTable
{
    //TODO: refresh your data
    dispatch_group_enter(resolveGPSAddress);
    [self gpsInitialize]; //Take the new GPS Location
    
    //Wait until the block group finished and run the above code
    dispatch_group_notify(resolveGPSAddress, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"FINAL BLOCK");
        [self loadVenues];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 5; //Change this Value
    return _venues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    //[tableView registerClass:[VenueTableViewCell class] forCellReuseIdentifier:@"cell"];
    VenueTableViewCell *cell = (VenueTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Venue *venue = _venues[indexPath.row];
    cell.cellTitleLabel.text = venue.name;
    cell.cellSubtitleLabel.text = [NSString stringWithFormat:@"%.0fm", venue.location.distance.floatValue];
    
//    cell.cellImageView.image = [UIImage imageNamed:@"defaultImage"];
//    cell.cellImageView.clipsToBounds = YES;
//    cell.cellImageView.layer.cornerRadius = cell.cellImageView.frame.size.width/2;
//    
//    [cell.cellTitleLabel setText:[NSString stringWithFormat:@"Row %i in Section %i", [indexPath row], [indexPath section]]];
//    cell.cellSubtitleLabel.text = @"swag";
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"selectedVenueSegue" sender:indexPath];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    //    UIViewControllerGASelectedReport *pushVC = [[UIViewControllerGASelectedReport alloc] initWithNibName:@"selectedReportVC" bundle:nil];
    //    [self.navigationController pushViewController:pushVC animated:YES];
    
}

# pragma mark - RestKit & Foursquare Retrieve Methods
- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:kBaseApiUrl];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:kVenueSearchPath
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // define location object mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"crossStreet", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
}

- (void)loadVenues
{
    NSString *latitude = [NSString stringWithFormat:@"%f", self.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", self.longitude];
    NSNumber *resultRadius = [NSNumber numberWithInt:3000];
    
    NSString *latLon = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
    NSString *addedCategoriesId = [NSString stringWithFormat:@"%@,%@",kFood, kNightlifeSpot];
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    NSString *radius = [NSString stringWithFormat:@"%@", resultRadius];
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : clientID,
                                  @"radius" : radius,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : addedCategoriesId,
                                  @"v" : kVersion};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:kVenueSearchPath
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}
@end
