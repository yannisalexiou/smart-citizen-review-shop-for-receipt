//
//  Foursquare+Rest.m
//  ProjectX
//
//  Created by Giorgos Moustakas on 12/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "Foursquare+Rest.h"

@implementation Foursquare_Rest {
    NSArray *venues;
    
    //Restkit Objects
    NSURL *baseURL;
    AFHTTPClient *client;
    RKObjectManager *objectManager;
    RKObjectMapping *venueMapping;
    RKObjectMapping *photosMapping;
    
    NSNumber *latitude;
    NSNumber *longtitude;
    int venuesPhotoCounter;
}

- (id)initWithLat :(NSNumber*)lat Long:(NSNumber*)lng
{
    self = [super init];
    if (self) {
        NSLog(@"initializing  Foursquare_Rest");

        latitude = lat;
        longtitude = lng;
    }
    return self;
}

- (void) start {
    [self configureRestKit];
    [self loadVenues];
}

# pragma mark - RestKit & Foursquare Retrieve Methods
- (void)configureRestKit
{
    NSLog(@"Configuring RestKit");
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
    NSNumber *resultRadius = [NSNumber numberWithInt:3000];
    
    NSString *latLon = [NSString stringWithFormat:@"%@,%@", latitude, longtitude];
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
                                                  venues = mappingResult.array;

                                                  // Για κάθε Venue ζητάμε τις φωτογραφίες
                                                  [self controlVenueAspect];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}

- (void) fetchedVenues {
    
    NSDictionary *venuesDictionary = [[NSDictionary alloc]
                                 initWithObjectsAndKeys:
                                 venues, @"Venues",
                                 nil];
    
    
    
    // Στέλνουμε notification σε όποια ενδιαφερόμενη μέθοδο
    [[NSNotificationCenter defaultCenter] postNotificationName:kVenuesResolvedNotif
                                                        object:self
                                                      userInfo:venuesDictionary];
}

- (void)controlVenueAspect
{
    venuesPhotoCounter = 0;
    NSLog(@"controlVenueAspect");
    for (Venue *thevenue in venues)
    {
        NSLog(@"Requesting photo for venue: name: %@\n venueID: %@\n", thevenue.name, thevenue.venueId);

        [self requestVenuePhoto:thevenue];
    }
    
}

//Request Photos for Venue
- (void)requestVenuePhoto:(Venue *)thisVenue
{
    NSLog(@"requesting photo of venue: %@", thisVenue.name);
    
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
         if (mappingResult.firstObject) {
             thisVenue.photos = mappingResult.firstObject;
         }

         NSString *photoSize = @"original";
         NSString *imageFullPath = [NSString stringWithFormat:@"%@%@%@", thisVenue.photos.prefix, photoSize, thisVenue.photos.suffix];
         NSURL *url = [NSURL URLWithString:imageFullPath];
         
         NSLog(@"URL for %@ with id %@  IS %@", thisVenue.name,thisVenue.venueId, url);
         thisVenue.imageURL = url;

         venuesPhotoCounter++;
         if (venuesPhotoCounter == venues.count)
         {
             [self fetchedVenues];
         }
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         NSLog(@"What do you mean by 'there is no photos?': %@", error);
     }];
}


@end
