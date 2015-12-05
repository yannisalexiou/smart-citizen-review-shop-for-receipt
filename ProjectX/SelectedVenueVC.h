//
//  SelectedVenueVC.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Venue.h"

@protocol SelectedVenueVCDelegate <NSObject>

-(void)popToVenuesNearMy;

@end

@interface SelectedVenueVC : UIViewController

/*
 You must have a retrievedVenueObject property
for example PFObject if you use Parse
 */

/*
 If you need to pass the image from Cell
@property (strong, nonatomic) UIImage *profileImage;
*/

@property (strong, nonatomic) Venue *retrievedVenue;

@end
