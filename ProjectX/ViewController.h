//
//  ViewController.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 29/10/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VenueTableViewCell.h"
#import "SelectedVenueVC.h"
#import "VenuesFullMapVC.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) SelectedVenueVC *selectedVenue;


@end

