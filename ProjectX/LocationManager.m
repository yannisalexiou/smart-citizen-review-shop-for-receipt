//
//  LocationManager.m
//  ProjectX
//
//  Created by Giorgos Moustakas on 12/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

// Initializer
- (id) init {
    self = [super init];
    
    if (self) {
        // Initializing our Location Manager
        locationManager = [[CLLocationManager alloc] init];
        if ([CLLocationManager locationServicesEnabled])
        {
            geocoder = [[CLGeocoder alloc] init];
            locationManager = [[CLLocationManager alloc] init];
            [locationManager requestWhenInUseAuthorization];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Can change the GPS Accurancy
            [locationManager startUpdatingLocation];
        }
    }
    return self;
}


#pragma mark - CLLocationManagerDelegate

// Successfully fetched location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // Αμέσως μόλις πάρουμε τις συνεταγμένες, σταματάμε τη χρήση του GPS
    // για να εξοικονομήσουμε μπαταρία
    [locationManager stopUpdatingLocation];
    
    CLLocation *currentLocation = newLocation;
    
    // Σε περίπτωση που δεν έχει γίνει κάποιο λάθος
    if (currentLocation != nil) {
        
        // Κράτάμε τις συντεταγμένες σε κατάλληλο τύπο NSNumber
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:
                                currentLocation.coordinate.latitude];
        NSNumber *longtitude = [[NSNumber alloc] initWithDouble:
                                currentLocation.coordinate.longitude];

        // Τις αποθηκεύουμε σε dictionary για να τις στείλουμε
        NSDictionary *coordinates = [[NSDictionary alloc]
                               initWithObjectsAndKeys:
                               latitude, @"Lat",
                               longtitude, @"Lng",
                               nil];
        
        NSLog(@"Coordicates: %@", coordinates);
        
        // Στέλνουμε notification σε όποια ενδιαφερόμενη μέθοδο
        [[NSNotificationCenter defaultCenter] postNotificationName:kGPSResolvedNotif
                                                            object:self
                                                          userInfo:coordinates];
    }
}

// Failed to fetch location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to Get Your Location" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alertVC addAction:defaultAction];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alertVC animated:YES completion:nil];
}



@end
