//
//  Foursquare+Rest.h
//  ProjectX
//
//  Created by Giorgos Moustakas on 12/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Venue.h"
#import "Location.h"
#import "Photos.h"

#import "Constants.h"
#import "NotificationNames.h"

@interface Foursquare_Rest : NSObject

- (id)initWithLat :(NSNumber*)lat Long:(NSNumber*)lng;
- (void) start;

@end