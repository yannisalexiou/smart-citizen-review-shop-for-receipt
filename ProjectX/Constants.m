//
//  Constants.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 01/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - Foursquare API
NSString *const kBaseApiUrl = @"https://api.foursquare.com";

#pragma mark Venues General Path
NSString *const kVenueSearchPath = @"/v2/venues/search";

#pragma mark venues/search Parameters
NSString *const kLl         = @"ll";
NSString *const kNear       = @"near";
NSString *const kLlAcc      = @"llAcc";
NSString *const kAlt        = @"alt";
NSString *const kAltAcc     = @"altAcc";
NSString *const kQuery      = @"query";
NSString *const kLimit      = @"limit";
NSString *const kIntent     = @"intent";
NSString *const kRadius     = @"radius";
NSString *const kSw         = @"sw";
NSString *const kNe         = @"ne";
NSString *const kCategoryId = @"categoryId";
NSString *const kUrl        = @"url";
NSString *const kProviderId = @"providerId";
NSString *const kLinkedId   = @"linkedId";

#pragma mark Foursquare Category Hierarchy
NSString *const kArtsAndEntertainment = @"4d4b7104d754a06370d81259";
NSString *const kCollegeAndUniversity = @"4d4b7105d754a06372d81259";
NSString *const kEvent = @"4d4b7105d754a06373d81259";
NSString *const kFood = @"4d4b7105d754a06374d81259";
NSString *const kNightlifeSpot = @"4d4b7105d754a06376d81259";
NSString *const kOutdoorsAndRecreation = @"4d4b7105d754a06377d81259";
NSString *const kProfessionalAndOtherPlaces = @"4d4b7105d754a06375d81259";
NSString *const kShopAndService = @"4d4b7105d754a06378d81259";
NSString *const kTravelAndTransport = @"4d4b7105d754a06379d81259";

#pragma mark Parse Venue Class
NSString *const kVenueClassKey = @"Venue";
NSString *const kFoursquareVenueIdKey = @"foursquareVenueId";

#pragma mark Parse User Class
NSString *const kUsersClassKey = @"Users";
NSString *const kUserUniqueIdKey = @"userUniqueId";

#pragma mark Parse Rate Class

@end
