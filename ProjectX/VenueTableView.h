//
//  ViewController.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "MapKit/MapKit.h"

#import "Venue.h"
#import "Location.h"
#import "Photos.h"
#import "Constants.h"
#import "LocationManager.h"
#import "Foursquare+Rest.h"
#import "IconDownloader.h"

#import "VenueTableViewCell.h"
#import "SelectedVenueVC.h"
#import "VenuesFullMapVC.h"
#import "startTor.h"

@interface VenueTableView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) SelectedVenueVC *selectedVenue;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

