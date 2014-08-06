//
//  NewsstandDownloader.m
//  Baker
//
//  Created by Tope on 21/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsstandDownloader.h"


@implementation NewsstandDownloader

-(void)downloadIssue:(IssueInfo*)issueInfo forIndexTag:(int)index{
    
    NKIssue* issue = issueInfo.nkIssue;
    
    NSURL *downloadURL = [NSURL URLWithString:issueInfo.contentUrl];
    
    if(!downloadURL) return;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [issue addAssetWithRequest:req];
    [assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:index],@"index",
                                nil]];
}



-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
 
    [self.delegate updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}


- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"connection:(NSURLConnection *)connection didWriteData"); 
    
    [self.delegate connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    NSLog(@"connection:(NSURLConnection *)connectionDidResumeDownloading");
    
   [self.delegate connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];

}


- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
    NSLog(@"connection:(NSURLConnection *)connectionDidFinishDownloading");
    NSLog(@"connection:(NSURLConnection *)connectionDidFinishDownloading");
    NKAssetDownload *asset = [connection newsstandAssetDownload];
    
    [self.delegate connectionDidFinishDownloading:connection destinationURL:destinationURL forIssue:asset.issue];
    
}




@end
