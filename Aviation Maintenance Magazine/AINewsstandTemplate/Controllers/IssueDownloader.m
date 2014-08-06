//
//  IssueDownloader.m
//  AINewsstandTemplate
//
//  Created by Alexey Ivanov on 22.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "IssueDownloader.h"
#import "ContentManager.h"


@implementation IssueDownloader


//singleton
+(IssueDownloader*)sharedManager{
    static IssueDownloader* __sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[IssueDownloader alloc] init];
    });
    
    return __sharedManager;
}


-(void)downloadIsssueAtIndex:(NSInteger)index{
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *issue = nkLib.issues[index];
    NSURL *downloadURL = [[ContentManager sharedManager] contentURLForIssueWithName:issue.name];
    if(!downloadURL) return;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [issue addAssetWithRequest:req];
    [assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:@{@"index": @(index),
                                 @"issueName":issue.name
                                 }];
    
}
#pragma mark - NSURLConnection delegate
-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes{
    
    [self.delegate connection:connection didWriteData:bytesWritten
            totalBytesWritten:totalBytesWritten
           expectedTotalBytes:expectedTotalBytes];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    
    [self.delegate connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection
                       destinationURL:(NSURL *)destinationURL
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NKAssetDownload *asset = [connection newsstandAssetDownload];
    NSURL* fileURL = [[asset issue] contentURL];
    NSString *issueName = [asset issue].name;
    NSString *fileName= [issueName stringByAppendingString:@".pdf"];

    
    //.PDF issue file
    if ([[destinationURL absoluteString] hasSuffix:@"pdf"]) {
        NSError *error;
        NSLog(@"PDF file suffix found");
        [[NSFileManager defaultManager] moveItemAtPath:[destinationURL path] toPath:[[fileURL path] stringByAppendingPathComponent:fileName] error:&error];
        if (error) {
            NSLog(@"error to move pdf file: %@",error.localizedDescription);
        }
        [self.delegate connectionDidFinishDownloading:connection destinationURL:destinationURL];
    }
    
}

-(void)updateProgressOfConnection:(NSURLConnection *)connection
            withTotalBytesWritten:(long long)totalBytesWritten
               expectedTotalBytes:(long long)expectedTotalBytes {
    
    [self.delegate updateProgressOfConnection:connection
                        withTotalBytesWritten:totalBytesWritten
                           expectedTotalBytes:expectedTotalBytes];
    
}


@end
