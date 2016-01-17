//
//  VenuesFullMapVC.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <CoreLocation/CoreLocation.h>
#import "Venue.h"
#import "Location.h"

@interface VenuesFullMapVC : UIViewController < CLLocationManagerDelegate, MKMapViewDelegate >

- (instancetype)initWithvenues :(NSArray*)thevenues;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSArray *Venues;

@end
