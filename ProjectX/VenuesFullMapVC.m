//
//  VenuesFullMapVC.m
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "VenuesFullMapVC.h"

@interface VenuesFullMapVC ()

@end

@implementation VenuesFullMapVC
{
    CLLocationManager *locationManager; //Δημιουργία object τύπου CLLocationManager
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *textViewLocation;
    //CGAffineTransform *scale;
    //CGAffineTransform *translate;
    BOOL reachableConnection;
    int *isLinkedToFacebook;
    NSString *administrativeAreaLock;
    NSString *thoroughfare;
}

@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self addVenuesToMap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    
    [self gpsInitialize];
    geocoder = [[CLGeocoder alloc] init];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];


}

- (void) addVenuesToMap {
    
    for (Venue* venue in self.Venues) {
        NSLog(@"adding %@ to map", venue.name);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        
        CLLocationCoordinate2D coord;
        coord.latitude = (CLLocationDegrees)[venue.location.lat doubleValue];
        coord.longitude = (CLLocationDegrees)[venue.location.lng doubleValue];
        point.coordinate = coord;
        
        point.title = venue.name;
        point.subtitle = [venue.location.distance stringValue];
        
        [self.mapView addAnnotation:point];
    }
}

//Initialize GPS and find location
-(void)gpsInitialize
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; //Με βέλτιστη αναζήτηση τοποθεσίας
    
    self.mapView.showsUserLocation = YES;
}


#pragma mark - CLLocationManagerDelegate
//Μέθοδος σε περίπτωση προβλήματος ανάκτησης διεύθυνσης

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
             //Βοηθητικό string  που περιέχει όλες τις πληροφορίες διεύθυνσης από τον χάρτη
             //             NSString *placemarkInfo = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
             //                                        placemark.subThoroughfare, placemark.thoroughfare,
             //                                        placemark.postalCode, placemark.locality,
             //                                        placemark.administrativeArea,
             //                                        placemark.country];
             
             //Βοηθητικές μεταβλητές που περιέχουν τις συντεταγμένες που πήραμε από το GPS
             self.longitude = [[NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude] doubleValue];
             self.latitude = [[NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude] doubleValue];
             
             
             //Δμιουργεία του Map
             self.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
             MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.coordinate, 600, 400);
             [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
             self.mapView.showsUserLocation = YES;
             
             textViewLocation = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare,placemark.administrativeArea];
             //This will help us to lock the usability of our application to kGASubmitAdministrativeAreaSamos.
             administrativeAreaLock = [NSString stringWithFormat:@"%@", placemark.administrativeArea];
             NSString *checkNull = @"(null)";
             if (([placemark.thoroughfare  isEqual: checkNull]))
             {
                 NSLog(@"Inside if for null: %@", placemark.thoroughfare);
                 self.navigationItem.title = [NSString stringWithFormat:@"%@", placemark.thoroughfare];
             }
             
             //Εδω θα μπει σε if (administrativeAreaLock != kGASubmitAdministrativeAreaSamos στην τελική φάση της εφαρμογής
             //self.commentTextView.text = textViewLocation;<----------------------
             

             MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 5000, 5000);
             MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
             [self.mapView setRegion:adjustedRegion animated:YES];
             
         } else {
             NSLog(@"%@", error.debugDescription);
         }
     }
     ];
}
- (IBAction)DonebuttonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
