//
//  IssueDownloader.h
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 22.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

@protocol IssueDownloaderDelegate <NSObject>

-(void)updateProgressOfConnection:(NSURLConnection *)connection
            withTotalBytesWritten:(long long)totalBytesWritten
               expectedTotalBytes:(long long)expectedTotalBytes;

- (void)connection:(NSURLConnection *)connection
      didWriteData:(long long)bytesWritten
 totalBytesWritten:(long long)totalBytesWritten
expectedTotalBytes:(long long) expectedTotalBytes;

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection
                     totalBytesWritten:(long long)totalBytesWritten
                    expectedTotalBytes:(long long) expectedTotalBytes;


- (void)connectionDidFinishDownloading:(NSURLConnection *)connection
                        destinationURL:(NSURL *) destinationURL;

@end
@interface IssueDownloader : NSObject <NSURLConnectionDownloadDelegate>

@property (nonatomic, assign) id<IssueDownloaderDelegate> delegate;

+(IssueDownloader*)sharedManager;

-(void)downloadIsssueAtIndex:(NSInteger)index;


@end
