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

@interface VenuesFullMapVC : UIViewController < CLLocationManagerDelegate >

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end
