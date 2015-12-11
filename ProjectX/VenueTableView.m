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
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSMutableArray *photos;


@end

@implementation VenueTableView
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *textViewLocation;
    BOOL reachableConnection;
    NSString *administrativeAreaLock;
    NSString *thoroughfare;
    NSUInteger venuesPhotoCounter;
    
    dispatch_group_t resolveGPSAddress;
    dispatch_group_t resolveVenues;
    dispatch_group_t resolveAllVenuePhotos;
    
    Venue *currentVenue;
    
    //Restkit Objects
    NSURL *baseURL;
    AFHTTPClient *client;
    RKObjectManager *objectManager;
    RKObjectMapping *venueMapping;
    RKObjectMapping *photosMapping;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.photos = [[NSMutableArray alloc] init];
    
    [self configureRestKit];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    resolveGPSAddress = dispatch_group_create();
    resolveVenues = dispatch_group_create();
    resolveAllVenuePhotos = dispatch_group_create();
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
        currentVenue = _venues[indexPath.row];
        nextViewController.retrievedVenue = currentVenue;
    }
}

//Initialize GPS and find location
-(void)gpsInitialize
{
    geocoder = [[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Can change the GPS Accurancy
    [locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
//In case of error resolving the address
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError: %@", error);
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alertVC addAction:defaultAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
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
    venuesPhotoCounter = 0;
    dispatch_group_enter(resolveGPSAddress);
    [self gpsInitialize]; //Take the new GPS Location
    
    dispatch_group_enter(resolveVenues);
    //Wait until the block group finished and run the above code
    dispatch_group_notify(resolveGPSAddress, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"resolveGPSAddress");
        [self loadVenues];
    });
    
    dispatch_group_enter(resolveAllVenuePhotos);
    dispatch_group_notify(resolveVenues, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"resolveVenues");
        [self controlVenueAspect];
    });
    
    dispatch_group_notify(resolveAllVenuePhotos, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"resolveVenuePhotos");
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
    
    currentVenue = _venues[indexPath.row];
    currentVenue.photos = _photos[indexPath.row];
    
    cell.cellTitleLabel.text = currentVenue.name;
    cell.cellSubtitleLabel.text = [NSString stringWithFormat:@"%.0fm", currentVenue.location.distance.floatValue];
    NSString *photoSize = @"original";
    NSString *imageFullPath = [NSString stringWithFormat:@"%@%@%@", currentVenue.photos.prefix, photoSize, currentVenue.photos.suffix];
    cell.cellImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageFullPath]]];
    NSLog(@"imageFullPath : %@", imageFullPath);
    
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
    baseURL = [NSURL URLWithString:kBaseApiUrl];
    client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    //[venueMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
    [venueMapping addAttributeMappingsFromDictionary:@{@"id" : @"venueId",
                                                       @"name" : @"name",}];
    
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
    
    // define photos object mapping
    photosMapping = [RKObjectMapping mappingForClass:[Photos class]];
    //[photosMapping addAttributeMappingsFromArray:@[@"id", @"createdAt", @"prefix", @"suffix", @"visibility"]];
    [photosMapping addAttributeMappingsFromDictionary:@{@"id" : @"photoId",
                                                        @"createdAt" : @"createdAt",
                                                        @"prefix" : @"prefix",
                                                        @"suffix" : @"suffix",
                                                        @"visibility" : @"visibility"}];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"photos" toKeyPath:@"photos" withMapping:photosMapping]];
}

//Search Venue
- (void)loadVenues
{
    NSString *latitude = [NSString stringWithFormat:@"%f", self.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", self.longitude];
    NSNumber *resultRadius = [NSNumber numberWithInt:3000];
    
    NSString *latLon = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
    NSString *addedCategoriesId = [NSString stringWithFormat:@"%@,%@",kFood, kNightlifeSpot];
    NSString *radius = [NSString stringWithFormat:@"%@", resultRadius];
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : kCLIENTID,
                                  @"radius" : radius,
                                  @"client_secret" : kCLIENTSECRET,
                                  @"categoryId" : addedCategoriesId,
                                  @"v" : kVersion};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:kVenueSearchPath
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  //[self.tableView reloadData];
                                                  //[self controlVenueAspect];
                                                  dispatch_group_leave(resolveVenues);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                                  dispatch_group_leave(resolveVenues);
                                              }];
}

- (void)controlVenueAspect
{
    NSLog(@"controlVenueAspect");
    Venue *venueToUpdate;
    for (venueToUpdate in _venues)
    {
        [self requestVenuePhoto:venueToUpdate];
    }
    
}

//Request Photos for Venue
- (void)requestVenuePhoto:(Venue *)thisVenue
{
    NSLog(@"requestVenuePhoto");
    NSString *venueId = thisVenue.venueId;
    NSNumber *resultLimit = [NSNumber numberWithInt:1];
    
    NSString *resultLimitString = [NSString stringWithFormat:@"%@", resultLimit];
    
    // register mappings with the provider using a response descriptor
    NSString *objectPath = [NSString stringWithFormat:@"/v2/venues/%@/photos", venueId];
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:photosMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:objectPath
                                                keyPath:@"response.photos.items"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    NSDictionary *queryParams = @{@"client_id" : kCLIENTID,
                                  @"limit" : resultLimitString,
                                  @"client_secret" : kCLIENTSECRET,
                                  @"v" : kVersion};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:objectPath parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        NSLog(@"YOLOO");
        //_photos = mappingResult.array;
        [self.photos addObjectsFromArray:mappingResult.array];
        venuesPhotoCounter++;
        if (venuesPhotoCounter == _venues.count)
        {
            //[self.tableView reloadData];
            dispatch_group_leave(resolveAllVenuePhotos);
        }
        
        //[self.tableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"What do you mean by 'there is no photos?': %@", error);
    }];
}

@end
