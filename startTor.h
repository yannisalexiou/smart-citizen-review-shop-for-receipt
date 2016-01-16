//
//  startTor.h
//  swiftRest
//
//  Created by Giorgos Moustakas on 18/12/15.
//  Copyright © 2015 Giorgos Moustakas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface startTor : NSObject

@property (strong,nonatomic) NSURLSession *urlSession;

+ (id)sharedManager;

@end
