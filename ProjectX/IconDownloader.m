//
//  IconDownloader.m
//  ProjectX
//
//  Created by Giorgos Moustakas on 12/12/15.
//  Copyright © 2015 icsd12004. All rights reserved.
//

#import "IconDownloader.h"
#import "Venue.h"

#define kAppIconSize 67


@interface IconDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end


#pragma mark -

@implementation IconDownloader

// -------------------------------------------------------------------------------
//	startDownload
// -------------------------------------------------------------------------------
- (void)startDownload
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.venue.imageURL];
    
    NSLog(@"downloading image %@ for venue %@", self.venue.imageURL, self.venue.name);

    // create an session data task to obtain and download the app icon
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // in case we want to know the response status code
        NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"response is %ld", (long)HTTPStatusCode);
                                                       

        if (error != nil)
        {
            if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
            {
                // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                // then your Info.plist has not been properly configured to match the target server.
                //
                abort();
            }
        }
                                                       
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            
            // Set appIcon and clear temporary data/image
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (HTTPStatusCode == 200) {
                if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
                {
                    CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    [image drawInRect:imageRect];
                    self.venue.image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                else
                {
                    self.venue.image = image;
                }
            }
            else {
                self.venue.image = [UIImage imageNamed:@"Placeholder.png"];
            }
            
            
            
            // call our completion handler to tell our client that our icon is ready for display
            if (self.completionHandler != nil)
            {
                self.completionHandler();
            }
        }];
    }];
    
    [self.sessionTask resume];
}

// -------------------------------------------------------------------------------
//	cancelDownload
// -------------------------------------------------------------------------------
- (void)cancelDownload
{
    [self.sessionTask cancel];
    _sessionTask = nil;
}

@end

