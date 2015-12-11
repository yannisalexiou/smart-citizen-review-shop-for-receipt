//
//  Photos.h
//  ProjectX
//
//  Created by Giovanni Alexiou on 05/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

/*
 size can be one of the following, where XX or YY is one of 36, 100, 300, or 500.
 XXxYY
 original: the original photo's size
 capXX: cap the photo with a width or height of XX (whichever is larger). Scales the other, smaller dimension proportionally
 widthXX: forces the width to be XX and scales the height proportionally
 heightYY: forces the height to be YY and scales the width proportionally
*/

#import <Foundation/Foundation.h>

@interface Photos : NSObject

//To assemble a resolvable photo URL, take prefix + size + suffix
@property (nonatomic, strong) NSString *photoId; //A unique string identifier for this photo.
@property (nonatomic, strong) NSString *createdAt; //Seconds since epoch when this photo was created.
@property (nonatomic, strong) NSString *prefix; //Start of the URL for this photo.
@property (nonatomic, strong) NSString *suffix; //Ending of the URL for this photo.
@property (nonatomic, strong) NSString *visibility;

@end
