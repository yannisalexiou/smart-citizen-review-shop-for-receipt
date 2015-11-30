//
//  Venue.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 30/11/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;

@interface Venue : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Location *location;

@end
