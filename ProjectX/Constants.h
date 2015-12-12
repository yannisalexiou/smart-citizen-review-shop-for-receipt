//
//  Constants.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 01/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - Notification Names
#define kGPSResolvedNotif @"GPSAddressResolved"
#define kVenuesResolvedNotif @"FoursquareVenuesResolved"
#define kImagesResolvedNotif @"FoursquareImagesResolved"

#pragma mark - Foursquare API
#define kCLIENTID @"XRUE0KJHBVZVKJEX0RCDKCOQXFFTLS4RR0SVVFM30OMEJHTU"
#define kCLIENTSECRET @"T5JQKCPNIEXD3PUVPFFNRQQNF1V3QLCE0CBDUAFWKJEHJM5A"
#define kVersion @"20151201"

extern NSString *const kBaseApiUrl;

#pragma mark Venues General Path
extern NSString *const kVenueSearchPath;

#pragma mark venues/search Parameters
extern NSString *const kLl; //requared
extern NSString *const kNear;
extern NSString *const kLlAcc;
extern NSString *const kAlt;
extern NSString *const kAltAcc;
extern NSString *const kQuery;
extern NSString *const kLimit;
extern NSString *const kIntent;
extern NSString *const kRadius;
extern NSString *const kSw;
extern NSString *const kNe;
extern NSString *const kCategoryId;
extern NSString *const kUrl;
extern NSString *const kProviderId;
extern NSString *const kLinkedId;

#pragma mark Foursquare Category Hierarchy
extern NSString *const kArtsAndEntertainment;
extern NSString *const kCollegeAndUniversity;
extern NSString *const kEvent;
extern NSString *const kFood;
extern NSString *const kNightlifeSpot;
extern NSString *const kOutdoorsAndRecreation;
extern NSString *const kProfessionalAndOtherPlaces;
extern NSString *const kShopAndService;
extern NSString *const kTravelAndTransport;

@end
