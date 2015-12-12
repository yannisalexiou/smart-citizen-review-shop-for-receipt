//
//  ViewController.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

//Client ID
//XRUE0KJHBVZVKJEX0RCDKCOQXFFTLS4RR0SVVFM30OMEJHTU
//
//Client Secret
//T5JQKCPNIEXD3PUVPFFNRQQNF1V3QLCE0CBDUAFWKJEHJM5A
#define kCLIENTID @"XRUE0KJHBVZVKJEX0RCDKCOQXFFTLS4RR0SVVFM30OMEJHTU"
#define kCLIENTSECRET @"T5JQKCPNIEXD3PUVPFFNRQQNF1V3QLCE0CBDUAFWKJEHJM5A"
#define kVersion @"20151201"

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Venue.h"
#import "Location.h"
#import "Photos.h"
#import "Constants.h"
#import "MapKit/MapKit.h"
#import "VenueTableViewCell.h"
#import "SelectedVenueVC.h"
#import "VenuesFullMapVC.h"
#import "LocationManager.h"
#import "Foursquare+Rest.h"
#import "IconDownloader.h"

@interface VenueTableView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) SelectedVenueVC *selectedVenue;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

