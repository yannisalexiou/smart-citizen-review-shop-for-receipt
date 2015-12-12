//
//  IconDownloader.h
//  ProjectX
//
//  Created by Giorgos Moustakas on 12/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

@class Venue;

@interface IconDownloader : NSObject

@property (nonatomic, strong) Venue *venue;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
