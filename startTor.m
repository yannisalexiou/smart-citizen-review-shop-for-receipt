//
//  startTor.m
//  swiftRest
//
//  Created by Giorgos Moustakas on 18/12/15.
//  Copyright © 2015 Giorgos Moustakas. All rights reserved.
//

#import "startTor.h"
#include <CPAProxy/CPAProxy.h>

@implementation startTor {
    CPAProxyManager *cpaProxyManager;
    NSString *theSocksHost;
    NSUInteger theSocksPort;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Get resource paths for the torrc and geoip files from the main bundle
        NSURL *cpaProxyBundleURL = [[NSBundle mainBundle] URLForResource:@"CPAProxy" withExtension:@"bundle"];
        NSBundle *cpaProxyBundle = [NSBundle bundleWithURL:cpaProxyBundleURL];
        NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
        NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
        
        // Place to store Tor caches (non-temp storage improves performance since
        // directory data does not need to be re-loaded each launch)
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *torDataDir = [documentsDirectory stringByAppendingPathComponent:@"tor"];
        
        // Initialize a CPAProxyManager
        CPAConfiguration *configuration = [CPAConfiguration configurationWithTorrcPath:torrcPath geoipPath:geoipPath torDataDirectoryPath:torDataDir];
        cpaProxyManager = [CPAProxyManager proxyWithConfiguration:configuration];
        NSLog(@"initializing");
        [self cpa];
    }
    return self;
}

- (void) cpa {
    [cpaProxyManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
        if (error == nil) {
            // ... do something with Tor socks hostname & port ...
            NSLog(@"Connected: host=%@, port=%lu", socksHost, (long)socksPort);
            
            theSocksHost = socksHost;
            theSocksPort = socksPort;
            
            // ... like this -- see below for implementation ...
            [self handleCPAProxySetupWithSOCKSHost:socksHost SOCKSPort:socksPort];
        }
    } progress:^(NSInteger progress, NSString *summaryString) {
        // ... do something to notify user of tor's initialization progress ...
        NSLog(@"%li %@", (long)progress, summaryString);
        NSString *theprogress = [NSString stringWithFormat:@"%li %@", (long)progress, summaryString ];
        
        NSDictionary *progressDic = [[NSDictionary alloc]
                                          initWithObjectsAndKeys:
                                          theprogress, @"progress",
                                          nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"torStatus"
                                                            object:self
                                                          userInfo:progressDic];
    }];
}



- (void)handleCPAProxySetupWithSOCKSHost:(NSString *)SOCKSHost SOCKSPort:(NSUInteger)SOCKSPort
{
    // Create a NSURLSessionConfiguration that uses the newly setup SOCKS proxy
    NSDictionary *proxyDict = @{
                                (NSString *)kCFStreamPropertySOCKSProxyHost : SOCKSHost,
                                (NSString *)kCFStreamPropertySOCKSProxyPort : @(SOCKSPort)
                                };
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
    
    // Create a NSURLSession with the configuration
    _urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // Send an HTTP GET Request using NSURLSessionDataTask
//    NSURL *URL = [NSURL URLWithString:@"https://check.torproject.org"];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:URL];
//    [dataTask resume];
    
    
    // ...
}

@end
