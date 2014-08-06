//
//  NewsstandDownloader.h
//  Baker
//
//  Created by Tope on 21/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#import "IssueInfo.h"

@protocol NewsstandDownloaderDelegate;

@interface NewsstandDownloader : NSObject <NSURLConnectionDownloadDelegate>

@property (nonatomic, assign) id<NewsstandDownloaderDelegate> delegate;

-(void)downloadIssue:(IssueInfo*)issueInfo forIndexTag:(int)index;

@end

@protocol NewsstandDownloaderDelegate <NSObject>

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;


- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL forIssue:(NKIssue*)issue;

@end
